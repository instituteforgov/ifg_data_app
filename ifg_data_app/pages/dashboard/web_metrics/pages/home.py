import os

import streamlit as st
from st_aggrid import AgGrid, JsCode, StAggridTheme

from ifg_data_app.config.ag_grid_theme import AG_GRID_THEME_BASE, AG_GRID_THEME_DEFAULTS
import ifg_data_app.pages.dashboard.web_metrics.config as config
import ifg_data_app.pages.dashboard.web_metrics.elements as elements
from ifg_data_app.pages.dashboard.web_metrics.notes import NOTES
from ifg_data_app.pages.dashboard.web_metrics.utils import format_integer, format_percentage

# SET CONSTANTS
TABLE_CONFIG = [
    {
        "section_header": "Publications",
        "title": "Downloads",
        "title_as_subheader": True,
        "description": "Publications available as PDFs. Page views are aggregated across all pages the PDF is downloadable from",
        "content_type": "Publication",
        "sql_script": "ifg_data_app/sql/dashboard/web_metrics/home_downloads.sql",
        "metrics": {
            "Page views (pages downloadable from)": format_integer,
            "Downloads": format_integer,
            "Download rate (pages downloadable from)": format_percentage,
        },
        "title_column": "Publication title",
        "internal_link_type": "file",
        "external_link_column": "Link",
        "external_link_text": "View pub... ⮺",
        "notes": [NOTES["downloads_note"]],
    },
    {
        "title": "Page views",
        "title_as_subheader": True,
        "description": "Publications available in HTML form. Page views are disaggregated by page",
        "content_type": "Publication",
        "sql_script": "ifg_data_app/sql/dashboard/web_metrics/home_page_views.sql",
        "metrics": {"Page views": format_integer},
        "title_column": "Page title",
        "internal_link_type": "page",
        "external_link_column": "Link",
        "external_link_text": "View page ⮺",
    },
    {
        "title": "Comment and live blog page views",
        "content_type": ("Comment", "Live blog"),
        "sql_script": "ifg_data_app/sql/dashboard/web_metrics/home_page_views.sql",
        "metrics": {"Page views": format_integer},
        "title_column": "Page title",
        "internal_link_type": "page",
        "external_link_column": "Link",
        "external_link_text": "View page ⮺",
        "notes": [NOTES["comment_live_blog_page_views_note"]],
    },
    {
        "title": "Explainer page views",
        "content_type": "Explainer",
        "sql_script": "ifg_data_app/sql/dashboard/web_metrics/home_page_views.sql",
        "metrics": {"Page views": format_integer},
        "title_column": "Page title",
        "internal_link_type": "page",
        "external_link_column": "Link",
        "external_link_text": "View page ⮺",
    },
    {
        "title": "Event page views",
        "content_type": "Event",
        "sql_script": "ifg_data_app/sql/dashboard/web_metrics/home_page_views.sql",
        "metrics": {"Page views": format_integer},
        "title_column": "Page title",
        "internal_link_type": "page",
        "external_link_column": "Link",
        "external_link_text": "View page ⮺",
    },
]

# CONNECT TO DATABASE
connection = elements.connect_database()

# LOAD DATE RANGE DATA
with open("ifg_data_app/sql/dashboard/web_metrics/date_range.sql", "r") as file:
    script_date_range = file.read()

df_date_range = elements.load_data(
    script_date_range,
    connection,
)

# DRAW PAGE HEADER
if config.REDACT_DATA:
    elements.draw_redact_data_warning()
st.title("Home")
elements.draw_latest_data_badge(df_date_range["max_date"][0])
st.markdown("\n\n")
st.markdown("\n\n")

# DRAW DATE RANGE INPUTS
_, start_date, end_date = elements.draw_date_range_inputs(
    min_date=df_date_range["min_date"][0],
    max_date=df_date_range["max_date"][0],
)

# # DRAW PAGE FILTER INPUT
col1, _ = st.columns([1, 5])

with col1:
    page_filter = st.selectbox(
        label="Choose scope",
        options=["All content", "New/updated content"],
        index=0,
        help="Select whether to include all content or only that published or updated during the selected date range.",
        key="page_filter",
    )


