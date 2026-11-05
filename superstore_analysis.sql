-- =====================================================================
-- Superstore Sales Analysis (MySQL)
-- Tables: sales (9,994 rows, one row per order line), customers (793 rows)
-- Files : sales_clean.csv, customers_clean.csv  (dates are YYYY-MM-DD)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. SETUP
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id   VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment       VARCHAR(20)
);

CREATE TABLE sales (
    row_id       INT PRIMARY KEY,
    order_id     VARCHAR(20),
    order_date   DATE,
    ship_date    DATE,
    ship_mode    VARCHAR(20),
    customer_id  VARCHAR(20),
    country      VARCHAR(50),
    city         VARCHAR(50),
    state        VARCHAR(50),
    postal_code  VARCHAR(10),
    region       VARCHAR(20),
    product_id   VARCHAR(20),
    category     VARCHAR(30),
    sub_category VARCHAR(30),
    product_name VARCHAR(200),
    sales        DECIMAL(12,4),
    quantity     INT,
    discount     DECIMAL(4,2),
    profit       DECIMAL(12,4)
);
-- Import both CSV files with the MySQL Workbench Table Data Import Wizard.

-- ---------------------------------------------------------------------
-- 1. DATA QUALITY CHECKS
-- ---------------------------------------------------------------------
-- Q1.1 Row count, duplicate rows, and missing values
SELECT COUNT(*)                    AS total_rows,
       COUNT(DISTINCT row_id)      AS distinct_row_ids,
       SUM(CASE WHEN sales IS NULL OR profit IS NULL THEN 1 ELSE 0 END) AS rows_with_missing_values
FROM sales;

-- Q1.2 Date range and number of orders / customers
SELECT MIN(order_date)             AS first_order,
       MAX(order_date)             AS last_order,
       COUNT(DISTINCT order_id)    AS orders,
       COUNT(DISTINCT customer_id) AS customers
FROM sales;

-- ---------------------------------------------------------------------
-- 2. OVERALL PERFORMANCE
-- ---------------------------------------------------------------------
-- Q2.1 Total sales, profit, and profit margin
SELECT ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales;

-- Q2.2 Sales, profit, and margin by year
SELECT YEAR(order_date)      AS order_year,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Q2.3 Which months are the strongest? (all years combined)
SELECT MONTH(order_date)     AS order_month,
       ROUND(SUM(sales), 2)  AS total_sales
FROM sales
GROUP BY MONTH(order_date)
ORDER BY total_sales DESC;

-- ---------------------------------------------------------------------
-- 3. PRODUCTS: WHERE DO WE MAKE AND LOSE MONEY?
-- ---------------------------------------------------------------------
-- Q3.1 Category performance
SELECT category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales
GROUP BY category
ORDER BY total_profit DESC;

-- Q3.2 Sub-categories that lose money overall (HAVING)
SELECT sub_category,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- Q3.3 The 10 least profitable products
SELECT product_name,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY product_name
ORDER BY SUM(profit)
LIMIT 10;

-- Q3.4 Product ID prefix check (string function): do the first 3 letters match the category?
SELECT SUBSTRING(product_id, 1, 3) AS id_prefix,
       category,
       COUNT(*)                    AS order_lines
FROM sales
GROUP BY SUBSTRING(product_id, 1, 3), category
ORDER BY id_prefix;

-- ---------------------------------------------------------------------
-- 4. DISCOUNTS
-- ---------------------------------------------------------------------
-- Q4.1 Profit by discount band (CASE WHEN)
SELECT CASE WHEN discount = 0   THEN '1. No discount'
            WHEN discount <= 0.2 THEN '2. Up to 20%'
            WHEN discount <= 0.4 THEN '3. Over 20% to 40%'
            ELSE                      '4. Over 40%'
       END AS discount_band,
       COUNT(*)              AS order_lines,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales
GROUP BY discount_band
ORDER BY discount_band;

-- Q4.2 Profitable vs loss-making order lines (UNION)
SELECT 'Loss-making' AS line_type, COUNT(*) AS order_lines, ROUND(SUM(profit), 2) AS total_profit
FROM sales
WHERE profit < 0
UNION
SELECT 'Profitable'  AS line_type, COUNT(*) AS order_lines, ROUND(SUM(profit), 2) AS total_profit
FROM sales
WHERE profit >= 0;

-- ---------------------------------------------------------------------
-- 5. REGIONS AND STATES
-- ---------------------------------------------------------------------
-- Q5.1 Region performance
SELECT region,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM sales
GROUP BY region
ORDER BY total_profit DESC;

-- Q5.2 States that lose money overall
SELECT state,
       ROUND(SUM(sales), 2)  AS total_sales,
       ROUND(SUM(profit), 2) AS total_profit
FROM sales
GROUP BY state
HAVING SUM(profit) < 0
ORDER BY total_profit;

-- ---------------------------------------------------------------------
-- 6. CUSTOMERS (uses JOIN)
-- ---------------------------------------------------------------------
-- Q6.1 Customer segment performance
SELECT c.segment,
       COUNT(DISTINCT c.customer_id) AS customers,
       ROUND(SUM(s.sales), 2)        AS total_sales,
       ROUND(SUM(s.profit), 2)       AS total_profit,
       ROUND(SUM(s.profit) / SUM(s.sales) * 100, 1) AS profit_margin_pct
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;

-- Q6.2 Top 10 customers by sales, with their profit
SELECT c.customer_name,
       c.segment,
       ROUND(SUM(s.sales), 2)  AS total_sales,
       ROUND(SUM(s.profit), 2) AS total_profit
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY SUM(s.sales) DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- 7. SHIPPING
-- ---------------------------------------------------------------------
-- Q7.1 Average days to ship by ship mode
SELECT ship_mode,
       COUNT(*)                                   AS order_lines,
       ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_days_to_ship
FROM sales
GROUP BY ship_mode
ORDER BY avg_days_to_ship;
