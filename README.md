# FoodGo --- Restaurant, Order & Delivery Management System

> Team 5 | DBMS Course Project

FoodGo is a MySQL-based relational database designed to model the core operations of a food-delivery platform. The system connects customers, delivery addresses, restaurants, menu items, orders, delivery partners, deliveries, payments and reviews in a structured relational model. The project focuses on ER modeling, relational schema design, functional dependencies, normalization, integrity constraints, realistic sample data and SQL-based business analysis.

Normalization note: The project includes a dedicated, read-only normalization.sql verification script. It demonstrates 1NF and 2NF, analyzes the dependencies relevant to 3NF, verifies lossless reconstruction, and checks price, total and cross-table consistency. Under the stated business dependency address_id → customer_id, the current physical orders table retains a transitive dependency, so the project does not claim that the entire current physical schema is strictly 3NF. The script documents this explicitly rather than silently changing the supplied schema.

### Team Members

| S.No. | Student Name | USN | Contributions |
|---:|---|---|----|
| 1 | Rehaan Saha | AU25UG-046 | Contributions for Documentation part and Scehema |
| 2 | S Thanmayee | AU25UG-049 | Documentation |
| 3 | Samhita Bhuvanagiri | AU25UG-050 | Schema, Table creation, constraints, Indexing |
| 4 | Sarang Siva Thilakan | AU25UG-054 | Queries |
| 5 | Shahiba Arshiya Banu | AU25UG-055 | ER-Diagram |
| 6 | Supriya R | AU25UG-058 | Normalization |

### 1. Project Overview

A food-delivery platform coordinates three major participants: Customers place orders and maintain delivery addresses. Restaurants provide menus and prepare orders. Delivery Partners handle order delivery.

FoodGo brings these activities together in one relational database. It stores customer information, saved addresses, restaurants, menu items, orders, order-line details, delivery assignments, payments and reviews.

The database was designed from the project requirements and the suggested FoodGo database specification, then implemented using MySQL.

### 2. Project Objectives

The main objectives are to:
- Design a realistic relational database for a food-delivery system.
- Identify entities, attributes, keys and relationships.
- Create an ER diagram with cardinalities and participation
- information.
- Convert the ER model into relational tables.
- Apply primary keys and foreign keys.
- Maintain data integrity using NOT NULL, UNIQUE, CHECK,
- DEFAULT and referential actions.

- Identify important functional dependencies.
- Demonstrate normalization through 1NF, 2NF and 3NF analysis.
- Insert realistic, referentially consistent sample data.
- Write SQL queries for practical business analysis.
- Verify important cross-table business rules.
- Maintain the complete project in a reproducible GitHub repository.

### 3. System Scope

#### Customer Management

- Store customer profiles.
- Maintain unique phone numbers and emails.
- Manage multiple saved delivery addresses.

#### Restaurant Management

- Store restaurant information.
- Maintain cuisine and city details.
- Track whether a restaurant is active.
- Store menu items and their current catalog prices.

#### Order Management

- Record customer orders.
- Associate orders with restaurants and delivery addresses.
- Store order status and order time.
- Store the total amount.
- Record the individual items included in each order.

#### Delivery Management

- Maintain delivery partner details.
- Assign delivery partners to orders.
- Record pickup and delivery timestamps.
- Allow at most one delivery record per order.

#### Payment Management

- Store payment amount and method.
- Track payment status.
- Allow at most one payment record per order in the current schema.

#### Review Management

- Store restaurant and delivery ratings.
- Store customer comments.
- Allow at most one review record per order in the current schema.

### 4. Technology Stack

| Layer | Technology |
|---|---|
| RDBMS | MySQL 8.x |
| Query Language | SQL |
| Schema / DDL | MySQL DDL |
| Data / DML | MySQL INSERT statements |
| Design | ER Diagram / Relational Schema |
| Documentation | Markdown |
| Repository | GitHub |

### 5. Repository Structure

```text
FoodGo/
├── README.md
│
├── schema/
│   └── create_tables.sql
│       └── Database, tables, keys and constraints
│
├── data/
│   └── insert_data.sql
│       └── Realistic sample data
│
├── queries/
│   └── queries.sql
│       └── Business and analytical SQL queries
│
├── normalization/
│   └── normalization.sql
│       └── Read-only 1NF, 2NF, 3NF analysis and verification
│
├── diagrams/
│   ├── ER_Diagram.png
│   └── Relational_Schema.png
│
└── docs/
    ├── Report.pdf
    └── Design_Rationale.md
```

