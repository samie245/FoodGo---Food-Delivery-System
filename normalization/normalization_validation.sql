-- FoodGo Database Normalization Validation
-- This file validates 1NF, 2NF and 3NF-related conditions
-- without modifying the existing database.

-- 1. Check that each order item has a unique (order_id, item_id) combination
SELECT order_id, item_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, item_id
HAVING COUNT(*) > 1;


-- 2. Check for invalid/orphan customer references in orders
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 3. Check the transitive dependency:
-- address_id -> customer_id
-- Verify that an order's customer matches the customer who owns its address
SELECT
    o.order_id,
    o.customer_id AS order_customer,
    a.customer_id AS address_customer,
    o.address_id
FROM orders o
JOIN addresses a
    ON o.address_id = a.address_id
WHERE o.customer_id <> a.customer_id;


-- 4. Check for orphan menu items in order_items
SELECT oi.order_id, oi.item_id
FROM order_items oi
LEFT JOIN menu_items mi
    ON oi.item_id = mi.item_id
WHERE mi.item_id IS NULL;


-- 5. Validate stored order totals against order_items
SELECT
    o.order_id,
    o.total_amount AS stored_total,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS calculated_total
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> COALESCE(SUM(oi.quantity * oi.unit_price), 0);


-- 6. Check that delivery records refer to valid orders
SELECT d.delivery_id, d.order_id
FROM deliveries d
LEFT JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 7. Check that payment records refer to valid orders
SELECT p.payment_id, p.order_id
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 8. Check that review records refer to valid orders
SELECT r.review_id, r.order_id
FROM reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 9. Check whether a delivery is duplicated for the same order
SELECT order_id, COUNT(*) AS delivery_count
FROM deliveries
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 10. Check whether a payment is duplicated for the same order
SELECT order_id, COUNT(*) AS payment_count
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1;


-- 11. Check whether a review is duplicated for the same order
SELECT order_id, COUNT(*) AS review_count
FROM reviews
GROUP BY order_id
HAVING COUNT(*) > 1;
