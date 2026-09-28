-- ============================================================
-- FoodGo: Business Questions & Analytical Queries
-- ============================================================

USE foodgo;

-- ------------------------------------------------------------
-- Q1: What is the most ordered food item?
-- Concepts: JOIN, SUM(quantity), GROUP BY
-- ------------------------------------------------------------
SELECT 
    mi.item_id,
    mi.name AS item_name,
    r.name AS restaurant_name,
    SUM(oi.quantity) AS total_ordered
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
GROUP BY mi.item_id, mi.name, r.name
ORDER BY total_ordered DESC
LIMIT 1;

-- ------------------------------------------------------------
-- Q2: Which restaurant has the highest revenue?
-- Concepts: Multi-table JOIN, SUM, ranking
-- ------------------------------------------------------------
SELECT 
    r.restaurant_id,
    r.name AS restaurant_name,
    r.cuisine,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY r.restaurant_id, r.name, r.cuisine
ORDER BY total_revenue DESC
LIMIT 1;

-- ------------------------------------------------------------
-- Q3: What is the average order value?
-- Concepts: Subquery / CTE, AVG
-- ------------------------------------------------------------
WITH OrderTotals AS (
    SELECT 
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id
)
SELECT 
    ROUND(AVG(order_value), 2) AS average_order_value
FROM OrderTotals;

-- ------------------------------------------------------------
-- Q4: Who are the top customers by spend?
-- Concepts: Aggregation by customer, LIMIT
-- ------------------------------------------------------------
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 5;

-- ------------------------------------------------------------
-- Q5: What is the average delivery time?
-- Concepts: Time difference functions, AVG
-- ------------------------------------------------------------
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.pickup_time, d.delivered_time)), 2) AS avg_delivery_time_minutes
FROM deliveries d
JOIN orders o ON d.order_id = o.order_id
WHERE o.status = 'delivered'
  AND d.pickup_time IS NOT NULL 
  AND d.delivered_time IS NOT NULL;

-- ------------------------------------------------------------
-- Q6: Which restaurants have high ratings? (Average rating >= 4.0)
-- Concepts: AVG rating, HAVING
-- ------------------------------------------------------------
SELECT 
    r.restaurant_id,
    r.name AS restaurant_name,
    ROUND(AVG(rev.restaurant_rating), 2) AS avg_restaurant_rating,
    COUNT(rev.review_id) AS total_reviews
FROM reviews rev
JOIN orders o ON rev.order_id = o.order_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE rev.restaurant_rating IS NOT NULL
GROUP BY r.restaurant_id, r.name
HAVING AVG(rev.restaurant_rating) >= 4.0
ORDER BY avg_restaurant_rating DESC;

-- ------------------------------------------------------------
-- Q7: How many orders were cancelled?
-- Concepts: COUNT with WHERE / CASE on status
-- ------------------------------------------------------------
SELECT 
    COUNT(*) AS total_cancelled_orders,
    (SELECT COUNT(*) FROM orders) AS total_orders_placed,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM orders), 2) AS cancellation_percentage
FROM orders
WHERE status = 'cancelled';

-- ------------------------------------------------------------
-- Q8 [Extra]: What are the peak ordering hours?
-- Concepts: HOUR(), GROUP BY
-- ------------------------------------------------------------
SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(*) AS total_orders
FROM orders
GROUP BY HOUR(order_time)
ORDER BY total_orders DESC;

-- ------------------------------------------------------------
-- Q9 [Extra]: Delivery partner performance & speed ranking
-- Concepts: JOIN, AVG delivery duration, ranking
-- ------------------------------------------------------------
SELECT 
    dp.partner_id,
    dp.name AS partner_name,
    dp.vehicle_type,
    COUNT(d.delivery_id) AS completed_deliveries,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.pickup_time, d.delivered_time)), 2) AS avg_delivery_minutes
FROM delivery_partners dp
JOIN deliveries d ON dp.partner_id = d.partner_id
JOIN orders o ON d.order_id = o.order_id
WHERE o.status = 'delivered' AND d.delivered_time IS NOT NULL
GROUP BY dp.partner_id, dp.name, dp.vehicle_type
ORDER BY avg_delivery_minutes ASC;

-- ------------------------------------------------------------
-- Q10 [Extra]: Cuisine-wise revenue breakdown
-- Concepts: Multi-level GROUP BY, SUM
-- ------------------------------------------------------------
SELECT 
    r.cuisine,
    COUNT(DISTINCT r.restaurant_id) AS active_restaurants,
    COUNT(o.order_id) AS total_orders_delivered,
    SUM(oi.quantity * oi.unit_price) AS cuisine_revenue
FROM restaurants r
JOIN orders o ON r.restaurant_id = o.restaurant_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY r.cuisine
ORDER BY cuisine_revenue DESC;

-- ------------------------------------------------------------
-- Q11 [Extra]: Customers ordering from multiple different restaurants
-- Concepts: HAVING COUNT(DISTINCT ...)
-- ------------------------------------------------------------
SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.restaurant_id) AS unique_restaurants_tried
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT o.restaurant_id) > 1
ORDER BY unique_restaurants_tried DESC;

-- ------------------------------------------------------------
-- Q12 [Extra]: Total revenue lost due to order cancellations
-- Concepts: Conditional aggregation, JOIN
-- ------------------------------------------------------------
SELECT 
    COUNT(o.order_id) AS cancelled_order_count,
    SUM(o.total_amount) AS estimated_revenue_lost
FROM orders o
WHERE o.status = 'cancelled';