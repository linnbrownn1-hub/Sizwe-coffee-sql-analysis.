--Task 1 - Channel performance

 SELECT
    channel,
    ROUND(FY2024_revenue, 2) AS FY2024_revenue,
    ROUND(FY2025_revenue, 2) AS FY2025_revenue,
    ROUND(100.0 * (FY2025_revenue - FY2024_revenue)/ NULLIF(FY2024_revenue, 0), 2) AS growth_pct

FROM (SELECT orders.channel,
        SUM(CASE
            WHEN orders.order_date < '2024-07-01'
            THEN lines.line_revenue ELSE 0 END) AS FY2024_revenue,

        SUM(CASE
            WHEN orders.order_date >= '2024-07-01'
            THEN lines.line_revenue ELSE 0 END) AS FY2025_revenue

    FROM sizwe_sales_orders AS orders
    JOIN sizwe_sales_lines AS lines
        ON orders.order_id = lines.order_id

    GROUP BY orders.channel) AS channel_totals

-- Answer: Wholesale generated the most revenue, increasing from R308.17 million in FY2024 to 335.43 million in FY2025. Both channels grew at almost the same rate: Wholesale by 8.85% and Subscription by 8.84%.


--Task 2 - Where the profit actually comes from 

SELECT
    products.product_line,
    ROUND(SUM(lines.line_revenue), 2) AS revenue,
    ROUND(SUM(lines.cogs), 2) AS cost_of_goods,
    ROUND(SUM(lines.line_revenue - lines.cogs), 2 ) AS gross_profit,

    ROUND(100.0 * SUM(lines.line_revenue - lines.cogs) / NULLIF(SUM(lines.line_revenue), 0), 2 ) AS gross_margin_pct

FROM sizwe_products AS products
JOIN sizwe_sales_lines AS lines
    ON products.sku = lines.sku
GROUP BY products.product_line
ORDER BY gross_profit DESC

-- House Blend earns the highest gross profit at R107.15 million, with a gross margin of 38.33%. Single Origin has the highest gross margin at 44.27%, so the highest-profit and highest-margin lines differ.


--Task 3 - The collections problem 

SELECT customers.channel,
    COUNT(*) AS total_invoices,
    SUM(CASE WHEN invoices.amount_settled >= invoices.invoice_amount THEN 1 ELSE 0 END) AS settled_invoices,

    SUM(CASE WHEN invoices.amount_settled < invoices.invoice_amount THEN 1 ELSE 0 END) AS open_invoices,

    ROUND( AVG(CASE WHEN invoices.amount_settled >= invoices.invoice_amount 
            THEN DATEDIFF(invoices.settlement_date,invoices.invoice_date)END), 2) AS avg_days_settle,

    ROUND( SUM(invoices.invoice_amount - invoices.amount_settled), 2 ) AS total_outstanding

FROM sizwe_ar_ledger AS invoices

JOIN sizwe_customers AS customers
    ON invoices.customer_id = customers.customer_id

GROUP BY customers.channel

ORDER BY total_outstanding DESC

--Wholesale takes an average of 68.68 days to settle invoices,compared with 3.85 days for Subscription, and has 87.85 million outstanding. I would investigate Wholesale first, checking payment terms and overdue invoices. These results show differences between channels, but do not establish whether payments have slowed over time.


--Task 4 - The ten accounts that matter most 

SELECT
    customers.trading_name,customers.segment,customers.province,reps.rep_name,
    ROUND(SUM(lines.line_revenue), 2) AS FY2025_revenue
FROM sizwe_customers AS customers
JOIN sizwe_sales_orders AS orders ON customers.customer_id = orders.customer_id
JOIN sizwe_sales_lines AS lines ON orders.order_id = lines.order_id
LEFT JOIN sizwe_reps AS reps ON customers.rep_id = reps.rep_id

WHERE orders.order_date >= '2024-07-01'
  AND orders.order_date < '2025-07-01'
GROUP BY
    customers.customer_id,customers.trading_name,customers.segment,customers.province,reps.rep_name

ORDER BY FY2025_revenue DESC
LIMIT 10

--The ten largest customers generated 61.38 million, accounting for 12.79% of FY2025 revenue. Halvane Retail Group was the largest customer at R38.40 million, approximately 8% of total revenue, making it a particularly important account to retain.Halvane is a Grocery Chain customer in the Western Cape, managed by Kagiso Mkhize. Its revenue is substantially higher than the second-largest customer, Highveld Deli 85, at 3.38 million. This indicates that Halvane Retail Group  is the one major account.


