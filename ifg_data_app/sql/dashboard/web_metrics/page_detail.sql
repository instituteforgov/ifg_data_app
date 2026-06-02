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
        tp.url,
        string_agg(tp.topic, ', ') topic
    from corporate.content_topics_canonical tp
    group by
        tp.url
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
    p.page_title [Page title],
    p.url Link,
    p.content_type [Content type],
    p.publication_type [Publication type],
    p.published_date [Published date],
    p.updated_date [Updated date],
    t.team Team,
    a.author Author,
    tp.topic Topic
from corporate.pages p
    left join teams_agg t on
        p.url = t.url
    left join topics_agg tp on
        p.url = tp.url
    left join authors_agg a on
        p.url = a.url
where
    p.url = ?;


-- METRICS
-- Uses a CTE on downloads for efficiency
-- NB: In contrast to the home_publications.sql script, this doesn't include any minimum-downloads filtering, as we want to include all downloads
with downloads_agg as (
    select
        dc.url,
        dc.date,
        sum(dc.downloads) downloads
    from corporate.downloads_canonical dc
    group by
        dc.url,
        dc.date
)
select
    pv.date Date,
    pv.page_views [Page views],
    pv.active_users [Active users],
    cast(pv.page_views as float) / nullif(pv.active_users, 0) [Page views per active user],
    cast(pv.user_engagement_duration as float) / nullif(pv.active_users, 0) [Average engagement time per active user],
    dc.downloads Downloads,
    cast(dc.downloads as float) / nullif(pv.page_views, 0) [Download rate]
from corporate.page_views_canonical pv
    left join downloads_agg dc on
        pv.url = dc.url and
        pv.date = dc.date
where
    pv.url = ? and
    pv.date between ? and ?;
