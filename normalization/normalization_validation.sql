-- ============================================================
-- File: normalization.sql
-- Database: foodgo
-- Normalization analysis by: Supriya
--
-- PURPOSE
-- Explain 1NF, 2NF and 3NF using the existing FoodGo tables.
-- Show how data can be separated and checked after separation.
--
-- SAFETY
-- This script only reads and checks the existing data.
-- It does not create, change or delete any database data or tables.
--
-- IMPORTANT
-- This is only a normalization analysis and demonstration.
-- The original FoodGo database remains unchanged.
-- The checks are based on the current sample data.
-- ============================================================


-- ============================================================
-- N01. ENVIRONMENT
-- Check that we are using the correct FoodGo database
-- and check the current MySQL settings.
-- ============================================================

SELECT
    'N01: Environment' AS demonstration,
    DATABASE() AS database_name,
    VERSION() AS mysql_version,
    @@SESSION.foreign_key_checks AS foreign_key_checks;


-- ============================================================
-- N02. EXISTING BASE TABLES
-- Check and display all existing tables in the FoodGo database.
-- Expected: 10 tables.
-- ============================================================

SELECT
    TABLE_NAME AS table_name
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'foodgo'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


-- ============================================================
-- N03. PRIMARY AND UNIQUE KEYS
-- Display all primary and unique constraints in the FoodGo tables.
--
-- Candidate keys are columns that can uniquely identify a record.
-- customer_id and phone_num uniquely identify customers.
-- partner_id and phone_num uniquely identify delivery partners.
-- deliveries, payments and reviews have unique IDs and order_id.
-- order_items uses (order_id, item_id) as a composite primary key.
-- ============================================================


SELECT
    tc.TABLE_NAME AS table_name,
    tc.CONSTRAINT_NAME AS constraint_name,
    tc.CONSTRAINT_TYPE AS constraint_type,
    kcu.COLUMN_NAME AS key_column,
    kcu.ORDINAL_POSITION AS position_in_key,
    col.IS_NULLABLE AS is_nullable
FROM information_schema.TABLE_CONSTRAINTS AS tc
JOIN information_schema.KEY_COLUMN_USAGE AS kcu
    ON kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
   AND kcu.TABLE_NAME = tc.TABLE_NAME
   AND kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
JOIN information_schema.COLUMNS AS col
    ON col.TABLE_SCHEMA = kcu.TABLE_SCHEMA
   AND col.TABLE_NAME = kcu.TABLE_NAME
   AND col.COLUMN_NAME = kcu.COLUMN_NAME
WHERE tc.CONSTRAINT_SCHEMA = 'foodgo'
  AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'UNIQUE')
ORDER BY
    tc.TABLE_NAME,
    tc.CONSTRAINT_NAME,
    kcu.ORDINAL_POSITION;

-- ============================================================
-- NORMALIZATION STARTING POINT: UNF
--
-- This is an example of how an order could look before normalization.
-- Multiple items are stored together in one repeating group.
-- This repeating group is the main UNF problem.
-- We use this only as an example and do not create an UNF table.
-- ============================================================

-- ============================================================
-- N04. FIRST NORMAL FORM: ONE ROW PER ORDERED ITEM
--
-- Example: Sneha places Order 2 from a restaurant.
-- She buys 3 units of item 74 and 2 units of item 77.
-- Instead of storing both items together, we store each
-- ordered item in a separate row.
--
-- This makes every value atomic and demonstrates 1NF.
-- The data still has partial dependencies, so it is not yet 2NF.
--
-- Expected: 2 rows.
-- ============================================================
-- ============================================================



SELECT
    o.order_id,
    oi.item_id,
    o.order_time,
    o.customer_id,
    c.name AS customer_name,
    o.restaurant_id,
    r.name AS restaurant_name,
    mi.name AS item_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
JOIN restaurants AS r
    ON r.restaurant_id = o.restaurant_id
JOIN order_items AS oi
    ON oi.order_id = o.order_id
JOIN menu_items AS mi
    ON mi.item_id = oi.item_id
WHERE o.order_id = 2
ORDER BY oi.item_id;

-- ============================================================
-- SECOND NORMAL FORM
--
-- Example: Sneha's Order 2 contains two items.
-- We separate the information into three parts:
-- 1. Information about the order
-- 2. Information about each menu item
-- 3. Information about a specific item in that order
--
-- This removes information that depends only on part of
-- the combined order-item key and demonstrates 2NF.
-- ============================================================


-- ============================================================
-- N05. 2NF: ORDER-LEVEL FACTS
--
-- Example: Sneha's Order 2 has one customer, restaurant,
-- address, order time, status and total amount.
-- These details belong to the order itself, so we store them
-- once instead of repeating them for every item.
--
-- Expected: 1 row.
-- ============================================================


