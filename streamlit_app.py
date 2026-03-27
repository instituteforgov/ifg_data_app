import argparse

import streamlit as st
import ifg_data_app.pages.dashboard.web_metrics.config as config


def parse_redact_data_config():
    """Parse redact data configuration from command line arguments"""
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--redact-data", action="store_true", help="Enable redact data mode")

    args, _ = parser.parse_known_args()

    return args.redact_data


# Parse and set redact data configuration
REDACT_DATA = parse_redact_data_config()

# Update config module with parsed values
config.REDACT_DATA = REDACT_DATA

st.set_page_config(
    layout="wide",
    initial_sidebar_state="expanded",
)

if not st.user.is_logged_in:
    st.header("Please log in to access this page")
    st.button("Log in", on_click=st.login)
    st.stop()

st.sidebar.button("Log out", type="tertiary", on_click=st.logout)

pg = st.navigation(
    {
        "Analytics dashboard": [
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/home.py",
                title="Home",
                url_path="/web_metrics_home",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/summary.py",
                title="Summary",
                url_path="/web_metrics_summary",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/files.py",
                title="Files (e.g. PDFs)",
                url_path="/web_metrics_files",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/file_detail.py",
                title="File detail",
                url_path="/web_metrics_file_detail",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/pages.py",
                title="Pages",
                url_path="/web_metrics_pages",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/page_detail.py",
                title="Page detail",
                url_path="/web_metrics_page_detail",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/roadmap.py",
                title="Roadmap",
                url_path="/web_metrics_roadmap",
            ),
            st.Page(
                "ifg_data_app/pages/dashboard/web_metrics/pages/help.py",
                title="Help",
                url_path="/web_metrics_help",
            ),
        ],
    },
)

# APPLY CUSTOM CSS
# Hide pages in sidebar
st.markdown(
    """
        <style>
            a[href$="web_metrics_summary"] {
                display: none;
            }
        </style>
        <style>
            a[href$="web_metrics_page_detail"] {
                display: none;
            }
        </style>
        <style>
            a[href$="web_metrics_file_detail"] {
                display: none;
            }
        </style>
        <style>
            a[href$="web_metrics_files"],
            a[href$="web_metrics_pages"] {
                padding-left: 1.25rem;
            }
        </style>
    """,
    unsafe_allow_html=True
)


# RUN PAGE
pg.run()
