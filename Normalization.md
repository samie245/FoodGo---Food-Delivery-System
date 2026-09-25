# FoodGo Database Normalization

## 1. Objective

The FoodGo database is designed to organize customer, restaurant, menu, order, delivery, payment and review information with minimum redundancy and good data integrity.

The normalization analysis checks the database up to Third Normal Form (3NF).

## 2. Functional Dependencies

### Customers

**Primary Key:** `customer_id`

`customer_id → name, phone, email`

### Addresses

**Primary Key:** `address_id`

`address_id → customer_id, line1, area, city, pincode`

### Restaurants

**Primary Key:** `restaurant_id`

`restaurant_id → name, cuisine, city, is_active`

### Menu Items

**Primary Key:** `item_id`

`item_id → restaurant_id, name, price, is_veg`

### Delivery Partners

**Primary Key:** `partner_id`

`partner_id → name, phone, vehicle_type`

### Orders

**Primary Key:** `order_id`

`order_id → customer_id, restaurant_id, address_id, order_time, status, total_amount`

Since `address_id → customer_id`, the current design contains:

`order_id → address_id → customer_id`

This is reviewed as a transitive dependency during the 3NF analysis.

### Order Items

**Composite Primary Key:** `(order_id, item_id)`

`(order_id, item_id) → quantity, unit_price`

`unit_price` stores the historical price at the time of ordering.

### Deliveries

**Primary Key:** `delivery_id`

`delivery_id → order_id, partner_id, pickup_time, delivered_time`

`order_id` is UNIQUE, allowing at most one delivery per order.

### Payments

**Primary Key:** `payment_id`

`payment_id → order_id, amount, method, status`

`order_id` is UNIQUE, allowing at most one payment per order.

### Reviews

**Primary Key:** `review_id`

`review_id → order_id, restaurant_rating, delivery_rating, comment`

`order_id` is UNIQUE, allowing at most one review per order.

## 3. First Normal Form (1NF)

FoodGo follows 1NF because:

- Each column contains atomic values.
- There are no repeating groups.
- Each row can be uniquely identified.
- Multiple addresses are stored as separate rows in `addresses`.
- Multiple items in an order are stored as separate rows in `order_items`.

## 4. Second Normal Form (2NF)

FoodGo first satisfies 1NF.

Most tables use a single-column primary key, so partial dependencies do not occur.

The important case is `order_items`.

Primary key:

`(order_id, item_id)`

Functional dependency:

`(order_id, item_id) → quantity, unit_price`

Both non-key attributes depend on the complete composite key.

Therefore, `order_items` satisfies 2NF.

## 5. Third Normal Form (3NF)

FoodGo separates major entities into individual tables:

- Customer information → `customers`
- Address information → `addresses`
- Restaurant information → `restaurants`
- Menu information → `menu_items`
- Delivery partner information → `delivery_partners`
- Delivery information → `deliveries`
- Payment information → `payments`
- Review information → `reviews`

The current `orders` table contains both `customer_id` and `address_id`.

Since:

`address_id → customer_id`

and:

`order_id → address_id`

there is a transitive dependency:

`order_id → address_id → customer_id`

A normalized design can avoid storing `customer_id` redundantly in `orders` when the customer can be obtained through the selected address.

## 6. Order Total

The current `orders` table contains `total_amount`.

The `order_items` table contains `quantity` and `unit_price`.

The order total can be calculated using:

`SUM(quantity × unit_price)`

Therefore, `total_amount` is a derived value.

The stored total should be handled consistently with `order_items` to prevent discrepancies.

## 7. Price Snapshot

`menu_items.price` represents the current menu price.

`order_items.unit_price` represents the price at the time of the order.

This preserves historical order information when menu prices change.

Therefore, `unit_price` is treated as a valid historical price snapshot.

## 8. Anomalies Reduced

### Update Anomaly
Separating customer, restaurant, menu and delivery partner information reduces repeated data and makes updates easier.

### Insertion Anomaly
Separate tables allow customers, restaurants, menu items and delivery partners to be added independently.

### Deletion Anomaly
Separating entities prevents deleting one order from removing unrelated entity information.

## 9. Integrity Constraints

FoodGo uses:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `NOT NULL`
- `UNIQUE`
- `CHECK`
- `DEFAULT`

The `order_items` table uses the composite primary key `(order_id, item_id)`.

The `deliveries`, `payments` and `reviews` tables use UNIQUE constraints on `order_id` to enforce the intended at-most-one relationship per order.

## 10. Normalization Summary

| Normal Form | FoodGo Analysis |
|---|---|
| 1NF | Atomic values, no repeating groups and uniquely identifiable rows |
| 2NF | Non-key attributes depend on the complete key; `order_items` correctly uses its composite key |
| 3NF | Major entities are separated into appropriate tables; the current `orders` design has a transitive dependency involving `address_id` and `customer_id` |

## 11. Conclusion

The FoodGo database has been analyzed using functional dependencies and the principles of 1NF, 2NF and 3NF.

The design separates major entities into individual relations and uses a composite key for the many-to-many relationship between orders and menu items.

The main normalization refinement identified in the current schema is the redundant `customer_id` stored together with `address_id` in `orders`.

The stored `total_amount` is also a derived value from `order_items` and should be handled consistently to prevent discrepancies.

These points provide the basis for the final normalization and SQL validation of the FoodGo database.
