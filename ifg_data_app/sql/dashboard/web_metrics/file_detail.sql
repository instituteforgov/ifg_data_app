-- CONTENT METADATA
-- Uses CTEs to pre-aggregate teams/topics/authors once rather than per-row
with teams_agg as (
    select
        t.url,
        string_agg(t.team, ', ') team
    from corporate.content_teams_canonical t
    group by
        t.url
),
topics_agg as (
    select
        p.url,
        string_agg(p.topic, ', ') topic
    from corporate.content_topics_canonical p
    group by
        p.url
),
authors_agg as (
    select
        a.url,
        string_agg(a.author, ', ') author
    from corporate.content_authors_canonical a
    group by
        a.url
)
select
    p.page_title [File title],
    f.file_name_clean [File name],
    f.file_path_latest Link,
    f.file_extension [File type],
    p.content_type [Content type],
    p.publication_type [Publication type],
    p.published_date [Published date],
    p.updated_date [Updated date],
    t.team Team,
    a.author Author,
    tp.topic Topic
from corporate.pages p
    left join corporate.files f on
        p.url = f.url and
        f.is_url_most_common = 1
    left join teams_agg t on
        p.url = t.url
    left join topics_agg tp on
        p.url = tp.url
    left join authors_agg a on
        p.url = a.url
where
    f.file_path_latest = ?;


-- METRICS
-- Uses CTEs on page views and downloads for efficiency
-- Uses files date columns to filter file→URL relationships to those with downloads in the period
with page_views_agg as (
    select
        pv.url,
        pv.date,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
    where
        pv.date between ? and ?
    group by
        pv.url,
        pv.date
),
downloads_agg as (
    select
        dc.url,
        dc.file_path_latest,
        dc.date,
        sum(dc.downloads) downloads
    from corporate.downloads_canonical dc
    where
        dc.date between ? and ?
    group by
        dc.url,
        dc.file_path_latest,
        dc.date
)
select
    pv.date Date,
    sum(pv.page_views) [Page views (pages downloadable from)],
    sum(dc.downloads) Downloads
from corporate.files f
    left join page_views_agg pv on
        f.url = pv.url
    left join downloads_agg dc on
        pv.url = dc.url and
        pv.date = dc.date and
        f.file_path_latest = dc.file_path_latest
where
    f.file_path_latest = ? and
    f.first_download_date <= ? and
    f.last_download_date >= ?
group by
    pv.date;


-- PAGES DOWNLOADABLE FROM
-- Uses CTEs on page views and downloads for efficiency
-- Uses files date columns to filter file→URL relationships to those with downloads in the period
-- NB: In contrast to the home_publications.sql script, this doesn't include any minimum-downloads filtering, as we want to include all downloads
with page_views_agg as (
    select
        pv.url,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
    where
        pv.date between ? and ?
    group by
        pv.url
),
downloads_agg as (
    select
        dc.url,
        dc.file_path_latest,
        sum(dc.downloads) downloads
    from corporate.downloads_canonical dc
    where
        dc.date between ? and ?
    group by
        dc.url,
        dc.file_path_latest
)
select
    p.page_title [Page title],
    f.url [Link],
    p.content_type [Content type],
    pv.page_views [Page views],
    dc.downloads [Downloads],
    cast(dc.downloads as float) / nullif(pv.page_views, 0) [Download rate]
from corporate.files f
    left join corporate.pages p on
        f.url = p.url
    left join page_views_agg pv on
        f.url = pv.url
    left join downloads_agg dc on
        f.url = dc.url and
        f.file_path_latest = dc.file_path_latest
where
    f.file_path_latest = ? and
    f.first_download_date <= ? and
    f.last_download_date >= ?;
