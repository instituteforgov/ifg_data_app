-- Uses two CTEs on page views and one downloads for efficiency
-- Applies a date restriction on corporate.files in the creation of page_views_agg_files to only pull page views from pages from which the file has been downloaded in the target period
-- NB: This could be written using corporate.page_views_canonical or corporate.downloads_canonical as the base table and only calculating aggregate page views/downloads for the top 10 publications, but is done this way for greater readability
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
select top 10
    p.page_title [Publication title],
    f.file_name_clean [File name],
    f.file_path_latest [Link],
    coalesce(pvf.page_views, pv.page_views) [Page views (pages downloadable from)],
    d.downloads Downloads,
    cast(d.downloads as float) / nullif(coalesce(pvf.page_views, pv.page_views), 0) [Download rate (pages downloadable from)]
from corporate.pages p
    inner join corporate.files f on
        p.url = f.url and
        f.is_url_most_common = 1
    inner join page_views_agg pv on
        p.url = pv.url
    inner join page_views_agg_files pvf on
        f.file_name_clean = pvf.file_name_clean
    inner join downloads_agg d on
        f.file_name_clean = d.file_name_clean
where
    p.content_type = 'Publication' and
    p.has_pdf = 1 and
    (
        p.published_date between ? and ? or
        p.updated_date between ? and ?
    )
order by
    d.downloads desc
