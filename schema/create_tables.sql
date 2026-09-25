-- ============================================================
-- FoodGo: Restaurant, Order and Delivery Management System
-- schema/create_tables.sql
-- Created by Samhita (DB schema, keys, relationships, full setup)
-- ============================================================

DROP DATABASE IF EXISTS foodgo;
CREATE DATABASE foodgo
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE foodgo;

-- Safety: disable FK checks while we (re)build, re-enable at the end
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    phone           VARCHAR(15)  NOT NULL,
    email           VARCHAR(100),
    CONSTRAINT uq_customers_phone UNIQUE (phone),
    CONSTRAINT uq_customers_email UNIQUE (email)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. addresses  (1 customer : N addresses)
-- ------------------------------------------------------------
CREATE TABLE addresses (
    address_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    line1           VARCHAR(255) NOT NULL,
    area            VARCHAR(100),
    city            VARCHAR(50)  NOT NULL,
    pincode         VARCHAR(10)  NOT NULL,
    CONSTRAINT fk_addresses_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. restaurants
-- ------------------------------------------------------------
CREATE TABLE restaurants (
    restaurant_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    cuisine         VARCHAR(50),
    city            VARCHAR(50),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. menu_items  (1 restaurant : N menu_items)
-- ------------------------------------------------------------
CREATE TABLE menu_items (
    item_id         INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id   INT NOT NULL,
    name            VARCHAR(150) NOT NULL,
    price           DECIMAL(8,2) NOT NULL,
    is_veg          BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_menuitems_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_menuitems_price CHECK (price > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. delivery_partners
-- ------------------------------------------------------------
CREATE TABLE delivery_partners (
    partner_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    phone           VARCHAR(15)  NOT NULL,
    vehicle_type    ENUM('bike','scooter','bicycle','car') NOT NULL,
    CONSTRAINT uq_partners_phone UNIQUE (phone)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 6. orders
--    customer : orders   = 1:N
--    restaurant : orders = 1:N
--    address : orders    = 1:N
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    restaurant_id   INT NOT NULL,
    address_id      INT NOT NULL,
    order_time      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('placed','preparing','out_for_delivery','delivered','cancelled')
                        NOT NULL DEFAULT 'placed',
    total_amount    DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id) REFERENCES addresses(address_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 7. order_items  (M:N between orders and menu_items)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_id        INT NOT NULL,
    item_id         INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    CONSTRAINT fk_orderitems_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_orderitems_item
        FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_orderitems_qty CHECK (quantity > 0),
    CONSTRAINT chk_orderitems_price CHECK (unit_price > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 8. deliveries  (each order has AT MOST one delivery -> 1:1)
-- ------------------------------------------------------------
CREATE TABLE deliveries (
    delivery_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    partner_id      INT NOT NULL,
    pickup_time     DATETIME,
    delivered_time  DATETIME,
    CONSTRAINT uq_deliveries_order UNIQUE (order_id),
    CONSTRAINT fk_deliveries_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_deliveries_partner
        FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_deliveries_times
        CHECK (delivered_time IS NULL OR pickup_time IS NULL OR delivered_time >= pickup_time)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 9. payments  (each order has exactly one payment -> 1:1)
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    method          ENUM('card','upi','cash','netbanking') NOT NULL,
    status          ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
    CONSTRAINT uq_payments_order UNIQUE (order_id),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_payments_amount CHECK (amount > 0)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 10. reviews  (customer rates restaurant/delivery per order)
-- ------------------------------------------------------------
CREATE TABLE reviews (
    review_id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id            INT NOT NULL,
    restaurant_rating   INT,
    delivery_rating     INT,
    comment             TEXT,
    CONSTRAINT uq_reviews_order UNIQUE (order_id),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_reviews_restaurant_rating
        CHECK (restaurant_rating IS NULL OR restaurant_rating BETWEEN 1 AND 5),
    CONSTRAINT chk_reviews_delivery_rating
        CHECK (delivery_rating IS NULL OR delivery_rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- Quick check: list all tables just created
-- ------------------------------------------------------------
SHOW TABLES;