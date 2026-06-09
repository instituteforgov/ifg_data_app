### v1.2.2 - Tu 2 June 2026
🪰 **DATA: Bugfix: Home page being reported as an explainer**

### v1.2.1 - Wed 11 Mar 2026
🪳 **DATA: Bugfix: In rare cases publications weren't eligible to appear in home page**\
Publications where the file name contained the string 'briefing' were erroneously excluded

### v1.2.0 - Fri 6 Feb 2026
📈 **DATA: Factor in redirects**\
Where a page has changed URL, merge traffic and download figures and report against the new URL

### v1.1.2 - Tu 27 Jan 2026
📈 **UI: Bugfix: Last two day's data always shown as provisional**\
This applied even where a custom range was applied, covering non-recent dates

### v1.1.1 - Wed 17 December 2025
🦟 **DATA: Bugfix: Strip out small number of publications that appeared twice**\
This affected ~30 publications where the file had been updated and the update was in a different month to the original upload

### v1.1.0 - Fri 21 November 2025
🖊️ **UI: Bring live blogs into the Home page**

### v1.0.2 - Thur 4 September 2025
🐛 **DATA: Bugfix: Metrics for Whitehall Monitor 2025 and Performance Tracker 2023 were overstated**\
A bug relating to file extensions led to overstatement for these two publications

### v1.0.1 - Fri 15 August 2025
🐛 **DATA: Bugfix: Certain comment pieces and explainers weren't eligible for inclusion in the Home page**\
Fix makes those deleted or changed to a new URL eligible for inclusion

📆 **UI: Restructure Roadmap**

### v1.0.0 - Mon 21 July 2025
🚀 **Launch**

### v0.8.0 - Mon 21 July 2025
❔ **UI: Update FAQs description of downloads**

### v0.7.0 - Fri 18 July 2025
❓ **UI: Add more questions to 'Help' page**

🪟 **UI: Set sidebar to always start expanded**

🎤 **UI: Clarify chart titles and add note on filtering**

✖️ **UI: Merge 'Publication downloads' and 'Publication page views' tables on 'Home' page**

🔄️ **UI: Reorder pages in sidebar**

📄 **UI: Add details of all pages a publication is downloadable from to 'Publication details' page**

🧹 **UI: Remove unused 'Publication details' and 'Page details' tabs ('Traffic sources', 'Search term')**

🐞 **DATA: Bugfix: Strip out duplicate page views for pages with 2+ downloadable files**

🅰️ **UI: Drop font size**

💁 **UI: Add definitions to 'Help' page**

### v0.6.0 - Wed 16 July 2025
📝 **UI: Clarify 'Page detail', 'Publication detail' page titles**

🪲 **UI: Bugfix: zeroes not shown in line charts**

🚦 **UI: Add info box where line chart has n/a values**

### v0.5.0 - Tu 15 July 2025
💁 **UI: Add help button explaining minimum date in date range selectors**

⚠️ **UI: Implement range highlights and annotations on line charts**

🖊️ **UI: Change chart fonts to Aller/Aller Light**

🖇️ **UI: Turn 'Page title' columns in 'Home' page into links**

📰 **UI: Add 'Publication detail' page**

📛 **UI: Rename 'Output title' column 'Publication title' in 'Publications' page**

📅 **UI: Retain selected date range when changing pages**

### v0.4.0 - Mon 14 July 2025
🐜 **DATA: Bugfix that meant some pages showed with a missing page title**

📉 **UI: Bugfixes in 'Page detail' page line charts**\
Ensures axis ranges are always fixed and only data for the last 48 hours is marked as provisional

### v0.3.0 - Fri 11 July 2025
💻 **UI: Add extra rule to hide sidebar button on 'Page detail' page**

💄 **UI: Improve presentation of 'Page detail' page**

📦 **UI: Enable exports from tables**\
Right-clicking allows copying and export to Excel/CSV

📃 **UI: Show Excel-style lists when filtering tables**

ℹ️ **UI: Add note on event data limitations and add future possibilities to Roadmap**

⁉️ **UI: Add details of how to provide feedback to FAQs**

🏛️ **UI: Disable sorting, filtering, reordering columns and locking columns in 'Home' page tables**

🪧 **UI: Clarify scope selection wording on 'Home' page**

✒️ **UI: Rename 'Confirmed' to 'Final' in chart tooltips**

🔤 **UI: Improve sidebar naming ("Web traffic" to "Analytics dashboard")**

📊 **UI: Add chart titles**

🅰️ **UI: Rename 'File extension' column to 'File type'**

🔢 **DATA: Improve identification of publication titles in 'Home', 'Publications' pages**\
Outputs are now given the name of the page from which most downloads have occurred

🐛 **DATA: Bugfix that meant certain links to publication files were broken**

✏️ **UI: Change wording from 'outputs' to 'publications' throughout dashboard**

### v0.2.0 - Wed 9 July 2025
➡️ **UI: Improve allocation of historic content to teams**

⏰ **UI: Add badges giving latest update dates**

📲 **UI: Set sidebar initial state to open except on small devices**

©️ **DATA: Deduplicate outputs**\
Remove '_1', '_v1' etc. from publication filenames

🗃️ **UI: Display publication filenames in 'Home', 'Publications' pages**\
Allowing related files (e.g. main publication and briefing document) to be distinguished

### v0.1.0 - Tu 8 July 2025
🗓️ **UI: Fix filtering on ‘Published date’, ‘Updated date’ columns in ‘Pages’, ‘Publications’ pages**

♟️ **UI: Split ‘Other’ and ‘Unclassified’ out as separate content types**

📖 **UI: Change ‘Publication type’ n/a values to blanks**

📂 **DATA: Restrict what counts as a download**\
Exclude things that don't have a Google Analytics `eventName` of ‘file_download’ or that don't follow an IfG web address format
