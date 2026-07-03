-- Run 01_schema.sql and 02_data_insert.sql first
USE Ecommerce_db;

-- ============================================================
-- QUERY OPTIMIZATION CHECK (using indexes created earlier)
-- ============================================================

-- Checks whether the index on orders.customer_id is being used
EXPLAIN
SELECT * FROM orders WHERE customer_id = 5;

-- Checks whether the index on orders.order_date is being used
EXPLAIN
SELECT * FROM orders WHERE order_date >= '2024-01-01';

-- Checks whether the index on products.category is being used
EXPLAIN
SELECT * FROM products WHERE category = 'Electronics';


-- ============================================================
-- ADVANCED ANALYTICS QUERIES (Window Functions, CTEs)
-- ============================================================

-- 1. Monthly gross order value trend
-- NOTE: gross order value (includes Pending/Cancelled orders),
-- not actual payments collected -- see revenue definitions note above
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(oi.quantity * oi.price_at_purchase) AS monthly_gross_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;


-- 2. Running total of gross order value (cumulative, month by month)
-- Uses SUM() OVER as a window function on top of the monthly totals
-- NOTE: gross order value again, not actual payments collected
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * oi.price_at_purchase) AS gross_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY order_month
)
SELECT
    order_month,
    gross_order_value,
    SUM(gross_order_value) OVER (ORDER BY order_month) AS running_total_gross_order_value
FROM monthly_revenue
ORDER BY order_month;


-- 3. Rank customers by total spend (leaderboard)
SELECT
    c.customer_name,
    SUM(p.amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.amount) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name;

EXPLAIN
SELECT
    c.customer_name,
    SUM(p.amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.amount) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name;


-- 4. Rank products within each category (best seller per category)
SELECT
    p.category,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.category, p.product_name;


-- 5. Month-over-month gross order value growth %
-- NULLIF used to avoid divide-by-zero, and first month's prev_month_value
-- will naturally be NULL (no previous month exists) so growth % shows NULL for it
-- NOTE: gross order value based, not actual payments collected
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * oi.price_at_purchase) AS gross_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY order_month
),
revenue_with_prev AS (
    SELECT
        order_month,
        gross_order_value,
        LAG(gross_order_value) OVER (ORDER BY order_month) AS prev_month_value
    FROM monthly_revenue
)
SELECT
    order_month,
    gross_order_value,
    prev_month_value,
    ROUND((gross_order_value - prev_month_value) / NULLIF(prev_month_value, 0) * 100, 2) AS mom_growth_percent
FROM revenue_with_prev
ORDER BY order_month;


-- 6. Repeat vs one-time customers
WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM customer_order_counts
GROUP BY customer_type;

-- ============================================================
-- END OF SCRIPT
-- Total rows: customers=300, products=32, orders=1013,
-- order_items=1922, payments=820
-- Total queries: 5 joins + 11 basic insights (incl. 1 subquery)
-- + 4 EXPLAIN checks + 6 advanced (window functions/CTEs)
-- ============================================================