Rename the files/folders above to match the exact names in the repository if your GitHub folder names are different.

### 6. Database Design

FoodGo contains the following 10 core tables:

| Table | Purpose |
|---|---|
| `customers` | Stores customer profiles and contact information |
| `addresses` | Stores saved delivery addresses belonging to customers |
| `restaurants` | Stores restaurant information |
| `menu_items` | Stores dishes offered by restaurants |
| `delivery_partners` | Stores delivery partner information |
| `orders` | Stores order-level information |
| `order_items` | Stores individual items within orders |
| `deliveries` | Stores delivery assignment and timing |
| `payments` | Stores payment information |
| `reviews` | Stores restaurant/delivery ratings and comments |

### 7. Table Attributes and Keys

#### customers

| Attribute | Description |
|---|---|
| `customer_id` | Primary key |
| `name` | Customer name |
| `phone` | Unique contact number |
| `email` | Unique email address |

Important constraints: customer_id is the primary key; phone and email have unique constraints.

#### addresses

| Attribute | Description |
|---|---|
| `address_id` | Primary key |
| `customer_id` | Foreign key referencing customers |
| `line1` | Address line |
| `area` | Area/locality |
| `city` | City |
| `pincode` | Postal code |

Relationship: One customer can have many addresses.

#### restaurants

| Attribute | Description |
|---|---|
| `restaurant_id` | Primary key |
| `name` | Restaurant name |
| `cuisine` | Cuisine type |
| `city` | Restaurant location |
| `is_active` | Indicates whether the restaurant is active |


#### menu_items

| Attribute | Description |
|---|---|
| `item_id` | Primary key |
| `restaurant_id` | Foreign key referencing restaurants |
| `name` | Food item name |
| `price` | Current catalog price |
| `is_veg` | Vegetarian/non-vegetarian indicator |

Relationship: One restaurant can offer many menu items.

#### delivery_partners

| Attribute | Description |
|---|---|
| `partner_id` | Primary key |
| `name` | Delivery partner name |
| `phone` | Unique contact number |
| `vehicle_type` | Bike, scooter, bicycle or car |


#### orders

| Attribute | Description |
|---|---|
| `order_id` | Primary key |
| `customer_id` | Foreign key referencing customers |
| `restaurant_id` | Foreign key referencing restaurants |
| `address_id` | Foreign key referencing addresses |
| `order_time` | Time when order was placed |
| `status` | Order lifecycle status |
| `total_amount` | Stored order total |

Allowed order statuses are:
- `placed`
- `preparing`
- `out_for_delivery`
- `delivered`
- `cancelled`

#### order_items

| Attribute | Description |
|---|---|
| `order_id` | Part of composite primary key; FK to orders |
| `item_id` | Part of composite primary key; FK to menu_items |
| `quantity` | Number of units ordered |
| `unit_price` | Price captured for the item at order time |

The primary key is:
```text
PRIMARY KEY (order_id, item_id)
```
This table resolves the many-to-many relationship between orders and menu items.

#### deliveries

| Attribute | Description |
|---|---|
| `delivery_id` | Primary key |
| `order_id` | Unique foreign key to orders |
| `partner_id` | Foreign key to delivery_partners |
| `pickup_time` | Pickup timestamp |
| `delivered_time` | Delivery completion timestamp |

The unique constraint on order_id means an order can have at most one delivery record.

#### payments

| Attribute | Description |
|---|---|
| `payment_id` | Primary key |
| `order_id` | Unique foreign key to orders |
| `amount` | Payment amount |
| `method` | Card, UPI, cash or netbanking |
| `status` | Pending, completed, failed or refunded |

The current schema permits at most one payment record per order. The foreign key/unique constraint does not by itself force every order to have a payment record.

#### reviews

| Attribute | Description |
|---|---|
| `review_id` | Primary key |
| `order_id` | Unique foreign key to orders |
| `restaurant_rating` | Rating from 1 to 5 |
| `delivery_rating` | Rating from 1 to 5 |
| `comment` | Customer feedback |

The current schema permits at most one review per order.

#### createtables:

