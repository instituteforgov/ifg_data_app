select
    pv.date Date,
    pt.page_title [Page title],
    pv.url Link,
    bm.content_type [Content type],
    bm.publication_type [Publication type],
    bm.published_date [Published date],
    year(bm.published_date) [Published date: year],
    month(bm.published_date) [Published date: month],
    day(bm.published_date) [Published date: day],
    bm.updated_date [Updated date],
    year(bm.updated_date) [Updated date: year],
    month(bm.updated_date) [Updated date: month],
    day(bm.updated_date) [Updated date: day],
    t.team Team,
    a.author Author,
    p.topic Topic,
    pv.page_views [Page views],
    pv.active_users [Active users],
    pv.user_engagement_duration [User engagement duration],
    dc.event_count Downloads
from corporate.content_basic_metadata_canonical bm      -- Start with a page and build from there
    left join corporate.content_page_titles_canonical pt on     -- Attach page title. 1:1
        bm.url = pt.url
    left join corporate.content_teams_canonical t on       -- Attach teams. 1:n
        bm.url = t.url
    left join corporate.content_topics_canonical p on       -- Attach topics. 1:n
        bm.url = p.url
    left join corporate.content_authors_canonical a on       -- Attach authors. 1:n
        bm.url = a.url
    left join corporate.page_views_canonical pv on       -- Attach page views. 1:1
        bm.url = pv.url
    left join corporate.downloads_canonical dc on       -- Attach downloads. 1:n
        bm.url = dc.url and
        pv.date = dc.date
where
    pv.date between '1900-01-01' and '9999-12-31';
