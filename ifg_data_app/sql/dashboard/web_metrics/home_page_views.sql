-- Uses a CTE on page views for efficiency
-- Applies an is_html_report filter for publications to exclude pages that only exist as PDFs
-- date filtering uses between rather than isnull() to enable index seeks; between still excludes nulls (null between x and y evaluates to false)
-- NB: This could be written using corporate.page_views_canonical as the base table and only calculating aggregate page views for the top 10 pages of each content type, but is done this way for greater readability
with page_views_agg as (
    select
        pv.url,
        sum(pv.page_views) page_views
    from corporate.page_views_canonical pv
    where
        pv.date between ? and ?
    group by
        pv.url
)
select top 10
    p.page_title [Page title],
    p.url Link,
    pv.page_views [Page views]
from corporate.pages p
    inner join page_views_agg pv on
        p.url = pv.url
where
    p.content_type = ? and
    (p.content_type <> 'Publication' or p.is_html_report = 1) and
    (
        p.published_date between ? and ? or
        p.updated_date between ? and ?
    )
order by
    pv.page_views desc
