## Overview
This repository contains SQL queries and analysis for the SQL evaluation test. The project demonstrates data manipulation, aggregation, and analytical query skills across multiple related tables.

## Database Schema

### Tables Used:
1. **transactions** - Purchase and refund data
2. **items** - Product catalog information
3. **orders** - Customer order records
4. **shippings** - Delivery status tracking
5. **customers** - Customer demographic data

## Questions Solution

### Question 1: Monthly Purchase Count
**Objective:** Count purchases per month (excluding refunded purchases)

**Approach:** 
- Group transactions by month using `strftime('%Y-%m', purchase_time)`
- Count all records with positive `gross_transaction_value`

**Result:** Shows distribution of purchases across 2019-2020

---

### Question 2: High-Volume Stores (October 2020)
**Objective:** Find stores with at least 5 orders in October 2020

**Approach:**
- Filter transactions for October 2020
- Group by `store_id` and count orders
- Apply `HAVING COUNT(*) >= 5` condition

**Result:** 0 stores meet this criteria in the dataset

---

### Question 3: Shortest Refund Interval
**Objective:** Calculate shortest time (in minutes) from purchase to refund per store

**Approach:**
- Calculate time difference using `julianday()` function
- Convert to minutes: `(julianday(refund_item) - julianday(purchase_time)) * 24 * 60`
- Get `MIN()` per store for only records with refunds

**Result:** 
- Store b: ~7,329 minutes
- Store f: ~1,282 minutes  
- Store g: ~5,646 minutes

---

### Question 4: First Order Value by Store
**Objective:** Get gross transaction value of each store's first order

**Approach:**
- Use `ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time)` window function
- Filter for `rn = 1` to get first order

**Result:** Each store's initial transaction value identified

---

### Question 5: Most Popular First Purchase Item
**Objective:** Find the item most frequently bought on customers' first purchase

**Approach:**
- Use `ROW_NUMBER()` to identify each buyer's first purchase
- Join with `items` table to get `item_name`
- Group by `item_name` and count frequency
- Order by frequency descending

**Result:** Identified most popular first-purchase item

---

### Question 6: Refund Processability Flag
**Objective:** Create a flag indicating if refund can be processed (≤72 hours)

**Approach:**
- Use `CASE` statement to check:
  - If `refund_item IS NOT NULL`
  - AND time difference ≤ 72 hours
- Return 1 (processable) or 0 (not processable)

**Result:** Binary flag added to each transaction

---

### Question 7: Second Purchase Filter
**Objective:** Filter for only the second purchase per buyer

**Approach:**
- Use `ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time)`
- Filter `WHERE purchase_rank = 2`

**Result:** Shows only buyer 3's second purchase

---

### Question 8: Second Transaction Timestamp
**Objective:** Extract the timestamp of each buyer's second transaction

**Approach:**
- Same window function as Q7
- Return only `buyer_id` and `purchase_time`

**Result:** Timestamp identified for buyers with 2+ purchases

---

## Technical Details

### SQL Dialect: SQLite
- Uses SQLite functions: `strftime()`, `julianday()`
- Window functions: `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`
- Compatible with: SQLite Online, DB Fiddle, SQL Fiddle

### Key Techniques Used:
- Window Functions (ROW_NUMBER)
- Common Table Expressions (subqueries)
- Date/Time calculations
- Aggregation (COUNT, MIN, SUM)
- JOINs (INNER JOIN, LEFT JOIN)
- Conditional logic (CASE statements)
- GROUP BY and HAVING clauses

## How to Run

### Online SQL Compiler (We Used)
1. Go to https://sqliteonline.com/
2. Copy the entire script from `sql_queries.sql`
3. Paste and click "Run"
4. All tables will be created, data inserted, and queries executed


## 📸 Execution Screenshots
All screenshots of executed queries on local machine are included in the `screenshots/` folder.

## Additional Insights

### Data Quality Observations:
- Total transactions: 7 records
- Refunded transactions: 3 (42.8%)
- Active stores: 6 (a, b, d, e, f, g)
- Date range: Sept 2019 - Oct 2020
