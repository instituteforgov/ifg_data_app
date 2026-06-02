-- AGGREGATED DATA BY DAY FOR LINE CHARTS
-- Uses a CTE on page views and downloads for efficiency
with page_views_agg as (
    select
        pv.url,
        pv.date,
        sum(pv.page_views) page_views,
        sum(pv.active_users) active_users,
        sum(pv.user_engagement_duration) user_engagement_duration
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
        dc.date,
        sum(dc.downloads) downloads
    from corporate.downloads_canonical dc
    where
        dc.date between ? and ?
    group by
        dc.url,
        dc.date
)
select
    pv.date Date,
    sum(pv.page_views) [Page views],
    sum(pv.active_users) [Active users],
    cast(sum(pv.page_views) as float) / nullif(sum(pv.active_users), 0) [Page views per active user],
    cast(sum(pv.user_engagement_duration) as float) / nullif(sum(pv.active_users), 0) [Average engagement time per active user],
    sum(dc.downloads) Downloads,
    cast(sum(dc.downloads) as float) / nullif(sum(pv.page_views), 0) [Download rate]
from corporate.pages p
    inner join page_views_agg pv on
        p.url = pv.url
    left join downloads_agg dc on
        pv.url = dc.url and
        pv.date = dc.date
where
    p.page_title is not null and
    pv.date between ? and ?
group by
    pv.date;


-- AGGREGATED DATA BY PAGE FOR DATA TABLES
-- Uses CTEs to pre-aggregate teams/topics/authors once rather than per-row
-- Uses a CTE on page views and downloads for efficiency
-- NB: Ordering is left to AGGrid
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
        sum(pv.page_views) page_views,
        sum(pv.active_users) active_users,
        sum(pv.user_engagement_duration) user_engagement_duration
    from corporate.page_views_canonical pv
    where
        pv.date between ? and ?
    group by
        pv.url
),
downloads_agg as (
    select
        dc.url,
        sum(dc.downloads) downloads
    from corporate.downloads_canonical dc
    where
        dc.date between ? and ?
    group by
        dc.url
)
select
    p.page_title [Page title],
    pv.url Link,
    p.content_type [Content type],
    p.publication_type [Publication type],
    p.published_date [Published date],
    p.updated_date [Updated date],
    t.team Team,
    a.author Author,
    tp.topic Topic,
    pv.page_views [Page views],
    pv.active_users [Active users],
    cast(pv.page_views as float) / nullif(pv.active_users, 0) [Page views per active user],
    cast(pv.user_engagement_duration as float) / nullif(pv.active_users, 0) [Average engagement time per active user],
    dc.downloads Downloads,
    cast(dc.downloads as float) / nullif(pv.page_views, 0) [Download rate]
from corporate.pages p
    left join teams_agg t on
        p.url = t.url
    left join topics_agg tp on
        p.url = tp.url
    left join authors_agg a on
        p.url = a.url
    inner join page_views_agg pv on
        p.url = pv.url
    left join downloads_agg dc on
        p.url = dc.url
where
    p.page_title is not null;
