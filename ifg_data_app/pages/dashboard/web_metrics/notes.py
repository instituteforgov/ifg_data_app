from datetime import date

NOTES = {
    "line_chart_all_content_note": {
        "type": "warning",
        "text": "NB: Figures cover all {content_type} and aren't responsive to filters applied in the table below. This feature may be added in a later version - see the Roadmap for further details."
    },
    "downloads_note": {
        "type": "warning",
        "text": "NB: Downloads doesn't include instances where someone directly accesses a file via a URL. See the Help page for further details."
    },
    "comment_live_blog_page_views_note": {
        "type": "error",
        "text": "NB: Between late October 2025 and mid-May 2026, some live blogs recorded unusually high page views. As a future development we will strip this traffic out, but for now it should be disregarded.",
        "display_start": date(2025, 10, 26),
        "display_end": date(2026, 5, 19),
        "pages": {
            "/live-blog/autumn-budget-2025",
            "/live-blog/general-election-2024",
            "/live-blog/cabinet-reshuffle-november-2023",
            "/live-blog/covid-public-inquiry",
        },
    },
    "chart_blanks_note": {
        "type": "warning",
        "text": "NB: Where a metric is a rate and the denominator is zero these appear as blanks."
    },
}