--Task 5 - A commercial gap 

SELECT
    customers.trading_name,
    customers.segment,
    customers.province,
    ROUND(SUM(lines.line_revenue), 2) AS total_revenue

FROM sizwe_customers AS customers
JOIN sizwe_sales_orders AS orders ON customers.customer_id = orders.customer_id
JOIN sizwe_sales_lines AS lines ON orders.order_id = lines.order_id
LEFT JOIN sizwe_trade_promotions AS promotions ON customers.customer_id = promotions.customer_id
WHERE customers.channel = 'Wholesale' AND promotions.promo_id IS NULL

GROUP BY customers.customer_id,customers.trading_name,customers.segment,customers.province
ORDER BY total_revenue DESC
LIMIT 15

--Prioritise the top three customers for suitable trade promotions to support future sales.


--Task 6 - Are the sales representatives hitting target? 

SELECT
    reps.rep_name,
    reps.territory,
    reps.target_monthly,

    ROUND(COALESCE(SUM(lines.line_revenue), 0) / 12, 2) AS actual_monthly_average,

    ROUND(100.0 * COALESCE(SUM(lines.line_revenue), 0) / 12 / NULLIF(reps.target_monthly, 0), 2 ) AS target_achievement_pct

FROM sizwe_reps AS reps
LEFT JOIN sizwe_sales_orders AS orders
    ON reps.rep_id = orders.rep_id
    AND orders.order_date >= '2024-07-01'
    AND orders.order_date < '2025-07-01'
LEFT JOIN sizwe_sales_lines AS lines
    ON orders.order_id = lines.order_id
GROUP BY reps.rep_id,reps.rep_name,reps.territory,reps.target_monthly
ORDER BY target_achievement_pct DESC

--Karabo van Wyk achieved the highest percentage of target at 250.32%, followed by Kagiso Mkhize at 249.82%. Kagiso generated a higher monthly average revenue, however Karabo performed better relative to his assigned target.

--Task 7 - The shape of the year 

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('MONTH', orders.order_date) AS sales_month,SUM(lines.line_revenue) AS revenue
    FROM sizwe_sales_orders AS orders
    JOIN sizwe_sales_lines AS lines
        ON orders.order_id = lines.order_id
    GROUP BY DATE_TRUNC('MONTH', orders.order_date)),

monthly_comparison AS (
    SELECT *,
        LAG(revenue) OVER (ORDER BY sales_month) AS previous_month_revenue
    FROM monthly_sales)

SELECT
    CAST(sales_month AS DATE) AS sales_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(100.0 * (revenue - previous_month_revenue)/ NULLIF(previous_month_revenue, 0), 2
    ) AS monthly_change_pct,

    ROUND(AVG(revenue) OVER (ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2
    ) AS rolling_three_month_average

FROM monthly_comparison
ORDER BY sales_month

--The two years show a similar seasonal pattern, with revenue declining towards December and recovering from January towards June. December is the quietest month in both years, with December 2023 recording the lowest revenue overall at 29.87 million.

--Task 8 - Why has the margin moved? 

WITH yearly_sales AS (
 SELECT
        products.product_line,
        CASE
            WHEN orders.order_date < '2024-07-01'
            THEN 'FY2024'
            ELSE 'FY2025'
        END AS financial_year,
        SUM(lines.line_revenue) AS revenue,
        SUM(lines.cogs) AS cost_of_goods

    FROM sizwe_sales_orders AS orders

    JOIN sizwe_sales_lines AS lines
        ON orders.order_id = lines.order_id

    JOIN sizwe_products AS products
        ON lines.sku = products.sku

    GROUP BY
        products.product_line,
        CASE
            WHEN orders.order_date < '2024-07-01'
            THEN 'FY2024'
            ELSE 'FY2025'
        END
)

SELECT
    product_line,
    financial_year,
    ROUND(revenue, 2) AS revenue,

    ROUND(
        100.0 * (revenue - cost_of_goods)
        / NULLIF(revenue, 0), 2
    ) AS gross_margin_pct,

    ROUND(
        100.0 * revenue
        / NULLIF(
            SUM(revenue) OVER (PARTITION BY financial_year), 0
        ), 2
    ) AS revenue_share_pct

FROM yearly_sales
ORDER BY product_line, financial_year

--The overall margin fell because Bulk Commercial, with a low margin of about 19.9%, increased its share of revenue from 25.02% to 33.65%. Higher-margin House Blend and Single Origin lost revenue share,falling from 32.14% to 28.71% and from 19.45% to 17.57%, reducing overall profitability despite higher total revenue.