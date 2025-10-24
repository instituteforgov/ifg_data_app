-- CONTENT METADATA
-- Unit of analysis: Single publication (downloadable file or page with content type of 'Publication')
select
    pt.page_title [Publication title],
    da.file_name_clean [File name],
    da.file_path_latest Link,
    da.file_extension [File type],
    bm.content_type [Content type],
    bm.publication_type [Publication type],
    bm.published_date [Published date],
    bm.updated_date [Updated date],
    t.team Team,
    a.author Author,
    p.topic Topic
from corporate.content_basic_metadata_canonical bm      -- Start with a page and build from there
    left join corporate.content_page_titles_canonical pt on     -- Attach page title. 1:1
        bm.url = pt.url
    outer apply (       -- Attach details of files available from page. 1:n
        select distinct
            da.url_most_common,
            da.file_path_latest,
            da.file_name_clean,
            da.file_extension
        from corporate.downloads_aggregated da
        where
            bm.url = da.url_most_common
    ) da
    outer apply (       -- Attach teams. 1:1 following application of aggregation
        select
            string_agg(t.team, ', ') team
        from corporate.content_teams_canonical t
        where
            da.url_most_common = t.url
        group by
            t.url
    ) t
    outer apply (       -- Attach topics. 1:1 following application of aggregation
        select
            string_agg(p.topic, ', ') topic
        from corporate.content_topics_canonical p
        where
            da.url_most_common = p.url
        group by
            p.url
    ) p
    outer apply (       -- Attach authors. 1:1 following application of aggregation
        select
            string_agg(a.author, ', ') author
        from corporate.content_authors_canonical a
        where
            da.url_most_common = a.url
        group by
            a.url
    ) a
where
    pt.page_title is not null and
    da.file_path_latest = ?;


-- METRICS
-- Unit of analysis: Unique dates
select
    pv.date Date,
    pv.page_views [Page views (pages downloadable from)],
    dc2.event_count Downloads
from corporate.content_basic_metadata_canonical bm      -- Start with a page and build from there
    outer apply (       -- Attach details of files available from page. 1:n
        select distinct
            da.url_most_common,
            da.file_path_latest,
            da.file_name_clean,
            da.file_extension
        from corporate.downloads_aggregated da
        where
            bm.url = da.url_most_common
    ) da
    outer apply (       -- Attach page views for all pages from which the file has been downloaded. 1:n following application of aggregation (1:n x m before this as a file can be downloadable from multiple URLs)
        select
            pv.date,
            sum(pv.page_views) page_views
        from corporate.page_views_canonical pv
        where
            exists (
                select *
                from corporate.downloads_canonical dc1
                where
                    dc1.date between ? and ? and
                    da.file_path_latest = dc1.file_path_latest and
                    pv.url = dc1.url
            )
        group by
            pv.date
    ) pv
    outer apply (       -- Attach downloads for all pages from which the file has been downloaded. 1:1 following application of aggregation (1:n x m before this as there can be multiple files downloadable from a single URL)
        select
            dc2.date,
            sum(dc2.event_count) event_count
        from corporate.downloads_canonical dc2
        where
            da.file_path_latest = dc2.file_path_latest and
            exists (
                select *
                from corporate.downloads_canonical dc1
                where
                    dc1.date between ? and ? and
                    da.file_path_latest = dc1.file_path_latest and
                    dc2.url = dc1.url
            ) and
            pv.date = dc2.date
        group by
            dc2.date
    ) dc2
where
    da.file_path_latest = ? and
    pv.date between ? and ?;


-- PAGES AVAILABLE FROM
-- Unit of analysis: Unique pages
-- NB: This differs from the structure of other publications queries as we:
    -- Need to match downloads to specific pages from which there have been page views, so need to apply another dc2 where clause
    -- Want the page details of pages the file has been downloaded from, rather than the page it is most commonly downloaded from
select
    pt.page_title [Page title],
    pv.url [Link],
    bm2.content_type [Content type],
    pv.page_views [Page views],
    dc2.event_count [Downloads]
from corporate.content_basic_metadata_canonical bm1       -- Start with a page and build from there
    outer apply (       -- Attach details of files available from page. 1:1 following application of where clause
        select distinct
            da.url_most_common,
            da.file_path_latest,
            da.file_name_clean,
            da.file_extension
        from corporate.downloads_aggregated da
        where
            bm1.url = da.url_most_common
    ) da
    outer apply (       -- Attach page views for all pages from which the file has been downloaded. 1:n following application of aggregation (1:n x m before this as a file can be downloadable from multiple URLs)
        select
            pv.url,
            sum(pv.page_views) page_views
        from corporate.page_views_canonical pv
        where
            exists (
                select *
                from corporate.downloads_canonical dc1
                where
                    dc1.date between ? and ? and
                    da.file_path_latest = dc1.file_path_latest and
                    pv.url = dc1.url
            )
        group by
            pv.url
    ) pv
    outer apply (       -- Attach downloads for all pages from which the file is available. 1:1 following application of aggregation (1:n before this as there can be multiple files downloadable from a single URL)
        select
            sum(dc2.event_count) event_count
        from corporate.downloads_canonical dc2
        where
            da.file_path_latest = dc2.file_path_latest and
            pv.url = dc2.url and
            exists (
                select *
                from corporate.downloads_canonical dc1
                where
                    dc1.date between ? and ? and
                    da.file_path_latest = dc1.file_path_latest and
                    dc2.url = dc1.url
            )
    ) dc2
    left join corporate.content_basic_metadata_canonical bm2 on      -- Attach basic page metadata. 1:1
        pv.url = bm2.url
    left join corporate.content_page_titles_canonical pt on     -- Attach page title. 1:1
        bm2.url = pt.url
where
    pt.page_title is not null and
    da.file_path_latest = ?;
