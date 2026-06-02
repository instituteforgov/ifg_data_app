select
    pv.date Date,
    p.page_title [Page title],
    pv.url Link,
    p.content_type [Content type],
    p.publication_type [Publication type],
    p.published_date [Published date],
    year(p.published_date) [Published date: year],
    month(p.published_date) [Published date: month],
    day(p.published_date) [Published date: day],
    p.updated_date [Updated date],
    year(p.updated_date) [Updated date: year],
    month(p.updated_date) [Updated date: month],
    day(p.updated_date) [Updated date: day],
    t.team Team,
    a.author Author,
    tp.topic Topic,
    pv.page_views [Page views],
    pv.active_users [Active users],
    pv.user_engagement_duration [User engagement duration],
    dc.downloads Downloads
from corporate.page_views_canonical pv
    left join corporate.downloads_canonical dc on
        pv.url = dc.url and
        pv.date = dc.date
    left join corporate.pages p on
        pv.url = p.url
    left join corporate.content_teams_canonical t on
        p.url = t.url
    left join corporate.content_topics_canonical tp on
        p.url = tp.url
    left join corporate.content_authors_canonical a on
        p.url = a.url
where
    pv.date between ? and ?;
