-- Unit of analysis: Unique page x date combinations
select
    pv.date Date,
    pt.page_title [Page title],
    pv.url Link,
    bm.content_type [Content type],
    bm.publication_type [Publication type],
    bm.published_date [Published date],
    bm.updated_date [Updated date],
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
    outer apply (       -- Attach teams. 1:1 following application of aggregation
        select
            string_agg(t.team, ', ') team
        from corporate.content_teams_canonical t
        where
            bm.url = t.url
        group by
            t.url
    ) t
    outer apply (       -- Attach topics. 1:1 following application of aggregation
        select
            string_agg(p.topic, ', ') topic
        from corporate.content_topics_canonical p
        where
            bm.url = p.url
        group by
            p.url
    ) p
    outer apply (       -- Attach authors. 1:1 following application of aggregation
        select
            string_agg(a.author, ', ') author
        from corporate.content_authors_canonical a
        where
            bm.url = a.url
        group by
            a.url
    ) a
    left join corporate.page_views_canonical pv on      -- Attach page views. 1:1
        bm.url = pv.url
    outer apply (       -- Attach downloads. 1:1 following application of aggregation (1:n before this as there can be multiple files downloadable from a single URL)
        select
            dc.date,
            sum(dc.event_count) event_count
        from corporate.downloads_canonical dc
        where
            pv.url = dc.url and
            pv.date = dc.date
        group by
            dc.date
    ) dc
where
    pt.page_title is not null and
    pv.date between '1900-01-01' and '9999-12-31';
