import os

import pandas as pd
import streamlit as st
from st_aggrid import AgGrid, JsCode, StAggridTheme

from ifg_data_app.config.ag_grid_theme import AG_GRID_THEME_BASE, AG_GRID_THEME_DEFAULTS
import ifg_data_app.pages.dashboard.web_metrics.config as config
from ifg_data_app.pages.dashboard.web_metrics.notes import NOTES
import ifg_data_app.pages.dashboard.web_metrics.elements as elements
from ifg_data_app.pages.dashboard.web_metrics.utils import set_metrics

# SET METRIC TYPE
METRIC_TYPE = "download"
(
    METRICS_RAW, METRICS_DISPLAY, METRIC_AGGREGATIONS, METRIC_CALCULATIONS, DEFAULT_METRIC
) = set_metrics(METRIC_TYPE)

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
st.title("Files")
elements.draw_latest_data_badge(df_date_range["max_date"][0])
st.markdown("\n\n")
st.markdown("\n\n")

# DRAW DATE RANGE INPUTS
date_range_option, start_date, end_date = elements.draw_date_range_inputs(
    min_date=df_date_range["min_date"][0],
    max_date=df_date_range["max_date"][0],
)

# LOAD PAGE DATA
with open("ifg_data_app/sql/dashboard/web_metrics/files.sql", "r") as file:
    script = file.read()

script_by_day = script.split(";")[0]
df_by_day = elements.load_data(
    script_by_day,
    connection,
    (
        start_date, end_date,  # page_views_agg
        start_date, end_date, end_date, start_date,  # page_views_agg_files
        start_date, end_date,  # downloads_agg
    ),
)

script_by_file = script.split(";")[1]
df_by_file = elements.load_data(
    script_by_file,
    connection,
    (
        start_date, end_date,  # page_views_agg
        start_date, end_date, end_date, start_date,  # page_views_agg_files
        start_date, end_date,  # downloads_agg
        end_date, start_date,  # where clause
    ),
)

# EDIT DATA
df_by_day = elements.fill_missing_dates(df_by_day, start_date, end_date, "Date", METRICS_RAW)

df_by_file = df_by_file[config.METRICS_FILES + list(METRICS_DISPLAY.keys())]

# Convert dates
for date_col in ["Published date", "Updated date"]:
    df_by_file[date_col] = df_by_file[date_col].apply(
        lambda x: pd.to_datetime(x, errors="coerce") if x != "" else ""
    )

# DRAW LINE CHART SECTION
selected_metric = elements.draw_line_chart_section(
    df=df_by_day,
    x="Date",
    start_date=start_date,
    end_date=end_date,
    metrics=list(METRICS_DISPLAY.keys()),
    default_metric=DEFAULT_METRIC,
    content_type="files",
    redact_data=config.REDACT_DATA,
)

# DRAW TABLE
column_defs, grid_options = elements.set_table_defaults(
    df=df_by_file,
    metrics=METRICS_DISPLAY,
    sort_columns=DEFAULT_METRIC,
    sort_order={
        DEFAULT_METRIC: "desc",
        "Published date": "desc",
        "Updated date": "desc"
    },
    pin_columns=["File title"],
)

column_defs = elements.create_internal_link(
    column_defs,
    "File title",
    page_type="file",
)
column_defs = elements.create_external_link(
    column_defs,
    "Link",
    "View file ⮺"
)
column_defs = elements.format_date_cols(
    column_defs,
    ["Published date", "Updated date"]
)

# Apply formatting to metric columns
if config.REDACT_DATA:
    for metric in METRICS_DISPLAY:
        column_defs[metric]["valueFormatter"] = JsCode("function(params) {return 'xxxxx';}")
else:
    for metric, formatter in METRICS_DISPLAY.items():
        column_defs[metric]["valueFormatter"] = formatter

AgGrid(
    df_by_file,
    key="ag",
    license_key=os.environ["AG_GRID_LICENCE_KEY"],
    enable_enterprise_modules="enterpriseOnly",
    update_on=[],
    gridOptions=grid_options,
    allow_unsafe_jscode=True,
    theme=StAggridTheme(base=AG_GRID_THEME_BASE).withParams(**AG_GRID_THEME_DEFAULTS),
    height=elements.calculate_ag_grid_height(len(df_by_file)),
)

st.warning(NOTES["downloads_note"]["text"])