In version 2 of our create_tables.sql file, we made some improvements without removing any existing functionality. The file increased from 198 lines to 284 lines.
First, we added three CHECK constraints to validate the format of important fields — customer phone numbers must contain 10 digits, address pincodes must contain 6 digits, and delivery partner phone numbers must contain 10 digits.
Next, we added two indexes on the orders table: one for order status and another for order time. These help improve the efficiency of queries that frequently search or sort orders using these columns.
We also added three triggers for the order_items table. These triggers automatically recalculate the order's total_amount whenever an order item is inserted, updated, or deleted. Before creating each trigger, we use DROP TRIGGER IF EXISTS so that the script can be safely executed again.
Finally, we added a changelog to document the modifications. The existing unique constraints were not removed; we only added trailing commas so the new CHECK constraints could follow them.
The important point is that these changes are backward-compatible. Our teammates' insert_tables.sql, queries.sql, and normalization_validation.sql files continue to work without modification and produce the same results. They only need to pull the updated create_tables.sql when rebuilding the database from scratch.

### 8. Relationships

The major relationships are:

```text
CUSTOMER
   │
   ├──────< ADDRESS
   │
   └──────< ORDER
              │
              ├──────< ORDER_ITEM >────── MENU_ITEM
              │                              │
              │                              └────── RESTAURANT
              │
              ├──────── DELIVERY >──────── DELIVERY_PARTNER
              │
              ├──────── PAYMENT
              │
              └──────── REVIEW

```

### Cardinalities

| Relationship | Cardinality |
|---|---|
| Customer → Address | 1 : N |
| Customer → Order | 1 : N |
| Restaurant → Menu Item | 1 : N |
| Order ↔ Menu Item | M : N through order_items |
| Restaurant → Order | 1 : N |
| Order → Delivery | 0 : 1 in the current schema |
| Delivery Partner → Delivery | 1 : N |
| Order → Payment | 0 : 1 in the current schema |
| Order → Review | 0 : 1 in the current schema |

### 9. Normalization

Normalization is the process of organizing relational data to reduce unnecessary duplication and avoid update, insertion and deletion anomalies. FoodGo includes a separate normalization.sql script that performs read-only demonstrations and verification.

It does not use:

```text
CREATE
ALTER
DROP
INSERT
UPDATE
DELETE
```

The script therefore does not modify the supplied database.

#### 9.1 Unnormalized Form --- UNF

A conceptual unnormalized order could look like:

```text
Order
├── order_id
├── customer
├── restaurant
└── items
      ├── Item 1
      ├── Item 2
      └── Item 3
```

The problem is the repeating group of items. The project does not create this as a physical table; it is used only to explain the starting normalization problem.

#### 9.2 First Normal Form --- 1NF

A relation is in 1NF when attributes contain atomic values and repeating groups are removed. FoodGo demonstrates this through the order-line query in normalization.sql.

Instead of:

```text
Order 2 → [Penne Alfredo, Grilled Salmon Steak]
```

the order items appear as separate rows: Order 2 | Item 74 | Penne Alfredo Order 2 | Item 77 | Grilled Salmon Steak Therefore: One item = one row The order_items table uses: PRIMARY KEY (order_id, item_id) to uniquely identify an order-item combination.

#### 9.3 Second Normal Form --- 2NF

2NF requires: The relation is already in 1NF. Non-key attributes depend on the whole key, not only part of a composite key. This is particularly relevant to order_items.

Its composite key is: (order_id, item_id) and the dependency is: (order_id, item_id)

```text
(order_id, item_id)
        ↓
 quantity
 unit_price
```

The normalization script demonstrates this by separating: order-level facts, menu-item facts, order-item facts. This avoids storing order-level information repeatedly on every item row.

#### 9.4 Third Normal Form --- 3NF Analysis

For the independent relations, the important dependencies include: customer_id → name, phone, email address_id → customer_id, line1, area, city, pincode restaurant_id → name, cuisine, city, is_active item_id → restaurant_id, name, price, is_veg partner_id → name, phone, vehicle_type (order_id, item_id) → quantity, unit_price The normalization script also analyzes: order_id → customer_id, restaurant_id, address_id, order_time, status, total_amount Important orders dependency Under the project's stated business rule: address_id → customer_id because an address belongs to one customer.

Therefore:

```text
order_id
   ↓
address_id
   ↓
customer_id
```

This is a transitive dependency. Because of this, the current physical orders table is not strict 3NF under that stated dependency. The project deliberately does not hide this issue. The normalization script: demonstrates the 3NF projection, separates address and customer facts conceptually, checks reconstruction, verifies that the current data has no observed ownership mismatch, preserves the original physical schema.