SELECT
    order_id,
    customer_id,
    restaurant_id,
    address_id,
    order_time,
    status,
    total_amount
FROM orders
WHERE order_id = 2;

-- ============================================================
-- N06. 2NF: ITEM-LEVEL FACTS
--
-- Example: Sneha ordered item 74 and item 77.
-- Each item has its own restaurant, name, price and veg status.
-- These details belong to the item itself, not to the order.
--
-- Expected: item IDs 74 and 77.
-- ============================================================


SELECT
    mi.item_id,
    mi.restaurant_id,
    mi.name,
    mi.price,
    mi.is_veg
FROM menu_items AS mi
WHERE EXISTS (
    SELECT 1
    FROM order_items AS oi
    WHERE oi.order_id = 2
      AND oi.item_id = mi.item_id
)
ORDER BY mi.item_id;

-- ============================================================
-- N07. 2NF: ORDER-ITEM FACTS
--
-- Example: In Sneha's Order 2, item 74 was ordered 3 times
-- at ₹299 each, while item 77 was ordered 2 times at ₹449 each.
-- Quantity and purchase price depend on both the order and item.
--
-- The stored unit price is the price paid at that time,
-- because the menu price may change later.
-- ============================================================


SELECT
    order_id,
    item_id,
    quantity,
    unit_price
FROM order_items
WHERE order_id = 2
ORDER BY item_id;

-- ============================================================
-- THIRD NORMAL FORM
--
-- Example: Sneha's order contains an address.
-- The address already tells us which customer owns it.
-- So the customer's information can be obtained through
-- the address instead of storing it again in the order.
--
-- Customer details belong in customers.
-- Restaurant details belong in restaurants.
-- Address details belong in addresses.
--
-- The following queries check this relationship without
-- changing our actual FoodGo tables.
-- ============================================================



-- ============================================================
-- N08. CHECK ADDRESS OWNERSHIP
--
-- Example: Address 9 is used by Order 1 and Order 4.
-- Both orders belong to Customer 8 in our sample data.
-- This shows that one address can be used by multiple orders.
--
-- Expected: 2 rows.
-- ============================================================


SELECT
    o.order_id,
    o.address_id,
    o.customer_id AS stored_order_customer,
    a.customer_id AS address_owner
FROM orders AS o
JOIN addresses AS a
    ON a.address_id = o.address_id
WHERE o.address_id = 9
ORDER BY o.order_id;

-- ============================================================
-- N09. CHECK THE ADDRESS-OWNER RELATIONSHIP
--
-- We check whether every order's customer matches
-- the customer who owns its address.
--
-- This checks our current data but does not automatically
-- prevent incorrect data from being entered in the future.
--
-- Expected:
-- checked_orders = 40
-- missing_address_orders = 0
-- ownership_mismatches = 0
-- ============================================================

SELECT
    COUNT(*) AS checked_orders,
    COUNT(
        CASE
            WHEN a.address_id IS NULL THEN 1
        END
    ) AS missing_address_orders,
    COUNT(
        CASE
            WHEN a.address_id IS NOT NULL
             AND o.customer_id <> a.customer_id
            THEN 1
        END
    ) AS ownership_mismatches
FROM orders AS o
LEFT JOIN addresses AS a
    ON a.address_id = o.address_id;

-- ============================================================
-- N10. 3NF ORDER-HEADER PROJECTION
--
-- Example: For Sneha's Order 2, we keep the order details
-- such as restaurant, address, time, status and total amount.
-- Customer information can be found through the address,
-- so we don't repeat customer_id here.
--
-- total_amount is kept because it stores the amount recorded
-- for that order.
--
-- This query only demonstrates the idea; it does not change
-- the actual orders table.
--
-- Expected: 1 row for Order 2.
-- ============================================================


SELECT
    order_id,
    restaurant_id,
    address_id,
    order_time,
    status,
    total_amount
FROM orders
WHERE order_id = 2;

-- ============================================================
-- N11. 3NF: ADDRESS FACTS
--
-- Example: Sneha's Order 2 uses Address 6.
-- Address 6 tells us the customer who owns it and also stores
-- the street, area, city and pincode.
--
-- These details belong to the address, so we keep them
-- in the addresses table.
--
-- Expected: Address 6, Customer 5.
-- ============================================================

SELECT
    a.address_id,
    a.customer_id,
    a.line1,
    a.area,
    a.city,
    a.pincode
FROM addresses AS a
JOIN orders AS o
    ON o.address_id = a.address_id
WHERE o.order_id = 2;