def create_table(table_config, page_filter, start_date, end_date, connection):
    """Create a single table with all the necessary data loading and configuration."""

    # LOAD PAGE DATA
    with open(f"{table_config['sql_script']}", "r") as file:
        script = file.read()

    # Determine parameters based on page filter
    if page_filter == "All content":
        published_start_date = config.SQL_EARLIEST_DATE
        published_end_date = config.SQL_LATEST_DATE
    elif page_filter == "New/updated content":
        published_start_date = start_date
        published_end_date = end_date

    if table_config.get("title") == "Downloads":
        df = elements.load_data(
            script,
            connection,
            (start_date, end_date, start_date, end_date, end_date, start_date, start_date, end_date, published_start_date, published_end_date, published_start_date, published_end_date),
        )
    else:
        # Handle multiple content types by modifying SQL dynamically
        content_type = table_config["content_type"]
        if isinstance(content_type, tuple) and len(content_type) > 1:
            placeholders = ", ".join(["?" for _ in content_type])
            script = script.replace("p.content_type = ?", f"p.content_type in ({placeholders})")
            content_type_params = content_type
        else:
            content_type_params = content_type[0] if isinstance(content_type, tuple) else content_type

        if isinstance(content_type_params, tuple):
            df = elements.load_data(
                script,
                connection,
                (start_date, end_date, *content_type_params, published_start_date, published_end_date, published_start_date, published_end_date),
            )
        else:
            df = elements.load_data(
                script,
                connection,
                (start_date, end_date, content_type_params, published_start_date, published_end_date, published_start_date, published_end_date),
            )

    # DRAW TABLE
    column_defs, grid_options = elements.set_table_defaults(
        df=df,
        metrics=table_config["metrics"],
        sortable=False,
        sort_columns="index",
        sort_order="asc",
        filter=False,
        lockPinned=True,
    )

    # Remove autoSizeStrategy set by GridOptionsBuilder so that flex column widths are honoured
    grid_options.pop("autoSizeStrategy", None)

    column_defs = elements.create_internal_link(
        column_defs,
        table_config["title_column"],
        page_type=table_config["internal_link_type"],
    )

    column_defs = elements.create_external_link(
        column_defs,
        table_config["external_link_column"],
        table_config["external_link_text"]
    )

    # For publication downloads, override the title renderer to append the file name as plain text
    if table_config.get("internal_link_type") == "file":
        column_defs = elements.create_internal_link_with_suffix(
            column_defs,
            "Publication title",
            page_type="file",
            suffix_column="File name",
        )
        column_defs["File name"]["hide"] = True

    # Apply formatting to metric columns
    if config.REDACT_DATA:
        for metric in table_config["metrics"]:
            column_defs[metric]["valueFormatter"] = JsCode("function(params) {return 'xxxxx';}")
    else:
        for metric, formatter in table_config["metrics"].items():
            column_defs[metric]["valueFormatter"] = formatter

    # Set proportional column widths using flex (minWidth sets pixel floor)
    column_defs[table_config["title_column"]]["flex"] = 3
    column_defs[table_config["title_column"]]["minWidth"] = 200
    column_defs[table_config["external_link_column"]]["flex"] = 1
    column_defs[table_config["external_link_column"]]["minWidth"] = 100

    # Set proportional width for metric columns
    for metric in table_config["metrics"]:
        column_defs[metric]["flex"] = 1
        column_defs[metric]["minWidth"] = 100

    # Disable pagination
    grid_options["pagination"] = True
    grid_options["paginationPageSize"] = 10
    grid_options["suppressPaginationPanel"] = True

    # Prevent column reordering
    grid_options["suppressMovableColumns"] = True

    # Add row numbers to show index
    grid_options["rowClassRules"] = {
        "row-index": "true"
    }

    # Add index column that updates after sorting
    index_column = {
        "headerName": "#",
        "field": "index",
        "valueGetter": "node.rowIndex + 1",
        "width": 47.5,
        "pinned": "left",
        "suppressMenu": True,
        "sortable": False,
        "cellClass": "text-center"
    }
    grid_options["columnDefs"].insert(0, index_column)

    for col in column_defs.values():
        col["filter"] = False

    # Create theme with background color if specified
    theme_params = AG_GRID_THEME_DEFAULTS.copy()
    if "background_color" in table_config:
        theme_params["backgroundColor"] = table_config["background_color"]

    # Create the AgGrid table
    AgGrid(
        df,
        key=f"ag_{table_config['content_type']}_{table_config['sql_script'].replace('.sql', '')}",
        license_key=os.environ["AG_GRID_LICENCE_KEY"],
        enable_enterprise_modules="enterpriseOnly",
        gridOptions=grid_options,
        allow_unsafe_jscode=True,
        theme=StAggridTheme(base=AG_GRID_THEME_BASE).withParams(**theme_params),
        height=500,
    )

    if "notes" in table_config:
        for note in table_config["notes"]:
            if note["type"] == "warning":
                st.warning(note["text"])
            elif note["type"] == "info":
                st.info(note["text"])
            elif note["type"] == "error":
                st.error(note["text"])
            elif note["type"] == "success":
                st.success(note["text"])


for i in range(0, len(TABLE_CONFIG), 2):
    # Emit any full-width header before opening columns
    first_table = TABLE_CONFIG[i]
    if "section_header" in first_table:
        st.header(first_table["section_header"])

    columns = st.columns(2)

    # Process up to two tables in this row
    for col_idx in range(2):
        table_idx = i + col_idx
        if table_idx < len(TABLE_CONFIG):
            table_config = TABLE_CONFIG[table_idx]

            with columns[col_idx]:
                title_fn = st.subheader if table_config.get("title_as_subheader") else st.header
                title_fn(table_config["title"])
                if "description" in table_config:
                    st.write(f"_{table_config['description']}_")
                create_table(table_config, page_filter, start_date, end_date, connection)
