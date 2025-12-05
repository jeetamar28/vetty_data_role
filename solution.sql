-- ====================================
-- SQL TEST SUBMISSION
-- ====================================
-- Author: [Your Name]
-- Date: December 5, 2024
-- Description: SQL queries for data analysis test
-- ====================================

-- ====================================
-- STEP 1: CREATE ALL TABLES
-- ====================================

-- Create transactions table
CREATE TABLE transactions (
    buyer_id INTEGER,
    purchase_time TIMESTAMP,
    refund_item TIMESTAMP,
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    gross_transaction_value DECIMAL(10,2)
);

-- Create items table
CREATE TABLE items (
    store_id VARCHAR(10),
    item_id VARCHAR(10),
    item_category VARCHAR(50),
    item_name VARCHAR(50)
);

-- Create orders table
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    item VARCHAR(50),
    amount DECIMAL(10,2),
    customer_id INTEGER
);

-- Create shippings table
CREATE TABLE shippings (
    shipping_id INTEGER PRIMARY KEY,
    status VARCHAR(20),
    customer INTEGER
);

-- Create customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INTEGER,
    country VARCHAR(10)
);

-- ====================================
-- STEP 2: INSERT DATA
-- ====================================

-- Insert transaction data
INSERT INTO transactions VALUES
(3, '2019-09-19 21:19:06.544', NULL, 'a', 'a1', 58),
(12, '2019-12-10 20:10:14.324', '2019-12-15 23:19:06.544', 'b', 'b2', 475),
(3, '2020-09-01 23:59:46.561', '2020-09-02 21:22:06.331', 'f', 'f9', 33),
(2, '2020-04-30 21:19:06.544', NULL, 'd', 'd3', 250),
(1, '2020-10-22 22:20:06.531', NULL, 'f', 'f2', 91),
(8, '2020-04-16 21:10:22.214', NULL, 'e', 'e7', 24),
(5, '2019-09-23 12:09:35.542', '2019-09-27 02:55:02.114', 'g', 'g6', 61);

-- Insert items data
INSERT INTO items VALUES
('a', 'a1', 'pants', 'denim pants'),
('a', 'a2', 'tops', 'blouse'),
('f', 'f1', 'table', 'coffee table'),
('f', 'f5', 'chair', 'lounge chair'),
('f', 'f6', 'chair', 'armchair'),
('d', 'd2', 'jewelry', 'bracelet'),
('b', 'b4', 'earphone', 'airpods');

-- Insert orders data
INSERT INTO orders VALUES
(1, 'Keyboard', 400, 4),
(2, 'Mouse', 300, 4),
(3, 'Monitor', 12000, 3),
(4, 'Keyboard', 400, 1),
(5, 'Mousepad', 250, 2);

-- Insert shippings data
INSERT INTO shippings VALUES
(1, 'Pending', 2),
(2, 'Pending', 4),
(3, 'Delivered', 3),
(4, 'Pending', 5),
(5, 'Delivered', 1);

-- Insert customers data
INSERT INTO customers VALUES
(1, 'John', 'Doe', 31, 'USA'),
(2, 'Robert', 'Luna', 22, 'USA'),
(3, 'David', 'Robinson', 22, 'UK'),
(4, 'John', 'Reinhardt', 25, 'UK'),
(5, 'Betty', 'Doe', 28, 'UAE');

-- ====================================
-- VERIFICATION: Display all tables
-- ====================================

SELECT '========== TRANSACTIONS TABLE ==========' AS '';
SELECT * FROM transactions;

SELECT '========== ITEMS TABLE ==========' AS '';
SELECT * FROM items;

SELECT '========== ORDERS TABLE ==========' AS '';
SELECT * FROM orders;

SELECT '========== SHIPPINGS TABLE ==========' AS '';
SELECT * FROM shippings;

SELECT '========== CUSTOMERS TABLE ==========' AS '';
SELECT * FROM customers;

-- ====================================
-- QUERIES FOR QUESTIONS 1-8
-- ====================================

/* 
QUESTION 1: Count of purchases per month (excluding refunded purchases)
APPROACH: Group by month from purchase_time, count rows where gross_transaction_value > 0
*/
SELECT '========== Q1: Purchases per Month ==========' AS '';
SELECT 
    strftime('%Y-%m', purchase_time) AS month,
    COUNT(*) AS purchase_count
FROM transactions
WHERE gross_transaction_value > 0
GROUP BY strftime('%Y-%m', purchase_time)
ORDER BY month;

