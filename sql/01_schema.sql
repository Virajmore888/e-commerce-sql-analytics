CREATE DATABASE Ecommerce_db;
USE Ecommerce_db;

-- ------------------------------------------------------------
-- 1. CUSTOMERS TABLE
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    city            VARCHAR(50),
    signup_date     DATE NOT NULL
);

-- ------------------------------------------------------------
-- 2. PRODUCTS TABLE
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    price           DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity  INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);

-- ------------------------------------------------------------
-- 3. ORDERS TABLE
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    order_date      DATE NOT NULL,
    order_status    VARCHAR(20) NOT NULL DEFAULT 'Pending'
                    CHECK (order_status IN ('Pending','Shipped','Delivered','Cancelled','Returned')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. ORDER_ITEMS TABLE
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id          INT NOT NULL,
    product_id        INT NOT NULL,
    quantity          INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ------------------------------------------------------------
-- 5. PAYMENTS TABLE
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id       INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT NOT NULL UNIQUE,
    payment_method   VARCHAR(20) NOT NULL
                     CHECK (payment_method IN ('UPI','Card','COD','NetBanking')),
    amount           DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date     DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 6. INDEXES (for faster JOINs and filtering on large data)
-- ------------------------------------------------------------
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- ============================================================
-- TABLE RELATIONSHIP / JOIN PATH
-- ============================================================
-- customers (customer_id)
--     └──> orders (customer_id -> order_id)
--             ├──> order_items (order_id -> product_id)
--             │        └──> products (product_id)
--             └──> payments (order_id)
--
-- NOTE: payments only exist for orders with status Shipped/Delivered/Returned.
-- Pending and Cancelled orders have NO payment row -> use LEFT JOIN on
-- payments, not INNER JOIN, or those orders will silently disappear.
-- ============================================================