-- ============================================================
-- N12. 3NF: CUSTOMER FACTS
--
-- Example: Customer 5 is Sneha Nair.
-- The customer's name, phone and email belong to the customer,
-- so they are stored in the customers table.
--
-- We display only the ID and name here to keep contact details
-- private in the screenshots.
--
-- Expected: Customer 5, Sneha Nair.
-- ============================================================

SELECT
    c.customer_id,
    c.name
FROM orders AS o
JOIN addresses AS a
    ON a.address_id = o.address_id
JOIN customers AS c
    ON c.customer_id = a.customer_id
WHERE o.order_id = 2;

-- ============================================================
-- N13. 3NF: RESTAURANT FACTS
--
-- Example: Order 2 is from Restaurant 8,
-- The Garden Continental.
-- Its name, cuisine, city and active status belong to the
-- restaurant, so we keep them in the restaurants table.
--
-- Expected: Restaurant 8, The Garden Continental.
-- ============================================================

SELECT
    r.restaurant_id,
    r.name,
    r.cuisine,
    r.city,
    r.is_active
FROM restaurants AS r
JOIN orders AS o
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_id = 2;

-- ============================================================
-- EXTRA CONTRIBUTION 1: LOSSLESS RECONSTRUCTION
--
-- Example: We temporarily leave customer_id out of the order
-- information and then use the address to find the customer.
--
-- We compare the reconstructed order with the original order
-- to check whether we can get the same information back.
--
-- This is only a check; the actual orders table is not changed.
-- ============================================================



-- ============================================================
-- N14. RECONSTRUCTION SUMMARY
--
-- We compare the original orders with the reconstructed orders.
-- If both contain the same information, reconstruction was
-- successful.
--
-- Expected:
-- original_orders = 40
-- reconstructed_orders = 40
-- mismatched_headers = 0
-- ============================================================

WITH normalized_order_projection AS (
    SELECT
        order_id,
        restaurant_id,
        address_id,
        order_time,
        status,
        total_amount
    FROM orders
),
reconstructed_orders AS (
    SELECT
        n.order_id,
        a.customer_id,
        n.restaurant_id,
        n.address_id,
        n.order_time,
        n.status,
        n.total_amount
    FROM normalized_order_projection AS n
    JOIN addresses AS a
        ON a.address_id = n.address_id
)
SELECT
    (SELECT COUNT(*) FROM orders) AS original_orders,

(SELECT COUNT(*) FROM reconstructed_orders)
        AS reconstructed_orders,

(
        SELECT COUNT(*)
        FROM orders AS original
        LEFT JOIN reconstructed_orders AS rebuilt
            ON rebuilt.order_id = original.order_id
        WHERE rebuilt.order_id IS NULL
           OR NOT (
               original.customer_id <=> rebuilt.customer_id
           )
           OR NOT (
               original.restaurant_id <=> rebuilt.restaurant_id
           )
           OR NOT (
               original.address_id <=> rebuilt.address_id
           )
           OR NOT (
               original.order_time <=> rebuilt.order_time
           )
           OR NOT (
               original.status <=> rebuilt.status
           )
           OR NOT (
               original.total_amount <=> rebuilt.total_amount
           )
    ) AS mismatched_headers;

-- ============================================================
-- EXTRA CONTRIBUTION 2:
-- PRICE SNAPSHOT AND DERIVED-TOTAL ANALYSIS
--
-- menu_items.price:
--   current catalog price.
--
-- order_items.unit_price:
--   historical price accepted for a particular order line.
--
-- They are different temporal facts, not needless duplication.
--
-- A historical price need not equal the current menu price.
-- Do not replace historical prices with current catalog prices.
-- ============================================================

-- ============================================================
-- N15. CURRENT PRICE VS HISTORICAL PRICE
--
-- Example: Sneha bought item 74 and item 77 in Order 2.
-- We show the current menu price and the price Sneha actually
-- paid when she placed the order.
--
-- The two prices happen to be the same in our sample data,
-- but they represent different information.
-- ============================================================



SELECT
    oi.order_id,
    oi.item_id,
    mi.name AS item_name,
    mi.price AS current_menu_price,
    oi.unit_price AS historical_unit_price,
    oi.quantity,
    oi.quantity * oi.unit_price AS line_amount
FROM order_items AS oi
JOIN menu_items AS mi
    ON mi.item_id = oi.item_id
WHERE oi.order_id = 2
ORDER BY oi.item_id;

-- ============================================================
-- N16. STORED TOTAL VS CALCULATED TOTAL
--
-- Example: Sneha's Order 2 has a stored total of ₹1795.
-- We calculate the total again using the quantity and the
-- historical price paid for each item.
--
-- If both totals are the same, the order total is consistent.
-- Expected difference: ₹0.
-- ============================================================