A possible future redesign could omit orders.customer_id and derive the customer through addresses, but that would require reviewing existing queries, application logic and business rules.

#### 9.5 Lossless Reconstruction

Query N14 checks whether the order information can be reconstructed after projecting out customer_id. Conceptually:

```text
Original Orders
      │
      ├── Order facts
      │
      └── Address
             │
             └── Customer
                    ↓
             Reconstructed Order
```

The verification compares: original order count, reconstructed order count, reconstructed header values.

The expected result is: original_orders       = 40 reconstructed_orders  = 40 mismatched_headers    = 0 This demonstrates lossless reconstruction for the tested data.

#### 9.6 Price Snapshot

menu_items.price represents the current catalog price. order_items.unit_price represents the historical price captured when the order was placed.

Example: Current menu price       = ₹350 Historical order price   = ₹299

The order must retain ₹299 even if the restaurant later changes the catalog price to ₹350. Therefore unit_price is intentionally stored in order_items.

#### 9.7 Total Verification

The normalization script compares: Stored total vs SUM(quantity × unit_price)

For example:

- Penne Alfredo: 3 × 299 = 897
- Grilled Salmon Steak: 2 × 449 = 898
- Total: 897 + 898 = 1795

The verification query checks whether the stored order total matches the calculated total.

### 10. Integrity Constraints

FoodGo uses:

#### Primary Keys

Uniquely identify records.

Examples:

- `customer_id`
- `restaurant_id`
- `order_id`
- `item_id`

#### Composite Primary Key

(order_id, item_id) in order_items.

```text
(order_id, item_id)
```

#### Foreign Keys

Maintain relationships between tables. Examples:

- `orders.customer_id` → `customers.customer_id`
- `orders.restaurant_id` → `restaurants.restaurant_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.item_id` → `menu_items.item_id`

#### UNIQUE

Used for values that must not repeat.

Examples: customers.phone customers.email delivery_partners.phone deliveries.order_id payments.order_id reviews.order_id

#### NOT NULL

Used where a value is required.

#### CHECK

Examples: menu_items.price > 0 order_items.quantity > 0 order_items.unit_price > 0 ratings between 1 and 5

#### DEFAULT

Examples include: order_time = CURRENT_TIMESTAMP status = 'placed'

#### Referential Actions

The schema uses appropriate ON DELETE and ON UPDATE actions such as: CASCADE RESTRICT to maintain referential integrity.

### 11. Sample Data

The sample-data script contains realistic FoodGo data covering: Customers Addresses Restaurants Menu items Delivery partners Orders Order items Deliveries Payments Reviews

The current sample-data source documents 347 total records across the 10 tables. The data is designed to be referentially consistent and sufficient to produce meaningful query results. Record counts can depend on the database snapshot used for execution. The normalization report and sample-data script should therefore be treated as execution-specific evidence rather than assumed to describe every future database state.

### 12. Normalization Verification Queries

The normalization.sql file contains the following analysis stages:

| Query | Purpose |
|---|---|
| `N01` | Verify database environment |
| `N02` | List existing base tables |
| `N03` | Inspect primary and unique constraints |
| `N04` | Demonstrate 1NF order-line representation |
| `N05` | Display order-level facts for 2NF |
| `N06` | Display menu-item facts for 2NF |
| `N07` | Demonstrate complete composite-key dependency |
| `N08` | Verify address ownership for a selected order |
| `N09` | Check address ownership across all orders |
| `N10` | Show the 3NF order projection |
| `N11` | Show address facts |
| `N12` | Show customer facts |
| `N13` | Show restaurant facts |
| `N14` | Verify lossless reconstruction |
| `N15` | Compare current and historical prices |
| `N16` | Compare stored and calculated total |
| `N17` | Verify totals across all orders |
| `N18` | Check order/menu-item restaurant consistency |
| `N19` | Show final database inventory |

### 13. Business Questions

The project addresses the core questions from the DBMS project specification and additional domain questions.

