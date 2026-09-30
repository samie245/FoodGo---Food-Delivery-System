-- ============================================================
-- File: normalization.sql
-- Database: foodgo
-- Normalization analysis by: Supriya
--
-- PURPOSE
-- Explain 1NF, 2NF and 3NF using the existing FoodGo tables.
-- Demonstrate decomposition and verify reconstruction.
--
-- SAFETY
-- No CREATE, ALTER, DROP, INSERT, UPDATE or DELETE.
-- No new database, table, view or procedure.
-- Existing data and schema remain unchanged.
--
-- IMPORTANT
-- This is an analysis/demonstration script, not a migration.
-- SQL checks test the supplied data; they do not prove that an
-- unenforced dependency holds in every possible future state.
--
-- Run against a stable copy of the supplied sample database.
-- Expected results assume the original seed is unchanged.
-- ============================================================

USE foodgo;

-- ============================================================
-- N01. ENVIRONMENT
-- Before we start our normalization checks, let's confirm that we're working in the correct database and know the current MySQL settings.
-- ============================================================

SELECT
    'N01: Environment' AS demonstration,
    DATABASE() AS database_name,
    VERSION() AS mysql_version,
    @@SESSION.foreign_key_checks AS foreign_key_checks;

-- ============================================================
-- N02. EXISTING BASE TABLES
-- Show all tables in FoodGo 
-- Expected: 10 rows, one per original table.
-- ============================================================

SELECT
    TABLE_NAME AS table_name
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'foodgo'
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- ============================================================
-- N03. PRIMARY AND UNIQUE KEYS
-- Display all primary and unique keys in the FoodGo tables
-- 
-- A candidate key is a minimal, mandatory unique identifier.
--
-- customers:
--   customer_id and phone are candidate keys.
--   email is nullable UNIQUE; do not treat it as a mandatory
--   relational candidate key.
--
-- delivery_partners:
--   partner_id and phone are candidate keys.
--
-- deliveries / payments / reviews:
--   Their primary ID and NOT NULL UNIQUE order_id are keys.
--
-- order_items:
--   Composite primary key = (order_id, item_id).
--
-- 
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
-- A hypothetical order form might contain:
--
-- OrderForm(
--   order_id,
--   customer_details,
--   restaurant_details,
--   items = [
--     {item_id, item_name, quantity, unit_price},
--     {item_id, item_name, quantity, unit_price},
--     ...
--   ]
-- )
--
-- The repeating items group is the conceptual UNF problem.
--
-- We do NOT create an unnecessary UNF table or store
-- comma-separated item lists in the working database.
-- ============================================================

-- ============================================================
-- N04. FIRST NORMAL FORM: ONE ROW PER ORDERED ITEM
--Take Order 2, collect its customer, restaurant and item information from the different tables, and show each ordered item as a separate row. This demonstrates the 1NF idea.”
-- Example: existing order 2.
--
-- This reconstructed flat relation has:
--   one item per row;
--   atomic values;
--   a row identifier of (order_id, item_id).
--
-- It illustrates 1NF, but contains partial dependencies:
--
--   order_id -> order_time, customer_id, restaurant_id
--   item_id  -> item_name
--
-- Therefore this flat teaching representation is not 2NF.
--
-- Expected: 2 rows.
--
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
-- A relation is in 2NF when:
--   it is in 1NF; and
--   no non-prime attribute depends on a proper subset
--   of a candidate key.
--
-- Decompose the flat order-line representation into:
--   order-level facts;
--   item-level facts;
--   facts specific to the complete order-item pair.
--
-- The following three queries use the same order 2.
-- ============================================================

-- ============================================================
-- N05. 2NF: ORDER-LEVEL FACTS
--
-- order_id -> customer_id, restaurant_id, address_id,
--             order_time, status, total_amount
--
-- Order-level facts do not need to repeat in every stored line.
--
-- Expected: 1 row.
-- 
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
-- item_id -> restaurant_id, name, price, is_veg
--
-- EXISTS selects the menu items used in order 2 without
-- duplicating menu rows.
--
-- Expected: item IDs 74 and 77.
-- 
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
-- N07. 2NF: COMPLETE COMPOSITE-KEY DEPENDENCY
--
-- (order_id, item_id) -> quantity, unit_price
--
-- quantity belongs to a specific item in a specific order.
-- unit_price is the historical purchase price for that line.
--
-- Do NOT assume:
--   item_id -> unit_price across all order history.
--
-- Current menu prices may change between orders.
--
-- Expected:
--   order 2, item 74, quantity 3, unit_price 299.00
--   order 2, item 77, quantity 2, unit_price 449.00
--
--
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
-- For every non-trivial dependency X -> A:
--   X must be a superkey, OR A must be a prime attribute.
--
-- Customer names belong in customers.
-- Restaurant names belong in restaurants.
-- Address details belong in addresses.
--
-- IMPORTANT BASELINE ISSUE
--
-- If an order must use an address owned by its customer:
--
--   order_id -> address_id
--   address_id -> customer_id
--
-- Therefore orders contains a transitive dependency.
--
-- The following queries demonstrate this and a possible
-- normalized projection WITHOUT changing the actual schema.
-- ============================================================

