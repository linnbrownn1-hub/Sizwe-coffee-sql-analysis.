# Sizwe-coffee-sql-analysis.

SQL analysis of Sizwe Coffee using Databricks
SQL Fundamentals assignment | Witle Plus | Databricks SQL

An analysis of eight business questions from the Sizwe Coffee year-end review.

## Contents

- [Project overview](#project-overview)
- [Business questions](#business-questions)
- [Dataset and relationships](#dataset-and-relationships)
- [SQL skills demonstrated](#sql-skills-demonstrated)
- [Key findings](#key-findings)
- [Definitions and assumptions](#key-findings).
- [How to run in Databricks](#how-to-run-in-databricks)
- [Validation and limitations](#validation-and-limitations)

## Project Overview
Sizwe Coffee (Pty) Ltd is the coffee roastery and wholesale supplier described in the assignment. It is based in Isando, Johannesburg, with a second distribution centre in Epping, Cape Town. It serves approximately 1,400 business customers, including grocery chains, restaurant groups, independent cafes, hotels and offices, through Wholesale and Subscription channels.

For the financial year ended 30 June 2025, Nomsa Dlamini, Financial Director, and Bongani Twala, National Sales Manager, need evidence for their year-end review. This project uses SQL in Databricks to analyse revenue, profitability, collections, customer accounts, trade promotions and representative performance. The supplied data covers 1 July 2023 to 30 June 2025.
- FY2024: 1 July 2023 to 30 June 2024.
- FY2025: 1 July 2024 to 30 June 2025.
The scope is querying and analysis only; the queries do not change source records.

## Business Questions
| Task | Business question |
|---|---|
| 1 | How did revenue change by channel between FY2024 and FY2025? |
| 2 | Which product lines generate the most gross profit and the highest gross margin? |
| 3 | How do invoice settlement times and outstanding balances differ by channel? |
| 4 | Who are the ten largest customers by FY2025 revenue, and which representatives own their accounts? |
| 5 | Which fifteen highest-revenue Wholesale customers have never received a trade promotion? |
| 6 | How does each representative's FY2025 monthly average revenue compare with their monthly target? |
| 7 | How does monthly revenue change across the two years, and what does the rolling three-month average show? |
| 8 | How did product-line margins and revenue shares contribute to the overall margin decline? |


## Dataset and Relationships
he dataset covers 1 July 2023 to 30 June 2025.
The following tables were used in the analysis.

| Table | Rows | Description |
|---|---:|---|
| sizwe_customers | 1,400 | Customer names, channels, segments, provinces and assigned representatives |
| sizwe_products | 23 | Product codes, product lines, prices and unit costs |
| sizwe_sales_orders | 48,144 | Order dates, customers, channels and sales representatives |
| sizwe_sales_lines | 168,172 | Products ordered, quantities, revenue and cost of goods |
| sizwe_ar_ledger | 48,144 | Invoice amounts, due dates, payments and settlement dates |
| sizwe_reps | 18 | Sales representatives, territories and monthly targets |
| sizwe_trade_promotions | 640 | Promotions provided to customers for specific products |

## SQL skills demonstrated

| SQL technique | How it was used | Tasks |
|---|---|---|
| JOIN | Connected customers, orders, sales lines, products and invoices | 1–8 |
| LEFT JOIN | Kept customers without representatives, found customers without promotions, and included all representatives | 4, 5, 6 |
| SUM | Calculated revenue, costs, gross profit and outstanding balances | 1–8 |
| COUNT | Counted invoices | 3 |
| AVG | Calculated average settlement days and rolling monthly revenue | 3, 7 |
| GROUP BY | Summarised results by channel, product line, customer, representative or month | 1–8 |
| CASE | Separated financial years and classified settled and open invoices | 1, 3, 8 |
| Subquery | Calculated yearly channel totals before calculating growth | 1 |
| Common table expressions (CTEs) | Organised monthly comparisons and yearly product-line calculations | 7, 8 |
| WHERE | Filtered financial-year dates and selected Wholesale customers without promotions | 4, 5 |
| DATEDIFF | Calculated days between invoice and settlement dates | 3 |
| DATE_TRUNC | Grouped order dates into months | 7 |
| LAG | Retrieved the previous month's revenue | 7 |
| Window frame | Calculated the rolling three-month average | 7 |
| PARTITION BY | Calculated total revenue separately for each financial year | 8 |
| COALESCE | Returned zero revenue for representatives without sales | 6 |
| NULLIF | Prevented division by zero | 1, 2, 6, 7, 8 |
| ROUND | Rounded monetary values and percentages | 1–8 |
| ORDER BY and LIMIT | Sorted results and selected the top ten or fifteen customers | 4, 5 |

## Key findings

### For Nomsa Dlamini, Financial Director

- **Both channels grew at similar rates.** Wholesale revenue increased from R308.17 million in FY2024 to R335.43 million in FY2025, growing by 8.85%. Subscription revenue increased from 132.83 million to 144.57 million, growing by 8.84% (Task 1).

- **Wholesale requires closer collections attention.** It had 87.85 million outstanding across 3,454 open invoices.  Fully settled Wholesale invoices took an average of 68.68 days to settle, compared with 3.85 days for Subscription.  Payment terms and overdue balances should be investigated first in Wholesale (Task 3).

- **The margin decline was mainly driven by the product mix.**  Bulk Commercial's share of revenue increased from 25.02% to 33.65%, while its gross margin remained around 19.9%. Higher-margin House Blend and Single Origin lost revenue share, contributing to the overall margin decline from approximately 34.7% to 33.0% (Task 8).

### For Bongani Twala, National Sales Manager

- **The highest-profit line was not the highest-margin line.**  House Blend generated the largest gross profit at 107.15 million, with a margin of 38.33%. Single Origin had the highest margin at 44.27% (Task 2).

- **Halvane Retail Group was the largest customer.** It generated R38.40 million in FY2025, approximately 8% of total revenue. The ten largest customers together generated 61.38 million, representing 12.79% of FY2025 revenue (Task 4).

- **High-revenue customers had gaps in promotional support.** The three largest Wholesale customers with no recorded promotion  were Umhlanga Fresh 108 (6.22 million), Ridgeway Foods 308 (4.45 million) and Kalahari Kitchen 42 (4.45 million). These figures cover the full two-year dataset. Prioritise the three accounts for suitable trade promotions to support future sales (Task 5).

- **Karabo van Wyk led on target achievement.**  Karabo achieved 250.32% of the monthly target, followed by Kagiso Mkhize at 249.82%. Kagiso generated a higher monthly
  revenue average, but Karabo performed better relative to the assigned target (Task 6).

- **December was consistently the quietest month.** Revenue declined towards December and recovered from January towards June in both years. December 2023 recorded the lowest monthly revenue overall at R29.87 million (Task 7).

## Definitions and Assumptions

| Term | Definition |
|---|---|
| Revenue | Sum of line_revenue from the sales lines table |
| Cost of goods | Sum of cogs from the sales lines table |
| Gross profit | Revenue minus cost of goods |
| Gross margin (%) | Gross profit divided by revenue, multiplied by 100 |
| Revenue growth (%) | Current-year revenue minus previous-year revenue, divided by previous-year revenue, multiplied by 100 |
| Settled invoice | An invoice where amount_settled is equal to or greater than invoice_amount |
| Open invoice | An invoice where amount_settled is less than invoice_amount |
| Settlement days | Number of days between the invoice date and settlement date |
| Outstanding balance | Invoice amount minus the amount settled |
| Actual monthly average | A representative's total FY2025 revenue divided by 12 |
| Target achievement (%) | Actual monthly average divided by monthly target, multiplied by 100 |
| Monthly revenue change (%) | Current-month revenue minus previous-month revenue, divided by previous-month revenue, multiplied by 100 |
| Rolling three-month average | Average revenue for the current month and the previous two months |
| Revenue share (%) | A product line's revenue divided by total revenue for the same financial year, multiplied by 100 |

### Reporting periods

- FY2024 covers 1 July 2023 to 30 June 2024.
- FY2025 covers 1 July 2024 to 30 June 2025.
- Tasks 2, 3 and 5 use the full supplied dataset.
- Tasks 4 and 6 use FY2025 only.
- Tasks 1 and 8 compare the two financial years.
- Task 7 uses all 24 months.

### Assumptions and calculation rules

- Task 1 and Task 8 classify dates before 1 July 2024 as FY2024 and all later dates as FY2025. This relies on the supplied dataset containing only the two financial years.
- Revenue is taken directly from line_revenue. Discounts are not deducted again.
- All order statuses are included because the assignment does not request a status filter.
- Gross margin is calculated from total revenue and total cost, rather than averaging individual sales-line margins.
- Average settlement time includes fully settled invoices only. Open invoices are not treated as taking zero days to settle.
- An open invoice is not necessarily overdue. Determining whether it is overdue requires comparing its due date with a reporting date.
- Customers without an assigned representative remain eligible for the top-ten customer list.
- Account ownership in Task 4 uses customers.rep_id. Representative sales performance in Task 6 uses sales_orders.rep_id.
- Task 5 treats "never received a promotion" as having no matching record in the supplied trade_promotions table.
- All representatives are included in Task 6. Those without FY2025 sales receive zero revenue. Annual revenue is divided by all 12 months, including months without sales.
- The first month's percentage change is NULL because no previous month is available. The rolling average uses one month initially,  two months in the second row, and three months thereafter.  All 24 months are present in the supplied data.
- NULLIF prevents division by zero. Where a denominator is zero, the resulting percentage is NULL.
- Calculations use unrounded totals. Final monetary values and percentages are rounded to two decimal places.


## Validation and Limitations

### Validation

- Queries were run in the Databricks SQL Editor and their outputs reviewed against the assignment requirements.
- Combined channel revenue was approximately 441 million for FY2024 and 480 million for FY2025, consistent with the brief.
- For each channel, settled invoices plus open invoices equal the total number of invoices.
- The top-customer and promotion-gap queries return 10 and 15 customers respectively.
- The representative analysis includes all 18 representatives, including those without FY2025 sales.
- The monthly analysis covers 24 months, with the first month's percentage change returned as NULL.

### Limitations

- Findings relate only to the supplied Sizwe Coffee dataset
- The collections summary compares channels across the full period. It does not establish whether customers are taking longer to pay over time.
- Two years of monthly data suggest a seasonal pattern but are insufficient to establish a long-term trend.
- Customers identified as having no promotions have no matching records in the supplied promotion table. Earlier promotions outside the dataset cannot be ruled out.
- Gross profit includes only revenue less cost of goods. It does not account for operating expenses, finance costs or taxes and therefore does not measure net profit.
