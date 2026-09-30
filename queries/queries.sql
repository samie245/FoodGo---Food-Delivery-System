-- ============================================================
-- FoodGo: Business Questions & Analytical Queries
-- queries/queries.sql
-- Created for Team 5 | DBMS Course Project
-- ============================================================

USE foodgo;

-- ------------------------------------------------------------
-- Q1: What is the most ordered food item?
-- ------------------------------------------------------------
SELECT 
    mi.item_id,                          -- Selects the unique item ID from menu items
    mi.name AS item_name,                -- Selects the dish name and renames it for the output
    r.name AS restaurant_name,           -- Selects the partner restaurant name
    SUM(oi.quantity) AS total_ordered    -- Adds up all quantities ordered for this dish across the platform
FROM order_items oi                      -- Starts from order_items (aliased as 'oi')
JOIN menu_items mi ON oi.item_id = mi.item_id -- Connects to menu_items matching item IDs
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id -- Connects to restaurants to get the venue name
GROUP BY mi.item_id, mi.name, r.name     -- Groups the aggregated sums by each unique dish
ORDER BY total_ordered DESC              -- Sorts the totals from highest to lowest
LIMIT 1;                                 -- Restricts the output to only the single top result

-- ------------------------------------------------------------
-- Q2: Which restaurant has the highest revenue?
-- ------------------------------------------------------------
SELECT 
    r.restaurant_id,                     -- Selects restaurant ID
    r.name AS restaurant_name,           -- Selects restaurant name
    r.cuisine,                           -- Selects cuisine type
    SUM(oi.quantity * oi.unit_price) AS total_revenue -- Multiplies quantity by historical price, then sums it up
FROM orders o                            -- Starts with orders table ('o')
JOIN restaurants r ON o.restaurant_id = r.restaurant_id -- Joins to match restaurant info
JOIN order_items oi ON o.order_id = oi.order_id -- Joins to grab the items inside those orders
WHERE o.status = 'delivered'             -- Filters to only include successfully delivered orders
GROUP BY r.restaurant_id, r.name, r.cuisine -- Groups revenue calculation per restaurant
ORDER BY total_revenue DESC              -- Sorts from highest revenue to lowest
LIMIT 1;                                 -- Returns only the top revenue generator

-- ------------------------------------------------------------
-- Q3: What is the average order value?
-- ------------------------------------------------------------
WITH OrderTotals AS (                    -- Creates a temporary result set (CTE) named OrderTotals
    SELECT 
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value -- Calculates total value per individual order
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'         -- Only looks at delivered orders
    GROUP BY o.order_id
)
SELECT 
    ROUND(AVG(order_value), 2) AS average_order_value -- Takes the mathematical average of all order values and rounds to 2 decimals
FROM OrderTotals;                        -- Pulls from our temporary CTE table

-- ------------------------------------------------------------
-- Q4: Who are the top customers by spend?
-- ------------------------------------------------------------
SELECT 
    c.customer_id,                       -- Customer ID
    c.name AS customer_name,             -- Customer name
    COUNT(DISTINCT o.order_id) AS total_orders, -- Counts unique orders placed
    SUM(oi.quantity * oi.unit_price) AS total_spent -- Sums total money spent on delivered items
FROM customers c                         -- Starts with customers ('c')
JOIN orders o ON c.customer_id = o.customer_id -- Joins to their orders
JOIN order_items oi ON o.order_id = oi.order_id -- Joins to order items for pricing
WHERE o.status = 'delivered'             -- Restricts to delivered orders
GROUP BY c.customer_id, c.name           -- Groups calculations per customer
ORDER BY total_spent DESC                -- Sorts from highest spender down
LIMIT 5;                                 -- Limits list to top 5 customers

-- ------------------------------------------------------------
-- Q5: What is the average delivery time?
-- ------------------------------------------------------------
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.pickup_time, d.delivered_time)), 2) AS avg_delivery_time_minutes 
    -- Calculates the difference in minutes between pickup and delivery, finds the average, and rounds it
FROM deliveries d                        -- Starts with deliveries table ('d')
JOIN orders o ON d.order_id = o.order_id -- Joins to orders
WHERE o.status = 'delivered'             -- Filters for delivered orders
  AND d.pickup_time IS NOT NULL          -- Ensures pickup time exists
  AND d.delivered_time IS NOT NULL;      -- Ensures drop-off time exists

-- ------------------------------------------------------------
-- Q6: Which restaurants have high ratings?
-- ------------------------------------------------------------
SELECT 
    r.restaurant_id,                     -- Restaurant ID
    r.name AS restaurant_name,           -- Restaurant name
    ROUND(AVG(rev.restaurant_rating), 2) AS avg_restaurant_rating, -- Averages their review scores
    COUNT(rev.review_id) AS total_reviews -- Counts how many reviews they received
FROM reviews rev                         -- Starts from reviews table ('rev')
JOIN orders o ON rev.order_id = o.order_id -- Joins to orders to trace back to the restaurant
JOIN restaurants r ON o.restaurant_id = r.restaurant_id -- Joins to restaurants
WHERE rev.restaurant_rating IS NOT NULL  -- Ignores empty ratings
GROUP BY r.restaurant_id, r.name         -- Groups by restaurant
HAVING AVG(rev.restaurant_rating) >= 4.0 -- Filters group results to keep only those averaging 4.0 or higher
ORDER BY avg_restaurant_rating DESC;     -- Sorts highest rated first