/* 
QUESTION 2: How many stores receive at least 5 orders/transactions in October 2020?
APPROACH: Filter for October 2020, group by store_id, count transactions, filter >= 5
*/
SELECT '========== Q2: Stores with 5+ Orders in Oct 2020 ==========' AS '';
SELECT COUNT(DISTINCT store_id) AS store_count
FROM (
    SELECT store_id, COUNT(*) AS order_count
    FROM transactions
    WHERE strftime('%Y-%m', purchase_time) = '2020-10'
    GROUP BY store_id
    HAVING COUNT(*) >= 5
);

/* 
QUESTION 3: Shortest interval (in minutes) from purchase to refund time per store
APPROACH: Calculate time difference in minutes using julianday, get MIN per store
*/
SELECT '========== Q3: Shortest Refund Interval (minutes) ==========' AS '';
SELECT 
    store_id,
    ROUND(MIN((julianday(refund_item) - julianday(purchase_time)) * 24 * 60), 2) AS shortest_interval_minutes
FROM transactions
WHERE refund_item IS NOT NULL
GROUP BY store_id
ORDER BY store_id;

/* 
QUESTION 4: Gross transaction value of every store's first order
APPROACH: Use ROW_NUMBER() to rank orders by purchase_time per store, filter rank = 1
*/
SELECT '========== Q4: First Order Value per Store ==========' AS '';
SELECT 
    store_id,
    gross_transaction_value AS first_order_value,
    purchase_time
FROM (
    SELECT 
        store_id,
        gross_transaction_value,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time) AS rn
    FROM transactions
) ranked
WHERE rn = 1
ORDER BY store_id;

/* 
QUESTION 5: Most popular item name that buyers order on their first purchase
APPROACH: Get first purchase per buyer using ROW_NUMBER(), join with items, count item_name
*/
SELECT '========== Q5: Most Popular Item on First Purchase ==========' AS '';
SELECT 
    i.item_name,
    COUNT(*) AS frequency
FROM (
    SELECT 
        t.buyer_id,
        t.item_id,
        ROW_NUMBER() OVER (PARTITION BY t.buyer_id ORDER BY t.purchase_time) AS rn
    FROM transactions t
) first_purchases
JOIN items i ON first_purchases.item_id = i.item_id
WHERE rn = 1
GROUP BY i.item_name
ORDER BY frequency DESC
LIMIT 1;

/* 
QUESTION 6: Flag indicating whether refund can be processed (within 72 hours)
APPROACH: Use CASE to check if refund_item exists and is within 72 hours of purchase
*/
SELECT '========== Q6: Refund Processable Flag ==========' AS '';
SELECT 
    buyer_id,
    purchase_time,
    refund_item,
    store_id,
    item_id,
    gross_transaction_value,
    CASE 
        WHEN refund_item IS NOT NULL 
        AND (julianday(refund_item) - julianday(purchase_time)) * 24 <= 72 
        THEN 1 
        ELSE 0 
    END AS refund_processable_flag
FROM transactions
ORDER BY buyer_id, purchase_time;

/* 
QUESTION 7: Filter for only the second purchase per buyer
APPROACH: Use ROW_NUMBER() to rank purchases per buyer, filter where rank = 2
*/
SELECT '========== Q7: Second Purchase per Buyer ==========' AS '';
SELECT 
    buyer_id,
    purchase_time,
    store_id,
    item_id,
    gross_transaction_value
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS purchase_rank
    FROM transactions
) ranked
WHERE purchase_rank = 2;

/* 
QUESTION 8: Find the second transaction time per buyer
APPROACH: Same as Q7 but only return buyer_id and purchase_time
*/
SELECT '========== Q8: Second Transaction Time per Buyer ==========' AS '';
SELECT 
    buyer_id,
    purchase_time AS second_purchase_time
FROM (
    SELECT 
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time) AS purchase_rank
    FROM transactions
) ranked
WHERE purchase_rank = 2;

-- ====================================
-- BONUS QUERIES (Using all tables)
-- ====================================

/* 
BONUS 1: Total order amount per customer with their details
*/
SELECT '========== BONUS: Customer Order Summary ==========' AS '';
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS full_name,
    c.country,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_amount DESC;

/* 
BONUS 2: Shipping status by country
*/
SELECT '========== BONUS: Shipping Status by Country ==========' AS '';
SELECT 
    c.country,
    s.status,
    COUNT(*) AS count
FROM shippings s
JOIN customers c ON s.customer = c.customer_id
GROUP BY c.country, s.status
ORDER BY c.country, s.status;
