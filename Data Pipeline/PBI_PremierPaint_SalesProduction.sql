/*
This logic constructs a denormalized, tabular view of PP's paint sales and production
data from [LatexStar2].[POS] for use in a Microsoft Power BI (PBI) dashboard.

Plan

A. Extract sales quantities (Source: POS, grain = daily)
Convert all non-gallon unit sizes (i.e. quarts, pints, etc.) to gallons

B. Extract retail production quantities (Source: POS, grain = daily)
Convert all non-gallon unit sizes to gallons
*/
WITH UsefulData AS
(
    SELECT -- Sales
        CONVERT( DATE, LEFT( sales.[ORIG_SALES_DATE], 10) ) AS [Date],
        'Sales' AS [Type],
        CASE
            WHEN TRIM(sales.COLOR) = '' THEN 'Unknown'
            ELSE TRIM(sales.COLOR)
        END AS Color,
        CASE
            WHEN sales.RECEIPT_ID IN ('RC00001000011377', 'RC00001000012756') THEN 260 * sales.SHIP_QTY
            WHEN (sales.SIZE_TYPE LIKE '%qt%' OR sales.SIZE_TYPE LIKE '%quart%') THEN ( TRY_CONVERT(decimal, sales.SIZE_QT) / 4 ) * sales.SHIP_QTY
            WHEN sales.SIZE_TYPE LIKE '%pt%' THEN ( TRY_CONVERT(decimal, sales.SIZE_QT) / 16 ) * sales.SHIP_QTY
            WHEN sales.SIZE_TYPE LIKE '%N/A%' THEN 5 * sales.SHIP_QTY
            ELSE TRY_CONVERT(decimal,sales.SIZE_QT) * sales.SHIP_QTY
        END AS Amount

        FROM
        [RC-DW-PES].[dbo].[LATEXSTAR2_RECEIPT_LINE_NEW] sales

        WHERE
        sales.DEPARTMENT LIKE '%PAINT%'
        AND CONVERT( DATE, LEFT( sales.ORIG_SALES_DATE, 10) ) >= '2012-07-01'

    UNION SELECT -- Production
        CONVERT( DATE, LEFT( production.DATE_RECEIVED, 10) ) AS [Date],
        'Production' AS [Type],
        CASE
            WHEN TRIM(production.COLOR) IS NULL THEN 'Unknown'
            ELSE TRIM(production.COLOR)
        END AS Color,
        CASE
            WHEN production.SIZES_TYPE LIKE '%qt%' OR production.SIZES_TYPE LIKE '%quart%' THEN ( TRY_CONVERT(decimal, production.SIZES_QT) / 4 ) * production.QTY
            WHEN production.SIZES_TYPE LIKE '%N/A%' THEN 5 * production.QTY
            ELSE TRY_CONVERT (decimal, production.SIZES_QT) * production.QTY 
        END AS Amount

        FROM
        [RC-DW-PES].[dbo].[LATEXSTAR2_PURCH_RCV_NEW] production

        WHERE
        production.DEPARTMENT LIKE '%PAINT%'
        AND CONVERT( DATE, LEFT( production.DATE_RECEIVED, 10) ) >= '2012-07-01'
)

-- Summarize into a tabular view, stub-out color for use in dashboard later as a product dimension
SELECT
    [Date],
    [Type] AS Series,
    --[Color] AS Product,
    'Retail' AS SeriesCategory,
    'Gallons' AS SeriesUnits,
    'Actuals' AS SeriesType,
    SUM ( [Amount] ) AS [Value]

FROM
UsefulData

GROUP BY
    [Date],
    [Type]