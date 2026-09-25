# FoodGo Database Normalization

## 1. Objective

The FoodGo database is designed to organize customer, restaurant, menu, order, delivery, payment and review information with minimum redundancy and good data integrity.

The normalization analysis checks the database up to Third Normal Form (3NF).

---

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

Since:

`address_id → customer_id`

and:

`order_id → address_id`

there is a transitive dependency:

`order_id → address_id → customer_id`

This is identified as a normalization refinement in the current design.

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

---

## 3. First Normal Form (1NF)

FoodGo follows 1NF because:

- Each column contains atomic values.
- There are no repeating groups.
- Each row can be uniquely identified.
- Multiple addresses are stored as separate rows in `addresses`.
- Multiple items in an order are stored as separate rows in `order_items`.

Therefore, the relations satisfy First Normal Form.

---

## 4. Second Normal Form (2NF)

FoodGo first satisfies 1NF.

Most tables use a single-column primary key, so partial dependencies do not occur.

The important case is `order_items`.

**Primary Key:**

`(order_id, item_id)`

**Functional Dependency:**

`(order_id, item_id) → quantity, unit_price`

Both non-key attributes depend on the complete composite key.

There is no dependency of `quantity` or `unit_price` on only `order_id` or only `item_id`.

Therefore, `order_items` satisfies 2NF.

---

## 5. Third Normal Form (3NF)

FoodGo separates major entities into individual relations:

- Customer information → `customers`
- Address information → `addresses`
- Restaurant information → `restaurants`
- Menu information → `menu_items`
- Delivery partner information → `delivery_partners`
- Delivery information → `deliveries`
- Payment information → `payments`
- Review information → `reviews`

This separation reduces unnecessary duplication and keeps attributes with the entity they describe.

### Transitive Dependency

In `addresses`:

`address_id → customer_id`

In `orders`:

`order_id → address_id`

Therefore:

`order_id → address_id → customer_id`

This is a transitive dependency in the current `orders` design.

A normalized refinement can avoid storing `customer_id` redundantly in `orders` when the customer can be obtained through the selected address.

---

## 6. Normalization Process Summary

| Normal Form | FoodGo Analysis |
|---|---|
| 1NF | Atomic values, no repeating groups and uniquely identifiable rows |
| 2NF | Partial dependencies are removed; `order_items` attributes depend on the complete composite key |
| 3NF | Major entities are separated into appropriate tables; the transitive dependency involving `address_id` and `customer_id` in `orders` is identified |

---

## 7. Order Total

The current `orders` table contains `total_amount`.

The `order_items` table contains:

- `quantity`
- `unit_price`

Therefore, the order total can be calculated using:

`SUM(quantity × unit_price)`

`total_amount` is a derived value.

The stored total was validated against the calculated total using SQL validation queries.

The current FoodGo data showed no mismatch between the stored and calculated totals.

---

## 8. Price Snapshot

`menu_items.price` represents the current menu price.

`order_items.unit_price` represents the price at the time the order was placed.

This preserves historical order information when menu prices change.

Therefore, `unit_price` is treated as a valid historical price snapshot rather than redundant data.

---

## 9. Anomalies Reduced

### Update Anomaly

Separating customer, restaurant, menu and delivery partner information reduces repeated data and makes updates easier.

### Insertion Anomaly

Separate tables allow customers, restaurants, menu items and delivery partners to be added independently.

### Deletion Anomaly

Separating entities prevents deleting one order from removing unrelated customer, restaurant or delivery partner information.

---

## 10. Integrity Constraints

FoodGo uses:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `NOT NULL`
- `UNIQUE`
- `CHECK`
- `DEFAULT`

The `order_items` table uses the composite primary key:

`(order_id, item_id)`

The `deliveries`, `payments` and `reviews` tables use UNIQUE constraints on `order_id` to enforce the intended at-most-one relationship per order.

Referential actions such as `ON DELETE` and `ON UPDATE` are also used where appropriate.

---

## 11. Normalization Validation

The normalization validation SQL checks the following:

1. Duplicate order items
2. Invalid customer references
3. Address/customer consistency
4. Orphan menu items
5. Stored order totals against calculated totals
6. Orphan deliveries
7. Orphan payments
8. Orphan reviews
9. Duplicate deliveries
10. Duplicate payments
11. Duplicate reviews

All 11 validation queries were executed on the FoodGo database.

The validation queries returned zero rows for the current sample data, indicating that no violations were found by these checks.

---

## 12. Conclusion

The FoodGo database has been analyzed using functional dependencies and the principles of 1NF, 2NF and 3NF.

The design separates major entities into individual relations and uses a composite key for the many-to-many relationship between orders and menu items.

The main normalization refinement identified in the current schema is the transitive dependency involving `address_id` and `customer_id` in `orders`.

The stored `total_amount` is also a derived value from `order_items` and has been validated against the calculated total.

The normalization validation queries provide additional checks for duplicate records, invalid references and consistency across related tables.
