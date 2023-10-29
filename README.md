# Key Metrics Dashboard
![image](https://github.com/joelmsherman/Key-Metrics-Dashboard/blob/master/readme_image.png)

## Background
Premier Paint Llc is a leader in quality paint manufacturing in the Pacific Northwest with a growing market share of North American paint sales.  Company executives rely on timely and accurate information from finance personnel, sales managers and manufacturing staff in order to assess company financials and key performance indicators.  However, data is siloed and integrated and prepared manually by company staff, making data less useful than it could be.

## Project Objectives
The purpose of this project was to integrate and prepare data from Premier's various source systems, including it's financial database, point-of-sale (POS) system, and manufacturing database, into one semantic model linked to a dashboard.  The dashboard brings together the company's major expense and revenue metrics, sales and production data, as well as it's manufacturing "feedstock" into view for company managers to gain insights and take appropriate action.   

### Final Solution
A link to the live report is available [here](https://app.powerbi.com/view?r=eyJrIjoiZjAzNzMzNTAtMTY1My00MGZmLWE4MDgtZjM3M2IzZDYwZjY3IiwidCI6IjEwMmY4MzcyLTBlMWUtNDFhMy04ZWU4LTZhOTQ5NzAyZjcxNCJ9)

## Administration & Governance

### Workspace
My Workspace

### Distribution
Publish to web

### Sensitivity Label
Public

### Permissions
Public

## Repository Organization
The repository is organized into the following folders:

### 1. Data Pipeline
Storage of all SQL scripts governing the ETL process from source system to warehouse.

### 2. Premier Paint Metrics.Dataset
A collection of files and folders that represent a Power BI dataset. It contains some of the most important files you're likely to work on, like model.bim. To learn more about the files and subfolders and files in here, see [Project Dataset folder](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-dataset).

### 3. Premier Paint Metrics.Report
A collection of files and folders that represent a Power BI report. To learn more about the files and subfolders and files in here, see [Project report folder](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report).

### 4. .gitignore
Specifies intentionally untracked files Git should ignore. Dataset and report subfolders each have default git ignored files specified in .gitIgnore:

* Dataset
    - .pbi\localSettings.json
    - .pbi\cache.abf

* Report
    - .pbi\localSettings.json

In addition to these, all client project docs (project plans, sketches, wireframes, etc), data and ux artifacts are ignored.

### 5. Premier Paint Metrics.pbip
The PBIP file contains a pointer to a report folder, opening a PBIP opens the targeted report and model for authoring. For more information, refer to the [pbip schema document](https://github.com/microsoft/powerbi-desktop-samples/blob/main/item-schemas/common/pbip.md).