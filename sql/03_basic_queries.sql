-- Run 01_schema.sql and 02_data_insert.sql first
USE Ecommerce_db;

-- ============================================================
-- ANALYSIS QUERIES START HERE
-- ============================================================


-- ============================================================
-- STEP 1: VIEW EACH TABLE INDIVIDUALLY (before any joins)
-- Run these first to see the raw data in each table on its own.
-- Note: a JOIN never creates a new permanent table - it only
-- produces a temporary combined result for that one query run.
-- To see the fully combined data, run the "Full Chain Join"
-- query further below (JOIN QUERIES, #5).
-- ============================================================

-- 1. customers table
SELECT * FROM customers LIMIT 10;

-- 2. products table
SELECT * FROM products LIMIT 10;

-- 3. orders table
SELECT * FROM orders LIMIT 10;

-- 4. order_items table
SELECT * FROM order_items LIMIT 10;

-- 5. payments table
SELECT * FROM payments LIMIT 10;

-- ============================================================
-- JOIN QUERIES
-- ============================================================

-- 1. Customers JOIN Orders
-- Shows which customer placed which order, with order date and status
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.order_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


-- 2. Orders JOIN Order_Items
-- Shows each order broken down into the individual line items inside it
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    oi.order_item_id,
    oi.product_id,
    oi.quantity,
    oi.price_at_purchase
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- 3. Order_Items JOIN Products
-- Adds product name, category and current price to each order line item
SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.price_at_purchase
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id;


-- 4. Orders LEFT JOIN Payments
-- LEFT JOIN because Pending/Cancelled orders have no payment recorded yet
SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    p.payment_method,
    p.amount,
    p.payment_date
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id;


-- 5. Full Chain Join: Customers -> Orders -> Order_Items -> Products -> Payments
-- Combines all 5 tables into one complete view of every transaction
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.order_status,
    pr.product_name,
    pr.category,
    oi.quantity,
    oi.price_at_purchase,
    pay.payment_method,
    pay.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
LEFT JOIN payments pay ON o.order_id = pay.order_id;


-- ============================================================
-- NOTE ON "REVENUE" DEFINITIONS USED IN THIS SCRIPT
-- ============================================================
-- Two different revenue metrics are used below, deliberately:
--   1) net_collected_revenue  -> SUM(payments.amount)
--      Actual money received. Excludes Pending/Cancelled orders
--      (they have no payment row).
--   2) gross_order_value      -> SUM(order_items.quantity * price_at_purchase)
--      Total value of everything ordered, INCLUDING Pending and
--      Cancelled orders (money not actually collected).
-- These are intentionally different numbers and should never be
-- compared directly. Column names below are labeled accordingly.
-- ============================================================

-- ============================================================
-- BASIC ANALYSIS QUERIES (SIMPLE INSIGHTS)
-- ============================================================

-- 1. Overall summary: how many customers, orders, and net revenue collected
-- Revenue is taken from payments table (actual money received),
-- NOT order value, so Pending/Cancelled orders contribute 0 here
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(p.amount) AS net_collected_revenue
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id;


-- 2. How many customers are there in each city
SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;


-- 3. How many products in each category, and their average price
SELECT
    category,
    COUNT(*) AS total_products,
    AVG(price) AS avg_price
FROM products
GROUP BY category;


-- 4. Order status breakdown - count of orders in each status
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 5. Gross order value earned from each product category
-- NOTE: this is order value (includes Pending/Cancelled), not
-- actual collected payments -> compare only to other gross_* metrics
SELECT
    p.category,
    SUM(oi.quantity * oi.price_at_purchase) AS gross_category_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY gross_category_order_value DESC;


-- 6. Total amount collected through each payment method
SELECT
    payment_method,
    SUM(amount) AS total_collected
FROM payments
GROUP BY payment_method
ORDER BY total_collected DESC;


-- 7. Top 5 best-selling products by quantity sold
SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;


-- 8. Top 5 customers by total amount spent
-- NOTE: grouped by customer_id (not just name) so two different
-- customers who happen to share the same name never get merged
-- into one row and their spends never get wrongly added together
SELECT
    c.customer_id,
    c.customer_name,
    SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;


-- 9. Average order value (average amount paid per order)
SELECT
    AVG(amount) AS average_order_value
FROM payments;


-- 10. Products that are running low on stock (less than 50 units left)
SELECT
    product_name,
    category,
    stock_quantity
FROM products
WHERE stock_quantity < 50
ORDER BY stock_quantity ASC;


-- 11. (SUBQUERY) Customers who spent more than the average customer spend
-- Inner query calculates average total spend per customer,
-- outer query filters customers above that average
SELECT
    c.customer_name,
    SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(p.amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(p2.amount) AS customer_total
        FROM orders o2
        JOIN payments p2 ON o2.order_id = p2.order_id
        GROUP BY o2.customer_id
    ) AS customer_totals
)
ORDER BY total_spent DESC;