SELECT
    o.order_id,
    o.total_amount AS stored_total,
    SUM(oi.quantity * oi.unit_price) AS calculated_total,
    o.total_amount
        - SUM(oi.quantity * oi.unit_price) AS difference
FROM orders AS o
JOIN order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_id = 2
GROUP BY
    o.order_id,
    o.total_amount;

-- ============================================================
-- N17. CHECK ALL ORDER TOTALS
--
-- We check every order to make sure its stored total matches
-- the total calculated from its ordered items.
--
-- We also check whether any order has no items.
--
-- Expected:
-- checked_orders = 40
-- orders_without_items = 0
-- mismatched_totals = 0
-- ============================================================
WITH calculated_totals AS (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS calculated_total
    FROM order_items
    GROUP BY order_id
)
SELECT
    COUNT(*) AS checked_orders,

COUNT(
        CASE
            WHEN t.order_id IS NULL THEN 1
        END
    ) AS orders_without_items,

COUNT(
        CASE
            WHEN t.order_id IS NOT NULL
             AND o.total_amount <> t.calculated_total
            THEN 1
        END
    ) AS mismatched_totals

FROM orders AS o
LEFT JOIN calculated_totals AS t
    ON t.order_id = o.order_id;

-- ============================================================
-- EXTRA CONTRIBUTION 3: BUSINESS-RULE CHECK
--
-- Example: An order belongs to one restaurant, and every menu
-- item also belongs to a restaurant.
--
-- We check that the restaurant of the order matches the
-- restaurant of each item ordered.
-- ============================================================

-- ============================================================
-- N18. ORDER-ITEM RESTAURANT CONSISTENCY
--
-- We check every ordered item to make sure:
-- 1. The order exists.
-- 2. The menu item exists.
-- 3. The order's restaurant matches the item's restaurant.
--
-- Expected:
-- checked_order_items = 74
-- missing_parent_lines = 0
-- restaurant_mismatches = 0
-- ============================================================

SELECT
    COUNT(*) AS checked_order_items,

COUNT(
        CASE
            WHEN o.order_id IS NULL
              OR mi.item_id IS NULL
            THEN 1
        END
    ) AS missing_parent_lines,

COUNT(
        CASE
            WHEN o.order_id IS NOT NULL
             AND mi.item_id IS NOT NULL
             AND o.restaurant_id <> mi.restaurant_id
            THEN 1
        END
    ) AS restaurant_mismatches

FROM order_items AS oi
LEFT JOIN orders AS o
    ON o.order_id = oi.order_id
LEFT JOIN menu_items AS mi
    ON mi.item_id = oi.item_id;

-- ============================================================
-- N19. FINAL DATA INVENTORY
--
-- We count the rows in all 10 FoodGo tables to confirm that
-- the original data is still unchanged.
--
-- Expected total: 347 rows across 10 tables.
-- ============================================================



WITH row_counts AS (
    SELECT 'customers' AS table_name, COUNT(*) AS row_count
    FROM customers

UNION ALL
    SELECT 'addresses', COUNT(*) FROM addresses

UNION ALL
    SELECT 'restaurants', COUNT(*) FROM restaurants

UNION ALL
    SELECT 'menu_items', COUNT(*) FROM menu_items

UNION ALL
    SELECT 'delivery_partners', COUNT(*)
    FROM delivery_partners

UNION ALL
    SELECT 'orders', COUNT(*) FROM orders

UNION ALL
    SELECT 'order_items', COUNT(*) FROM order_items

UNION ALL
    SELECT 'deliveries', COUNT(*) FROM deliveries

UNION ALL
    SELECT 'payments', COUNT(*) FROM payments

UNION ALL
    SELECT 'reviews', COUNT(*) FROM reviews
)
SELECT
    table_name,
    row_count
FROM row_counts

UNION ALL

SELECT
    'TOTAL',
    SUM(row_count)
FROM row_counts;

-- ============================================================
-- FINAL NORMALIZATION CONCLUSION
--
-- Our analysis shows that the FoodGo tables are largely
-- organized according to 3NF.
--
-- Customers, addresses, restaurants, menu items and other
-- related information are stored separately to avoid
-- unnecessary repetition.
--
-- One important case is the orders table:
-- an order has a customer and an address, and the address
-- already belongs to that customer.
--
-- So, if we strictly follow this business rule, customer
-- information can be obtained through the address, creating
-- a transitive dependency in the original orders table.
--
-- We demonstrate how this could be separated and reconstructed,
-- but we do not change the actual FoodGo database.
--
-- END
-- ============================================================
