/*
This logic creates or alters a view of Paint financials data from various source
systems in the data warehouse for downstream Power BI analysis

Plan: 

A. Extract expense data (Source: central finance database)
    1. Materials and Services (grain = monthly)
    2. Personnel Services (grain = monthly)

B. Extract revenue data
    1. Source 1 (Source: central finance database; grain = monthly)
    2. Source 2 (Source: point of sale system; grain = daily)
    3. Source 3 (Source: point of sale system; grain = daily)
*/
-----------------------------------------------------------------------------------
---------------------------------A. Expenses---------------------------------------
-----------------------------------------------------------------------------------
SELECT
    DATEFROMPARTS(
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN budget_year - 1
            ELSE budget_year
        END,
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN  6 + tb_fiscper
            ELSE (6 + tb_fiscper) - 12
        END, 
    1) AS [Date],
    glcatname AS Series, 
    'Expenses' AS SeriesCategory,
    'USD' AS SeriesUnits,
    'Actuals' AS SeriesType,
    SUM(month_actual) AS [Value]

    FROM 
    [RC-DW-PES].[dbo].[M_WPES_ActualsReport]

    WHERE
    costctr_name IN ('Redacted', 'Redacted')
    AND acct_type = 'Expenses'
    AND glcatname IN ('Materials and Services', 'Personnel Services')

    GROUP BY
    DATEFROMPARTS(
    CASE
        WHEN tb_fiscper BETWEEN 1 and 6 THEN budget_year - 1
        ELSE budget_year
    END,
    CASE
        WHEN tb_fiscper BETWEEN 1 and 6 THEN  6 + tb_fiscper
        ELSE (6 + tb_fiscper) - 12
    END, 
    1),
    glcatname
----------------------------------------------------------------------------------
-------------------------------B1. Source 1----------------------------
----------------------------------------------------------------------------------
UNION ALL SELECT
    DATEFROMPARTS(
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN budget_year - 1
            ELSE budget_year
        END,
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN  6 + tb_fiscper
            ELSE (6 + tb_fiscper) - 12
        END,
    1) AS [Date],
    glacctname AS Series,
    'Revenue' AS SeriesCategory,
    'USD' AS SeriesUnits,
    'Actuals' AS SeriesType,
    SUM(month_actual) AS [Value]

    FROM
    [RC-DW-PES].[dbo].[M_WPES_ActualsReport]

    WHERE
    costctr_name IN ('Redacted', 'Redacted')
    AND acct_type = 'Revenue'
    AND glacctname = 'Source 1'

    GROUP BY
    DATEFROMPARTS(
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN budget_year - 1
            ELSE budget_year
        END,
        CASE
            WHEN tb_fiscper BETWEEN 1 and 6 THEN  6 + tb_fiscper
            ELSE (6 + tb_fiscper) - 12
        END,
    1),
    glacctname
----------------------------------------------------------------------------------
---------------------------B2, B3. Store sales Revenue----------------------------
----------------------------------------------------------------------------------
UNION ALL SELECT
    CONVERT(DATE, LEFT(sales.[ORIG_SALES_DATE], 10)) AS [Date],
    CASE 
        WHEN sales.[STORE] = 1 THEN 'Source 2'
        ELSE 'Source 3' 
    END AS Series,
    'Revenue' AS SeriesCategory,
    'USD' AS SeriesUnits,
    'Actuals' AS SeriesType,
    SUM(sales.[SHIP_QTY] * sales.[SELLING_PRICE]) AS [Value]

    FROM
    [RC-DW-PES].[dbo].[LATEXSTAR2_RECEIPT_LINE_NEW] sales

    WHERE
    sales.DEPARTMENT LIKE '%PAINT%'
    AND CONVERT( DATE, LEFT( sales.ORIG_SALES_DATE, 10) ) >= '2012-07-01'

    GROUP BY
    CONVERT(DATE, LEFT(sales.[ORIG_SALES_DATE], 10)),
    CASE 
        WHEN sales.[STORE] = 1 THEN 'Source 2'
        ELSE 'Source 3' 
    END