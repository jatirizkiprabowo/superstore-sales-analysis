# Superstore Sales Analysis (2014-2017)

**Tools:** MySQL, Microsoft Excel (SUMIFS, formulas, charts)
**Data:** Public "Superstore" sample dataset, 9,994 order lines, 793 customers, Jan 2014 - Dec 2017. This is a fictional company used for learning, not real business data.

## Business questions
1. How are sales and profit changing over time?
2. Which product categories and sub-categories make or lose money?
3. Where do discounts help, and where do they hurt?
4. Which regions and states underperform?
5. Who are the top customers, and are they profitable?

## Data preparation
- Checked for missing values and duplicate rows: none found (9,994 unique row IDs).
- Converted dates from M/D/YYYY text to proper dates.
- Restored postal codes to 5 digits (leading zeros were lost in the source file).
- Split customer info into a separate `customers` table to practice `JOIN`.
- Added helper columns in Excel: year, month, days to ship, discount band.

## Key findings
| # | Finding | Evidence |
|---|---------|----------|
| 1 | Sales grew strongly, and margin improved | Sales rose from $484K (2014) to $733K (2017). Profit margin moved from 10.2% to 12.7%. |
| 2 | Furniture is the weak spot | Furniture margin is 2.5%, versus 17.4% for Technology and 17.0% for Office Supplies. Tables (-$17.7K) and Bookcases (-$3.5K) lose money overall. |
| 3 | Heavy discounts are linked to losses | Lines with no discount have a 29.5% margin. Lines discounted over 40% have a -77.4% margin. Lines discounted over 20% (1,393 lines) lost $135K in total. |
| 4 | Loss-making lines are a big drag | 1,871 lines (18.7%) lost $156K in total. |
| 5 | Central region and four states underperform | Central margin is 7.9% (West: 14.9%). Texas, Ohio, Pennsylvania and Illinois are all loss-making. Their average discounts are 32-39%, versus 7% in California. |
| 6 | Tables lose money only when heavily discounted | Table lines discounted over 20% lost $30.7K. Table lines at 20% or less earned $13.0K. |
| 7 | Sales are seasonal | September, November and December are the strongest months in every year. |
| 8 | The biggest customer is not profitable | Sean Miller has the highest sales ($25.0K) but a loss of $2.0K. |

## Recommendations
These are suggestions based on patterns in this dataset. They show association, not proven cause.
1. **Review the discount policy**, especially discounts above 20%. Test a cap and measure the effect on profit.
2. **Re-price or reduce discounts on Tables and Bookcases**, and review the supplier cost of Furniture.
3. **Look into the Central region and the four loss-making states.** Discounting looks like a common factor, but local costs should also be checked.
4. **Plan stock and marketing around the September to December peak.**
5. **Review the terms of high-sales, low-profit customers** such as the top customer.

## Limitations
- The company is fictional, so findings show analysis method, not real business facts.
- Cost data is not included, so we can see profit but not why costs are high.
- Discount bands are my own grouping, and different cut-offs could change the details.

## Files
| File | Description |
|------|-------------|
| `Superstore_Sales_Analysis.xlsx` | Data sheet plus summary tables and charts, all built with formulas |
| `superstore_analysis.sql` | MySQL script: table setup, data checks, and 20+ analysis queries |
| `sales_clean.csv`, `customers_clean.csv` | Cleaned data ready to import into MySQL |

## SQL skills shown
`SELECT`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `JOIN`, `UNION`, `CASE WHEN`, aggregate functions, string and date functions, data quality checks.