-- ------------------------------------------------------------
-- Q7: How many orders were cancelled?
-- ------------------------------------------------------------
SELECT 
    COUNT(*) AS total_cancelled_orders,  -- Counts total rows where status is cancelled
    (SELECT COUNT(*) FROM orders) AS total_orders_placed, -- Subquery counting absolute total orders
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM orders), 2) AS cancellation_percentage 
    -- Calculates cancellation rate as a percentage
FROM orders
WHERE status = 'cancelled';              -- Filters strictly for cancelled status

-- ------------------------------------------------------------
-- Q8 [Extra]: What are the peak ordering hours?
-- ------------------------------------------------------------
SELECT 
    HOUR(order_time) AS order_hour,      -- Extracts the hour (0-23) from the order timestamp
    COUNT(*) AS total_orders             -- Counts how many orders happened in that specific hour
FROM orders
GROUP BY HOUR(order_time)                -- Groups totals by each hour of the day
ORDER BY total_orders DESC;              -- Sorts from busiest hour to slowest

-- ------------------------------------------------------------
-- Q9 [Extra]: Delivery partner performance & speed ranking
-- ------------------------------------------------------------
SELECT 
    dp.partner_id,                       -- Partner ID
    dp.name AS partner_name,             -- Partner name
    dp.vehicle_type,                     -- Vehicle type (bike, scooter, etc.)
    COUNT(d.delivery_id) AS completed_deliveries, -- Count of completed deliveries
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.pickup_time, d.delivered_time)), 2) AS avg_delivery_minutes
    -- Averages their delivery speed in minutes
FROM delivery_partners dp
JOIN deliveries d ON dp.partner_id = d.partner_id
JOIN orders o ON d.order_id = o.order_id
WHERE o.status = 'delivered' AND d.delivered_time IS NOT NULL
GROUP BY dp.partner_id, dp.name, dp.vehicle_type
ORDER BY avg_delivery_minutes ASC;       -- Sorts fastest delivery times first

-- ------------------------------------------------------------
-- Q10 [Extra]: Cuisine-wise revenue breakdown
-- ------------------------------------------------------------
SELECT 
    r.cuisine,                           -- Cuisine type (South Indian, Chinese, etc.)
    COUNT(DISTINCT r.restaurant_id) AS active_restaurants, -- Counts unique restaurants in that cuisine
    COUNT(o.order_id) AS total_orders_delivered, -- Total successful orders for this cuisine
    SUM(oi.quantity * oi.unit_price) AS cuisine_revenue -- Total earnings for this cuisine category
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY r.cuisine                       -- Groups metrics by cuisine category
ORDER BY cuisine_revenue DESC;           -- Sorts highest earning cuisine first

-- ------------------------------------------------------------
-- Q11 [Extra]: Customers ordering from multiple different restaurants
-- ------------------------------------------------------------
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.restaurant_id) AS unique_restaurants_tried -- Counts distinct restaurants a user ordered from
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.restaurant_id) > 1 -- Filters out users who only ordered from 1 restaurant
ORDER BY unique_restaurants_tried DESC;

-- ------------------------------------------------------------
-- Q12 [Extra]: Total revenue lost due to order cancellations
-- ------------------------------------------------------------
SELECT 
    COUNT(o.order_id) AS cancelled_order_count, -- Counts total cancelled orders
    SUM(o.total_amount) AS estimated_revenue_lost -- Sums up the monetary value of those lost orders
FROM orders o
WHERE o.status = 'cancelled';            -- Targets only cancelled rows

-- ------------------------------------------------------------
-- Q13 [Extra]: What are the most popular payment methods?
-- ------------------------------------------------------------
SELECT 
    method,                              -- Payment method type (upi, card, cash, netbanking)
    COUNT(*) AS total_transactions,      -- Counts how many times this payment method was chosen
    SUM(amount) AS total_amount_processed -- Sums up total monetary volume processed via this method
FROM payments
GROUP BY method                          -- Groups the counts and sums by payment method
ORDER BY total_transactions DESC;        -- Sorts from most frequently used to least used

-- ------------------------------------------------------------
-- Q14 [Extra]: How do average restaurant ratings compare to delivery ratings?
-- ------------------------------------------------------------
SELECT 
    ROUND(AVG(restaurant_rating), 2) AS overall_avg_restaurant_score, -- Platform-wide average score for restaurants/food
    ROUND(AVG(delivery_rating), 2) AS overall_avg_delivery_score     -- Platform-wide average score for delivery service
FROM reviews
WHERE restaurant_rating IS NOT NULL 
  AND delivery_rating IS NOT NULL;       -- Filters out incomplete reviews to ensure a fair comparison

-- ------------------------------------------------------------
-- Q15 [Extra]: Which delivery vehicle type handles the most orders?
-- ------------------------------------------------------------
SELECT 
    dp.vehicle_type,                     -- Type of vehicle used by partners (bike, scooter, etc.)
    COUNT(d.delivery_id) AS total_deliveries -- Counts total deliveries completed by each vehicle type
FROM delivery_partners dp
JOIN deliveries d ON dp.partner_id = d.partner_id
GROUP BY dp.vehicle_type                 -- Groups delivery counts by vehicle category
ORDER BY total_deliveries DESC;          -- Sorts from highest volume vehicle type down