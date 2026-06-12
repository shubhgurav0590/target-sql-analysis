-- ============================================================
-- Target Brazil E-Commerce — SQL Analysis (BigQuery)
-- Dataset: target_sql (customers, orders, order_items, payments)
-- Tool: Google BigQuery
-- ============================================================


-- ============================================================
-- SECTION I: INITIAL EXPLORATION
-- ============================================================

-- A. Data types of all columns in the customers table
SELECT column_name, data_type
FROM target_sql.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'customers';
-- INSIGHT: Columns are STRING and INTEGER data types

-- B. Time range of orders placed
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM `my-project-sql396802.target_sql.orders`;
-- INSIGHT: First order on 4th September 2016, last order on 17th October 2018

-- C. Count of unique cities and states of customers
SELECT
    COUNT(DISTINCT customer_city) AS cities,
    COUNT(DISTINCT customer_state) AS states
FROM `target_sql.customers`;
-- INSIGHT: 4119 unique cities and 27 unique states


-- ============================================================
-- SECTION II: EVOLUTION OF E-COMMERCE ORDERS IN BRAZIL
-- ============================================================

-- A. Unique customers per state
SELECT
    COUNT(DISTINCT customer_id) AS unique_customer,
    customer_state
FROM `my-project-sql-396802.target_sql.customers`
GROUP BY customer_state;
-- INSIGHT: SP has the highest number of unique customers (41,746)

-- B. Month-on-month orders placed in each state
SELECT
    COUNT(*) AS no_of_orders,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    c.customer_state AS state
FROM `target_sql.orders` AS o
INNER JOIN `target_sql.customers` AS c
    ON o.customer_id = c.customer_id
GROUP BY month, state
ORDER BY month, state;
-- INSIGHT: SP consistently leads in order volume across all months

-- C. Orders by time of day (Dawn / Morning / Afternoon / Night)
WITH base AS (
    SELECT
        EXTRACT(HOUR FROM order_purchase_timestamp) AS hour,
        COUNT(order_id) AS orders
    FROM `target_sql.orders`
    GROUP BY hour
)
SELECT
    SUM(CASE WHEN hour BETWEEN 0  AND 6  THEN orders ELSE 0 END) AS Dawn,
    SUM(CASE WHEN hour BETWEEN 7  AND 12 THEN orders ELSE 0 END) AS Morning,
    SUM(CASE WHEN hour BETWEEN 13 AND 18 THEN orders ELSE 0 END) AS Afternoon,
    SUM(CASE WHEN hour BETWEEN 19 AND 23 THEN orders ELSE 0 END) AS Night
FROM base;
-- INSIGHT: Afternoon (38,135) is the peak ordering period, followed by Night (28,331)


-- ============================================================
-- SECTION III: IMPACT ON ECONOMY
-- ============================================================

-- A. Year-on-year percentage increase in order payments (Jan–Aug)
WITH base AS (
    SELECT
        EXTRACT(YEAR  FROM order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
        SUM(p.payment_value) AS payments
    FROM `target_sql.orders` o
    INNER JOIN `target_sql.payments` p ON o.order_id = p.order_id
    WHERE EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY year, month
    ORDER BY year, month
),
grouped AS (
    SELECT year, SUM(payments) AS payments
    FROM base
    GROUP BY year
),
leads AS (
    SELECT *, LEAD(payments, 1) OVER (ORDER BY year ASC) AS next_year_payment
    FROM grouped
)
SELECT *,
    CONCAT(ROUND((next_year_payment - payments) / payments * 100, 2), ' %') AS per_inc
FROM leads;
-- INSIGHT: 136.98% increase in payments from 2017 to 2018

-- B. Total and average order price per state
SELECT
    SUM(ot.price)  AS Total_price,
    AVG(ot.price)  AS Avg_price,
    c.customer_state AS State
FROM `target_sql.order_items` AS ot
INNER JOIN `target_sql.orders`    AS o ON ot.order_id    = o.order_id
INNER JOIN `target_sql.customers` AS c ON o.customer_id  = c.customer_id
GROUP BY State
ORDER BY State;
-- INSIGHT: SP has highest total order value; smaller states have higher average order values

-- C. Total and average freight value per state
SELECT
    SUM(ot.freight_value) AS Total_freight_value,
    AVG(ot.freight_value) AS Avg_freight_value,
    c.customer_state AS State
FROM `target_sql.order_items` AS ot
INNER JOIN `target_sql.orders`    AS o ON ot.order_id   = o.order_id
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY State
ORDER BY State;
-- INSIGHT: Remote states like RR, PB, RO have highest average freight values


-- ============================================================
-- SECTION IV: DELIVERY TIME ANALYSIS
-- ============================================================

-- A. Top 5 states with highest average delivery time
SELECT
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS average_delivery_time,
    c.customer_state AS state
FROM `target_sql.orders` AS o
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY average_delivery_time DESC
LIMIT 5;
-- INSIGHT: RR, AP, AM, AL, PA have the highest delivery times (remote/northern states)

-- B. Top 5 states with lowest average delivery time
SELECT
    AVG(o.order_delivered_customer_date - o.order_purchase_timestamp) AS average_delivery_time,
    c.customer_state AS state
FROM `target_sql.orders` AS o
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY average_delivery_time ASC
LIMIT 5;
-- INSIGHT: SP, PR, MG, DF, SC have the lowest delivery times (southern/urban states)

-- C. Top 5 states with lowest average freight value
SELECT
    AVG(ot.freight_value) AS average,
    c.customer_state AS state
FROM `target_sql.order_items` AS ot
INNER JOIN `target_sql.orders`    AS o ON ot.order_id   = o.order_id
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY average ASC
LIMIT 5;
-- INSIGHT: SP, PR, MG, RJ, DF have lowest freight — logistically well-connected states

-- D. Top 5 states with highest average freight value
SELECT
    AVG(ot.freight_value) AS average,
    c.customer_state AS state
FROM `target_sql.order_items` AS ot
INNER JOIN `target_sql.orders`    AS o ON ot.order_id   = o.order_id
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY state
ORDER BY average DESC
LIMIT 5;
-- INSIGHT: RR, PB, RO, AC, PI have highest freight — remote/underdeveloped logistics


-- ============================================================
-- SECTION V: PAYMENT ANALYSIS
-- ============================================================

-- A. Orders by number of payment installments
SELECT
    COUNT(order_id) AS No_of_orders,
    payment_installments AS Installment
FROM `target_sql.payments`
WHERE payment_installments >= 1
GROUP BY Installment
ORDER BY Installment;
-- INSIGHT: Most orders (52,546) are paid in 1 installment; installment usage drops sharply after 10

-- B. Orders by payment type per month
SELECT
    COUNT(*) AS No_of_orders,
    p.payment_type,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS Month
FROM `target_sql.payments` AS p
INNER JOIN `target_sql.orders`    AS o ON p.order_id    = o.order_id
INNER JOIN `target_sql.customers` AS c ON o.customer_id = c.customer_id
GROUP BY payment_type, Month
ORDER BY payment_type, Month;
-- INSIGHT: Credit card dominates all months; UPI and voucher usage is consistent but smaller
