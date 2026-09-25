# FoodGo---Food-Delivery-System
# FoodGo
### Restaurant, Order & Delivery Management System

**Team 5 | DBMS Course Project**

A clean, fully normalised relational database that powers a food delivery platform.  
FoodGo connects customers, restaurants, menus, orders, delivery partners, payments and reviews into one coherent system — designed for correctness, analytical power and real-world practices.

---

## Team Members

| S.No | Student Name              | USN         |
|:----:|---------------------------|-------------|
| 1    | Rehaan Saha               | AU25UG-046  |
| 2    | S Thanmayee               | AU25UG-049  |
| 3    | Samhita Bhuvanagiri       | AU25UG-050  |
| 4    | Sarang Siva Thilakan      | AU25UG-054  |
| 5    | Shahiba Arshiya Banu      | AU25UG-055  |
| 6    | Supriya R                 | AU25UG-058  |

---

## Project Highlights

- Fully normalised to **Third Normal Form (3NF)**
- Industry-standard **price snapshot** in order items
- Strong integrity constraints (`CHECK`, `UNIQUE`, referential actions)
- Realistic order lifecycle with controlled status values
- One-to-one relationships for Delivery, Payment and Review per order
- Performance indexes on frequently queried columns
- Rich, interconnected sample data (12 customers • 8 restaurants • 20+ orders)
- 12 analytical queries covering all required business questions + extras

---

## Technology Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| RDBMS              | MySQL 8.0+ / MariaDB 10.5+         |
| Schema Design      | Crow’s Foot ER Diagram              |
| Query Language     | Standard SQL (CTEs, Aggregations, Time functions) |
| Tools              | MySQL Workbench / DBeaver / CLI     |

---

## Repository Structure

```text
FoodGo/
├── README.md                       ← You are here
├── schema/
│   └── create_tables.sql           ← Complete DDL (tables, constraints, indexes)
├── data/
│   └── insert_data.sql             ← Realistic sample data
├── queries/
│   └── queries.sql                 ← Business questions + analytical queries
├── diagrams/                       ← ER diagram & relational schema diagram
└── docs/
    └── Design_Rationale.md         ← Design decisions, normalisation & assumptions