| \# | Business Question | SQL Concepts |
|---|---|---|
| Q1 | What is the most ordered food item? | `JOIN`, `SUM`, `GROUP BY` |
| Q2 | Which restaurant has the highest revenue? | Multi-table `JOIN`, `SUM`, ranking |
| Q3 | What is the average order value? | CTE/subquery, `AVG` |
| Q4 | Who are the top customers by spending? | Aggregation, `LIMIT` |
| Q5 | What is the average delivery time? | Time-difference functions, `AVG` |
| Q6 | Which restaurants have high ratings? | `AVG`, `HAVING` |
| Q7 | How many orders were cancelled? | `COUNT`, `CASE`, filtering |
| Q8 | What are the peak ordering hours? | `HOUR()`, `GROUP BY` |
| Q9 | How does delivery-partner performance compare? | `JOIN`, `AVG`, aggregation/ranking |
| Q10 | What is the revenue by cuisine? | Multi-level `GROUP BY` |
| Q11 | Which customers order from multiple restaurants? | `COUNT(DISTINCT ...)`, `HAVING` |
| Q12 | What revenue is associated with cancelled orders? | Conditional aggregation |

### 14. Key Design Decisions

#### 1. Price Snapshot

order_items.unit_price is stored separately from menu_items.price. Reason: menu_items.price = current catalog price order_items.unit_price = price recorded for that historical order This preserves historical order accuracy.

#### 2. Composite Key in order_items

PRIMARY KEY (order_id, item_id) An item can appear in many orders and an order can contain many items. The composite key uniquely identifies each order-item combination.

#### 3. At-Most-One Delivery, Payment and Review

Unique constraints on order_id in: deliveries payments reviews ensure that an order cannot have multiple rows in each of those tables. The current physical schema enforces at most one, not necessarily exactly one.

#### 4. Stored total_amount

The orders table stores total_amount. The normalization verification script separately calculates: SUM(quantity × unit_price) and compares it with the stored total. This provides a direct consistency check against update/calculation errors.

#### 5. Referential Integrity

Foreign keys and referential actions are used to prevent orphaned records and maintain relationships between entities.

#### 6. Read-Only Normalization Verification

The normalization script does not alter the existing database. This was intentional because the objective is to demonstrate and verify normalization against the supplied schema and data, while preserving the project database.

### 15. SQL Concepts Demonstrated

The project demonstrates:

- DDL
- DML
- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- JOIN
- LEFT JOIN
- EXISTS
- Subqueries
- CTEs
- Aggregate functions
- `SUM()`
- `COUNT()`
- `AVG()`
- CASE
- UNION ALL
- Date/time functions
- Primary keys
- Foreign keys
- Unique constraints
- Composite keys
- Check constraints
- Default values
- Referential integrity
- Functional dependencies
- 1NF
- 2NF
- 3NF analysis
- Lossless reconstruction

### 16. How to Run the Project

#### Step 1 --- Create the database

Run:

```sql
SOURCE schema/create_tables.sql;
```

This creates the foodgo database and its tables.

#### Step 2 --- Insert sample data

Run:

```sql
SOURCE data/insert_data.sql;
```

This populates the tables with sample data.

#### Step 3 --- Run business queries

Run:

```sql
SOURCE queries/queries.sql;
```

This executes the business-analysis queries.

#### Step 4 --- Run normalization verification

Run:

```sql
SOURCE normalization/normalization.sql;
```

This executes the read-only normalization and consistency checks.

#### Step 5 --- Verify the database

You can check the tables using:

```sql
USE foodgo; SHOW TABLES;
```

### 17. Project Workflow

The overall project follows:

```text
Requirements
     ↓
ER Diagram
     ↓
Relational Schema
     ↓
Primary & Foreign Keys
     ↓
Integrity Constraints
     ↓
Sample Data
     ↓
Normalization Analysis
     ↓
Business SQL Queries
     ↓
Verification
     ↓
Documentation
```

### 18. Conclusion

FoodGo demonstrates how a real-world food-delivery system can be represented using a relational database. The project covers the complete DBMS workflow:

```text
Conceptual Design
      ↓
Logical Design
      ↓
Physical Implementation
      ↓
Data Population
      ↓
Normalization Analysis
      ↓
SQL Analysis
      ↓
Integrity Verification

```

The database provides structured relationships between customers, addresses, restaurants, menu items, orders, order items, delivery partners, deliveries, payments and reviews. The dedicated normalization analysis makes the project's assumptions and functional dependencies explicit. It demonstrates 1NF and 2NF, evaluates the 3NF condition of the current schema, verifies lossless reconstruction and performs additional consistency checks without modifying the database.

---

### Team 5 --- FoodGo

Restaurant, Order & Delivery Management System

DBMS Course Project
