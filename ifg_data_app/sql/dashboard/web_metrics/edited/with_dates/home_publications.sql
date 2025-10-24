select
    pt.page_title [Publication title],
    da.file_name_clean [File name],
    da.file_path_latest [Link],
    sum(pv.page_views) [Page views (pages downloadable from)],
    sum(dc2.event_count) Downloads
from corporate.content_basic_metadata_canonical bm      -- Start with a page and build from there
    left join corporate.content_page_titles_canonical pt on     -- Attach page title. 1:1
        bm.url = pt.url
    outer apply (       -- Attach details of files available from page. 1:1
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
                    dc1.date between '1900-01-01' and '9999-12-31' and
                    da.file_path_latest = dc1.file_path_latest and
                    pv.url = dc1.url
            )
        group by
            pv.date
    ) pv
    outer apply (       -- Attach downloads for all pages from which the file has been downloaded. 1:1 following application of aggregation (1:n x m before this as there can be multiple files downloadable from a single URL)
        select
            sum(dc2.event_count) event_count
        from corporate.downloads_canonical dc2
        where
            da.file_path_latest = dc2.file_path_latest and
            exists (
                select *
                from corporate.downloads_canonical dc1
                where
                    dc1.date between '1900-01-01' and '9999-12-31' and
                    da.file_path_latest = dc1.file_path_latest and
                    dc2.url = dc1.url
            ) and
            pv.date = dc2.date
        group by
            dc2.date
    ) dc2
where
    bm.content_type = 'publication' and
    (
        (
            bm.published_date >= '1900-01-01' and
            bm.published_date <= '9999-12-31'
        ) or
        (
            bm.updated_date >= '1900-01-01' and
            bm.updated_date <= '9999-12-31'
        )
    ) and
    pt.page_title is not null and
    da.file_name_clean not like '%briefing%' and
    pv.date between '1900-01-01' and '9999-12-31'
group by
    pt.page_title,
    da.file_name_clean,
    da.file_path_latest;