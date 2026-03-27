-- AGGREGATED DATA BY DAY FOR LINE CHARTS
-- Uses CTEs on page views and downloads for efficiency
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
page_views_agg_files as (
    select
        f.file_name_clean,
        pv.date,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
        inner join corporate.files f on
            pv.url = f.url
    where
        pv.date between ? and ? and
        f.first_download_date <= ? and
        f.last_download_date >= ?
    group by
        f.file_name_clean,
        pv.date
),
downloads_agg as (
    select
        d.file_name_clean,
        d.date,
        sum(d.downloads) downloads
    from corporate.downloads_canonical d
    where
        d.date between ? and ?
    group by
        d.file_name_clean,
        d.date
)
select
    pv.date Date,
    coalesce(sum(pvf.page_views), sum(pv.page_views)) [Page views (pages downloadable from)],
    sum(d.downloads) Downloads,
    cast(sum(d.downloads) as float) / nullif(coalesce(sum(pvf.page_views), sum(pv.page_views)), 0) [Download rate (pages downloadable from)]
from corporate.pages p
    left join corporate.files f on
        p.url = f.url and
        f.is_url_most_common = 1
    inner join page_views_agg pv on
        p.url = pv.url
    left join page_views_agg_files pvf on
        f.file_name_clean = pvf.file_name_clean and
        pv.date = pvf.date
    left join downloads_agg d on
        f.file_name_clean = d.file_name_clean and
        pv.date = d.date
where
    (p.content_type = 'Publication' or f.url is not null)
group by
    pv.date;


-- AGGREGATED DATA BY FILE FOR DATA TABLES
-- XXX
-- Uses CTEs to pre-aggregate teams/topics/authors once rather than per-row
-- Uses CTEs on page views and downloads for efficiency
-- Applies a date restriction on corporate.files in the creation of page_views_agg_files to only pull page views from pages from which the file has been downloaded in the target period
-- Uses a coalesce statement on page views, to pull in page views for a single page for HTML-only publications and all pages from which the file is downloadable for publications with downloadable files
-- Uses a left join to corporate.files, page_views_agg_files and downloads_agg so we don't exclude HTML-only publications
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
),
page_views_agg as (
    select
        pv.url,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
    where
        pv.date between ? and ?
    group by
        pv.url
),
page_views_agg_files as (
    select
        f.file_name_clean,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
        inner join corporate.files f on
            pv.url = f.url
    where
        pv.date between ? and ? and
        f.first_download_date <= ? and
        f.last_download_date >= ?
    group by
        f.file_name_clean
),
downloads_agg as (
    select
        d.file_name_clean,
        sum(d.downloads) downloads
    from corporate.downloads_canonical d
    where
        d.date between ? and ?
    group by
        d.file_name_clean
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
    tp.topic Topic,
    coalesce(pvf.page_views, pv.page_views) [Page views (pages downloadable from)],
    d.downloads Downloads,
    cast(d.downloads as float) / nullif(coalesce(pvf.page_views, pv.page_views), 0) [Download rate (pages downloadable from)]
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
    inner join page_views_agg pv on
        p.url = pv.url
    left join page_views_agg_files pvf on
        f.file_name_clean = pvf.file_name_clean
    left join downloads_agg d on
        f.file_name_clean = d.file_name_clean
where
    (p.content_type = 'Publication' or (
        f.first_download_date <= ? and f.last_download_date >= ?
    ))