-- ============================================================
-- N08. EXAMINE ADDRESS OWNERSHIP IN THE SEED
--
-- Example: address 9 is used by orders 1 and 4.
-- Both orders belong to customer 8 in the supplied seed.
--
-- Repeated use of one address shows address_id is not
-- a unique identifier for orders.
--
-- Expected: 2 rows.
--
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
-- N09. CHECK THE ADDRESS-OWNER ASSUMPTION
--
-- These are DATA checks, not proof of enforcement.
-- Independent foreign keys do not enforce owner equality.
--
-- Expected:
--   checked_orders = 40
--   missing_address_orders = 0
--   ownership_mismatches = 0
--
--
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
-- customer_id is omitted from this SELECT because it can be
-- derived through addresses under the ownership assumption.
--
-- total_amount is retained here deliberately.
--
-- A stored cross-table aggregate is a consistency concern,
-- but is not automatically a within-relation 3NF violation.
--
-- This query does NOT remove any physical column.
--
-- Expected: 1 row for order 2.
--
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
-- address_id -> customer_id, line1, area, city, pincode
--
-- No additional dependency such as pincode -> city is assumed
-- for this project's normalization assessment.
--
-- Expected: address 6, customer 5.
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
-- customer_id -> name, phone, email
--
-- Only ID and name are displayed to avoid exposing contact
-- details in screenshots.
--
-- Expected: customer 5, Sneha Nair.
-- 
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
-- restaurant_id -> name, cuisine, city, is_active
--
-- Expected: restaurant 8, The Garden Continental.
-- 
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
-- EXTRA CONTRIBUTION 1:
-- LOSSLESS RECONSTRUCTION CHECK FOR ORDER HEADERS
--
-- A CTE is a statement-scoped query result, not a new table.
--
-- Step 1:
-- Project orders without customer_id.
--
-- Step 2:
-- Reconstruct customer_id by joining addresses.
--
-- Step 3:
-- Compare every reconstructed header with the original.
--
-- The join preserves one row per order because:
--   addresses.address_id is a primary key;
--   orders.address_id is a mandatory foreign key.
--
-- Recovering the SAME customer additionally requires the
-- ownership rule checked in N09.
--
-- This demonstrates reconstruction for the current data.
-- It does not mean the physical orders table was normalized.
-- ============================================================

-- ============================================================
-- N14. RECONSTRUCTION SUMMARY
--
-- <=> is MySQL's NULL-safe equality operator.
--
-- Expected:
--   original_orders = 40
--   reconstructed_orders = 40
--   mismatched_headers = 0
--
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
-- N15. SHOW CURRENT PRICE AND HISTORICAL PRICE
--
-- Expected: two rows for order 2.
-- They happen to match in this seed.
-- Matching sample values do not make them the same attribute.
--
-- 
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
-- N16. STORED TOTAL VERSUS CALCULATED TOTAL
--
-- Use historical unit_price, not menu_items.price.
--
-- No rows are modified.
--
-- Expected for order 2:
--   stored_total = 1795.00
--   calculated_total = 1795.00
--   difference = 0.00
--
-- 
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
-- LEFT JOIN also detects orders that have no order lines.
-- An order without lines is not silently treated as valid.
--
-- Expected:
--   checked_orders = 40
--   orders_without_items = 0
--   mismatched_totals = 0
--
-- This checks cross-table consistency.
-- It is NOT a standalone proof of 3NF.
--
-- 
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
-- EXTRA CONTRIBUTION 3:
-- DISTINGUISH NORMALIZATION FROM BUSINESS-RULE ENFORCEMENT
--
-- Each order belongs to one restaurant.
-- Each menu item also belongs to one restaurant.
--
-- The separate foreign keys do not automatically guarantee
-- that both restaurant IDs match for an ordered item.
--
-- A normalized structure can still need extra business checks.
-- ============================================================

-- ============================================================
-- N18. ORDER-ITEM RESTAURANT CONSISTENCY
--
-- Expected:
--   checked_order_items = 74
--   missing_parent_lines = 0
--   restaurant_mismatches = 0
--
-- 
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
-- This script contains only read operations and USE.
-- Counts below confirm the currently visible inventory.
--
-- Expected total: 347 rows across 10 tables.
-- 
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
-- Under the stated dependencies:
--
-- customers:
--   customer_id -> name, phone, email
--   phone -> customer_id, name, email
--
-- addresses:
--   address_id -> customer_id, line1, area, city, pincode
--
-- restaurants:
--   restaurant_id -> name, cuisine, city, is_active
--
-- menu_items:
--   item_id -> restaurant_id, name, price, is_veg
--
-- delivery_partners:
--   partner_id -> name, phone, vehicle_type
--   phone -> partner_id, name, vehicle_type
--
-- order_items:
--   (order_id, item_id) -> quantity, unit_price
--
-- deliveries:
--   delivery_id -> order_id, partner_id,
--                  pickup_time, delivered_time
--   order_id -> delivery_id, partner_id,
--               pickup_time, delivered_time
--
-- payments:
--   payment_id -> order_id, amount, method, status
--   order_id -> payment_id, amount, method, status
--
-- reviews:
--   review_id -> order_id, restaurant_rating,
--                delivery_rating, comment
--   order_id -> review_id, restaurant_rating,
--               delivery_rating, comment
--
-- These nine relations satisfy 3NF under those dependencies.
--
-- orders:
--   order_id -> customer_id, restaurant_id, address_id,
--               order_time, status, total_amount
--
-- IF order customer must equal the address owner:
--   address_id -> customer_id also holds by business meaning.
--
-- Because address_id is not an orders superkey and customer_id
-- is non-prime, the original orders relation is not strict 3NF
-- under that rule.
--
-- We demonstrated the normalized projection and reconstruction,
-- but deliberately preserved the original physical schema.
--
-- A future approved change could omit orders.customer_id and
-- derive it through addresses, provided address ownership is
-- immutable. Existing queries and application code would then
-- require review and testing.
--
-- END 
-- ============================================================
