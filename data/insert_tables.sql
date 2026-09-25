-- ============================================================
-- FoodGo: Sample Data (realistic, referentially consistent)
-- schema/insert_data.sql
-- Created by Samhita 

-- Table               Rows   Notes
-- ------------------- -----  --------------------------------------------------
-- customers            25    Bengaluru names, unique phone/email
-- addresses            30    5 customers have 2 addresses; real Bengaluru areas + pincodes
-- restaurants           8    South Indian, North Indian, Chinese, Italian, Biryani,
--                             Fast Food, Desserts, Continental (1 inactive)
-- menu_items            80   10 per restaurant, realistic pricing, veg/non-veg mix
-- delivery_partners     10   Mostly bikes, a few scooters/bicycle/car
-- orders                40   Spread Aug-Sep 2026; status mix (mostly delivered,
--                             some cancelled/in-flight)
-- order_items           74   1-3 items per order; total_amount computed to match exactly
-- deliveries             32   80% of orders; all delivered/out_for_delivery orders covered
-- payments               36   90% of orders; status matched to order status
--                             (refunded/failed for cancellations)
-- reviews                12   50% of delivered orders; 1-5 ratings w/ realistic comments
-- ------------------- -----  --------------------------------------------------
-- TOTAL                347
-- ============================================================

USE foodgo;

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- customers (25 rows)
-- ------------------------------------------------------------
INSERT INTO customers (customer_id, name, phone, email) VALUES
(1, 'Aditi Rao', '9871644825', 'aditi.rao15@gmail.com'),
(2, 'Rohan Sharma', '9706713773', 'rohan.sharma95@gmail.com'),
(3, 'Priya Gowda', '9773827621', 'priya.gowda32@gmail.com'),
(4, 'Karthik Reddy', '9759917677', 'karthik.reddy18@gmail.com'),
(5, 'Sneha Nair', '9897694986', 'sneha.nair14@gmail.com'),
(6, 'Arjun Iyer', '9881650134', 'arjun.iyer95@gmail.com'),
(7, 'Divya Kumar', '9846395715', 'divya.kumar12@gmail.com'),
(8, 'Vikram Shetty', '9858509126', 'vikram.shetty55@gmail.com'),
(9, 'Ananya Bhat', '9708531599', 'ananya.bhat4@gmail.com'),
(10, 'Suresh Murthy', '9725151125', 'suresh.murthy28@gmail.com'),
(11, 'Meera Kulkarni', '9762454433', 'meera.kulkarni65@gmail.com'),
(12, 'Rahul Pillai', '9861603172', 'rahul.pillai4@gmail.com'),
(13, 'Lakshmi Menon', '9850658074', 'lakshmi.menon26@gmail.com'),
(14, 'Nikhil Patil', '9892205051', 'nikhil.patil84@gmail.com'),
(15, 'Pooja Naidu', '9888260488', 'pooja.naidu70@gmail.com'),
(16, 'Siddharth Hegde', '9812613994', 'siddharth.hegde29@gmail.com'),
(17, 'Kavya Prasad', '9820583634', 'kavya.prasad76@gmail.com'),
(18, 'Manoj Acharya', '9774676249', 'manoj.acharya1@gmail.com'),
(19, 'Ritu Bhandari', '9742858220', 'ritu.bhandari90@gmail.com'),
(20, 'Arvind Kamath', '9813444689', 'arvind.kamath44@gmail.com'),
(21, 'Shreya Shetty', '9774590520', 'shreya.shetty20@gmail.com'),
(22, 'Deepak Verma', '9757797847', 'deepak.verma98@gmail.com'),
(23, 'Nandini Krishnan', '9790353911', 'nandini.krishnan14@gmail.com'),
(24, 'Harish Raghavan', '9724896273', 'harish.raghavan49@gmail.com'),
(25, 'Swati Desai', '9725962105', 'swati.desai46@gmail.com');

-- ------------------------------------------------------------
-- addresses (30 rows)
-- ------------------------------------------------------------
INSERT INTO addresses (address_id, customer_id, line1, area, city, pincode) VALUES
(1, 1, 'No. 89, Airport Road', 'Malleswaram 8th Cross', 'Bengaluru', '560003'),
(2, 2, 'No. 3C, Airport Road', 'Basavanagudi Bull Temple Rd', 'Bengaluru', '560004'),
(3, 2, 'No. 101, Ring Road', 'Rajajinagar 1st Block', 'Bengaluru', '560010'),
(4, 3, 'No. 45B, Airport Road', 'Yelahanka New Town', 'Bengaluru', '560064'),
(5, 4, 'No. 64, Sarjapur Road', 'Koramangala 5th Block', 'Bengaluru', '560095'),
(6, 5, 'No. 101, Airport Road', 'Banashankari 3rd Stage', 'Bengaluru', '560085'),
(7, 6, 'No. 45B, Airport Road', 'Hebbal Ring Road', 'Bengaluru', '560024'),
(8, 7, 'No. 101, Residency Road', 'BTM Layout 2nd Stage', 'Bengaluru', '560076'),
(9, 8, 'No. 72, Ring Road', 'Electronic City Phase 1', 'Bengaluru', '560100'),
(10, 9, 'No. 18, Ring Road', 'Whitefield ITPL Main Road', 'Bengaluru', '560066'),
(11, 9, 'No. 64, Old Madras Road', 'HSR Layout Sector 2', 'Bengaluru', '560102'),
(12, 10, 'No. 15B, Airport Road', 'JP Nagar 6th Phase', 'Bengaluru', '560078'),
(13, 11, 'No. 64, Bannerghatta Road', 'Yelahanka New Town', 'Bengaluru', '560064'),
(14, 12, 'No. 9, Sarjapur Road', 'Rajajinagar 1st Block', 'Bengaluru', '560010'),
(15, 12, 'No. 56, Church Street', 'Whitefield ITPL Main Road', 'Bengaluru', '560066'),
(16, 13, 'No. 15B, Sarjapur Road', 'Jayanagar 4th Block', 'Bengaluru', '560011'),
(17, 14, 'No. 18, MG Road', 'Electronic City Phase 1', 'Bengaluru', '560100'),
(18, 15, 'No. 72, MG Road', 'HSR Layout Sector 2', 'Bengaluru', '560102'),
(19, 16, 'No. 18, Church Street', 'Banashankari 3rd Stage', 'Bengaluru', '560085'),
(20, 17, 'No. 24A, Sarjapur Road', 'Jayanagar 4th Block', 'Bengaluru', '560011'),
(21, 18, 'No. 21D, Ring Road', 'Basavanagudi Bull Temple Rd', 'Bengaluru', '560004'),
(22, 19, 'No. 64, Residency Road', 'HSR Layout Sector 2', 'Bengaluru', '560102'),
(23, 20, 'No. 15B, Residency Road', 'BTM Layout 2nd Stage', 'Bengaluru', '560076'),
(24, 20, 'No. 101, Bannerghatta Road', 'Whitefield ITPL Main Road', 'Bengaluru', '560066'),
(25, 21, 'No. 9, Old Madras Road', 'HSR Layout Sector 2', 'Bengaluru', '560102'),
(26, 22, 'No. 21D, Church Street', 'JP Nagar 6th Phase', 'Bengaluru', '560078'),
(27, 23, 'No. 21D, Church Street', 'Basavanagudi Bull Temple Rd', 'Bengaluru', '560004'),
(28, 24, 'No. 45B, Bannerghatta Road', 'Marathahalli Bridge', 'Bengaluru', '560037'),
(29, 24, 'No. 56, Airport Road', 'Rajajinagar 1st Block', 'Bengaluru', '560010'),
(30, 25, 'No. 12, Airport Road', 'Banashankari 3rd Stage', 'Bengaluru', '560085');

-- ------------------------------------------------------------
-- restaurants (8 rows)
-- ------------------------------------------------------------
INSERT INTO restaurants (restaurant_id, name, cuisine, city, is_active) VALUES
(1, 'Vidyarthi Bhavan Express', 'South Indian', 'Bengaluru', 1),
(2, 'Punjabi Tadka House', 'North Indian', 'Bengaluru', 1),
(3, 'Dragon Wok Chinese', 'Chinese', 'Bengaluru', 1),
(4, 'Bella Napoli Pizzeria', 'Italian', 'Bengaluru', 1),
(5, 'Empire Biryani Corner', 'Biryani', 'Bengaluru', 1),
(6, 'Chatkara Fast Food', 'Fast Food', 'Bengaluru', 1),
(7, 'Sweet Mane Desserts', 'Desserts', 'Bengaluru', 1),
(8, 'The Garden Continental', 'Continental', 'Bengaluru', 0);

-- ------------------------------------------------------------
-- menu_items (80 rows)
-- ------------------------------------------------------------
INSERT INTO menu_items (item_id, restaurant_id, name, price, is_veg) VALUES
(1, 1, 'Masala Dosa', 99, 1),
(2, 1, 'Plain Dosa', 79, 1),
(3, 1, 'Idli Vada Combo', 89, 1),
(4, 1, 'Rava Idli', 79, 1),
(5, 1, 'Filter Coffee', 39, 1),
(6, 1, 'Mysore Bonda', 69, 1),
(7, 1, 'Uttapam', 109, 1),
(8, 1, 'Curd Rice', 89, 1),
(9, 1, 'Vegetable Khichdi', 99, 1),
(10, 1, 'Kesari Bath', 69, 1),
(11, 2, 'Butter Chicken', 329, 0),
(12, 2, 'Paneer Butter Masala', 279, 1),
(13, 2, 'Dal Makhani', 229, 1),
(14, 2, 'Tandoori Roti', 29, 1),
(15, 2, 'Garlic Naan', 49, 1),
(16, 2, 'Chicken Biryani', 299, 0),
(17, 2, 'Rajma Chawal', 189, 1),
(18, 2, 'Palak Paneer', 259, 1),
(19, 2, 'Chicken Tikka', 319, 0),
(20, 2, 'Lassi', 99, 1),
(21, 3, 'Veg Hakka Noodles', 189, 1),
(22, 3, 'Chicken Manchurian', 249, 0),
(23, 3, 'Veg Fried Rice', 179, 1),
(24, 3, 'Chilli Paneer', 229, 1),
(25, 3, 'Szechuan Chicken', 269, 0),
(26, 3, 'Spring Rolls', 149, 1),
(27, 3, 'Schezwan Noodles', 199, 1),
(28, 3, 'Honey Chilli Potato', 179, 1),
(29, 3, 'Chicken Soup', 129, 0),
(30, 3, 'Veg Manchurian', 199, 1),
(31, 4, 'Margherita Pizza', 299, 1),
(32, 4, 'Pepperoni Pizza', 399, 0),
(33, 4, 'Farmhouse Pizza', 349, 1),
(34, 4, 'Pasta Alfredo', 279, 1),
(35, 4, 'Garlic Bread', 149, 1),
(36, 4, 'Lasagna', 329, 0),
(37, 4, 'Mushroom Pizza', 319, 1),
(38, 4, 'Penne Arrabbiata', 259, 1),
(39, 4, 'Caesar Salad', 219, 0),
(40, 4, 'Tiramisu', 179, 1),
(41, 5, 'Hyderabadi Chicken Biryani', 249, 0),
(42, 5, 'Mutton Biryani', 329, 0),
(43, 5, 'Veg Biryani', 189, 1),
(44, 5, 'Egg Biryani', 199, 0),
(45, 5, 'Chicken 65', 229, 0),
(46, 5, 'Raita', 39, 1),
(47, 5, 'Paneer Biryani', 219, 1),
(48, 5, 'Boneless Chicken Biryani', 279, 0),
(49, 5, 'Kebab Platter', 299, 0),
(50, 5, 'Double Ka Meetha', 99, 1),
(51, 6, 'Cheese Burger', 139, 0),
(52, 6, 'Veg Burger', 99, 1),
(53, 6, 'French Fries', 99, 1),
(54, 6, 'Chicken Wrap', 179, 0),
(55, 6, 'Veg Wrap', 139, 1),
(56, 6, 'Loaded Nachos', 169, 1),
(57, 6, 'Cold Coffee', 119, 1),
(58, 6, 'Chicken Nuggets', 179, 0),
(59, 6, 'Paneer Roll', 149, 1),
(60, 6, 'Masala Fries', 119, 1),
(61, 7, 'Gulab Jamun', 89, 1),
(62, 7, 'Rasmalai', 109, 1),
(63, 7, 'Chocolate Brownie', 139, 1),
(64, 7, 'Kaju Katli', 199, 1),
(65, 7, 'Ice Cream Sundae', 149, 1),
(66, 7, 'Jalebi', 79, 1),
(67, 7, 'Kulfi', 99, 1),
(68, 7, 'Cheesecake', 189, 1),
(69, 7, 'Fruit Custard', 119, 1),
(70, 7, 'Mysore Pak', 99, 1),
(71, 8, 'Grilled Chicken', 349, 0),
(72, 8, 'Mushroom Soup', 149, 1),
(73, 8, 'Fish and Chips', 379, 0),
(74, 8, 'Veg Grill Platter', 299, 1),
(75, 8, 'Caesar Salad', 219, 1),
(76, 8, 'Roasted Veggies', 199, 1),
(77, 8, 'Steak', 449, 0),
(78, 8, 'Mashed Potato', 129, 1),
(79, 8, 'Iced Tea', 99, 1),
(80, 8, 'Apple Pie', 179, 1);

-- ------------------------------------------------------------
-- delivery_partners (10 rows)
-- ------------------------------------------------------------
INSERT INTO delivery_partners (partner_id, name, phone, vehicle_type) VALUES
(1, 'Manjunath', '8741028029', 'bike'),
(2, 'Ravi Kumar', '8868428764', 'bike'),
(3, 'Faizan', '8742944840', 'bike'),
(4, 'Santosh', '8882665285', 'scooter'),
(5, 'Gopal', '8813322702', 'bike'),
(6, 'Iqbal', '8860097331', 'bike'),
(7, 'Naveen', '8717053089', 'scooter'),
(8, 'Prakash', '8803285188', 'bicycle'),
(9, 'Yusuf', '8802440146', 'bike'),
(10, 'Chandan', '8859957580', 'car');

-- ------------------------------------------------------------
-- orders (40 rows)
-- ------------------------------------------------------------
INSERT INTO orders (order_id, customer_id, restaurant_id, address_id, order_time, status, total_amount) VALUES
(1, 8, 2, 9, '2026-09-16 15:52:00', 'delivered', 319.00),
(2, 5, 8, 6, '2026-08-17 16:55:00', 'delivered', 1795.00),
(3, 23, 4, 27, '2026-08-26 18:41:00', 'delivered', 737.00),
(4, 8, 4, 9, '2026-08-22 08:37:00', 'delivered', 458.00),
(5, 23, 1, 27, '2026-08-05 22:02:00', 'placed', 178.00),
(6, 22, 8, 26, '2026-09-04 10:46:00', 'placed', 437.00),
(7, 14, 4, 17, '2026-08-07 18:27:00', 'delivered', 1175.00),
(8, 2, 2, 2, '2026-08-26 19:21:00', 'out_for_delivery', 29.00),
(9, 7, 8, 8, '2026-08-28 10:17:00', 'cancelled', 896.00),
(10, 4, 1, 5, '2026-08-06 22:48:00', 'cancelled', 178.00),
(11, 16, 8, 19, '2026-08-26 22:03:00', 'delivered', 449.00),
(12, 13, 5, 16, '2026-08-19 14:44:00', 'cancelled', 767.00),
(13, 2, 1, 3, '2026-08-04 08:37:00', 'delivered', 168.00),
(14, 17, 2, 20, '2026-08-05 17:04:00', 'delivered', 805.00),
(15, 20, 1, 23, '2026-08-27 18:37:00', 'preparing', 168.00),
(16, 22, 6, 26, '2026-08-17 14:08:00', 'delivered', 656.00),
(17, 20, 2, 23, '2026-09-04 11:32:00', 'delivered', 528.00),
(18, 12, 5, 14, '2026-08-29 21:34:00', 'delivered', 1534.00),
(19, 22, 2, 26, '2026-08-17 09:56:00', 'out_for_delivery', 319.00),
(20, 9, 5, 10, '2026-09-15 13:13:00', 'delivered', 807.00),
(21, 21, 7, 25, '2026-08-03 08:21:00', 'delivered', 149.00),
(22, 24, 8, 29, '2026-09-05 08:07:00', 'out_for_delivery', 758.00),
(23, 2, 6, 2, '2026-08-28 10:02:00', 'placed', 308.00),
(24, 22, 4, 26, '2026-08-23 20:35:00', 'delivered', 528.00),
(25, 6, 7, 7, '2026-08-12 19:59:00', 'cancelled', 298.00),
(26, 23, 2, 27, '2026-08-03 21:30:00', 'delivered', 58.00),
(27, 12, 5, 14, '2026-08-15 08:42:00', 'placed', 219.00),
(28, 9, 2, 11, '2026-08-23 18:32:00', 'delivered', 618.00),
(29, 9, 3, 11, '2026-08-03 09:38:00', 'delivered', 696.00),
(30, 17, 2, 20, '2026-09-06 11:16:00', 'delivered', 189.00),
(31, 17, 4, 20, '2026-08-28 09:42:00', 'delivered', 866.00),
(32, 24, 5, 29, '2026-09-12 14:20:00', 'preparing', 528.00),
(33, 14, 7, 17, '2026-09-09 17:19:00', 'delivered', 208.00),
(34, 7, 7, 8, '2026-08-30 15:28:00', 'delivered', 1283.00),
(35, 3, 5, 4, '2026-08-06 21:48:00', 'delivered', 229.00),
(36, 7, 3, 8, '2026-08-03 11:30:00', 'delivered', 1035.00),
(37, 19, 4, 22, '2026-09-01 14:15:00', 'preparing', 299.00),
(38, 25, 7, 30, '2026-08-12 20:44:00', 'delivered', 467.00),
(39, 4, 8, 5, '2026-09-21 15:42:00', 'preparing', 596.00),
(40, 24, 7, 29, '2026-08-11 19:55:00', 'out_for_delivery', 636.00);

-- ------------------------------------------------------------
-- order_items (74 rows)
-- ------------------------------------------------------------
INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
(1, 19, 1, 319.00),
(2, 77, 2, 449.00),
(2, 74, 3, 299.00),
(3, 38, 2, 259.00),
(3, 39, 1, 219.00),
(4, 34, 1, 279.00),
(4, 40, 1, 179.00),
(5, 2, 1, 79.00),
(5, 9, 1, 99.00),
(6, 80, 1, 179.00),
(6, 78, 2, 129.00),
(7, 37, 2, 319.00),
(7, 40, 3, 179.00),
(8, 14, 1, 29.00),
(9, 74, 2, 299.00),
(9, 72, 2, 149.00),
(10, 3, 2, 89.00),
(11, 77, 1, 449.00),
(12, 49, 1, 299.00),
(12, 48, 1, 279.00),
(12, 43, 1, 189.00),
(13, 9, 1, 99.00),
(13, 10, 1, 69.00),
(14, 14, 2, 29.00),
(14, 17, 1, 189.00),
(14, 12, 2, 279.00),
(15, 9, 1, 99.00),
(15, 6, 1, 69.00),
(16, 55, 1, 139.00),
(16, 58, 1, 179.00),
(16, 56, 2, 169.00),
(17, 13, 1, 229.00),
(17, 16, 1, 299.00),
(18, 45, 3, 229.00),
(18, 49, 2, 299.00),
(18, 41, 1, 249.00),
(19, 19, 1, 319.00),
(20, 45, 1, 229.00),
(20, 49, 1, 299.00),
(20, 48, 1, 279.00),
(21, 65, 1, 149.00),
(22, 73, 2, 379.00),
(23, 56, 1, 169.00),
(23, 51, 1, 139.00),
(24, 40, 1, 179.00),
(24, 33, 1, 349.00),
(25, 67, 1, 99.00),
(25, 64, 1, 199.00),
(26, 14, 2, 29.00),
(27, 47, 1, 219.00),
(28, 19, 1, 319.00),
(28, 16, 1, 299.00),
(29, 26, 2, 149.00),
(29, 30, 2, 199.00),
(30, 17, 1, 189.00),
(31, 40, 3, 179.00),
(31, 36, 1, 329.00),
(32, 45, 1, 229.00),
(32, 49, 1, 299.00),
(33, 69, 1, 119.00),
(33, 61, 1, 89.00),
(34, 64, 3, 199.00),
(34, 69, 1, 119.00),
(34, 68, 3, 189.00),
(35, 45, 1, 229.00),
(36, 22, 2, 249.00),
(36, 28, 3, 179.00),
(37, 31, 1, 299.00),
(38, 68, 2, 189.00),
(38, 61, 1, 89.00),
(39, 79, 2, 99.00),
(39, 76, 2, 199.00),
(40, 68, 1, 189.00),
(40, 65, 3, 149.00);

-- ------------------------------------------------------------
-- deliveries (32 rows, ~80% of orders)
-- ------------------------------------------------------------
INSERT INTO deliveries (delivery_id, order_id, partner_id, pickup_time, delivered_time) VALUES
(1, 1, 6, '2026-09-16 16:24:00', '2026-09-16 16:41:00'),
(2, 2, 3, '2026-08-17 17:14:00', '2026-08-17 17:36:00'),
(3, 3, 7, '2026-08-26 19:00:00', '2026-08-26 19:37:00'),
(4, 4, 4, '2026-08-22 08:54:00', '2026-08-22 09:22:00'),
(5, 7, 7, '2026-08-07 18:52:00', '2026-08-07 19:24:00'),
(6, 8, 8, '2026-08-26 19:49:00', NULL),
(7, 10, 1, NULL, NULL),
(8, 11, 7, '2026-08-26 22:36:00', '2026-08-26 23:21:00'),
(9, 12, 1, '2026-08-19 15:17:00', NULL),
(10, 13, 1, '2026-08-04 09:03:00', '2026-08-04 09:27:00'),
(11, 14, 7, '2026-08-05 17:32:00', '2026-08-05 18:04:00'),
(12, 16, 9, '2026-08-17 14:42:00', '2026-08-17 15:25:00'),
(13, 17, 4, '2026-09-04 12:02:00', '2026-09-04 12:24:00'),
(14, 18, 5, '2026-08-29 22:02:00', '2026-08-29 22:32:00'),
(15, 19, 1, '2026-08-17 10:23:00', NULL),
(16, 20, 6, '2026-09-15 13:40:00', '2026-09-15 14:18:00'),
(17, 21, 3, '2026-08-03 08:50:00', '2026-08-03 09:34:00'),
(18, 22, 3, '2026-09-05 08:41:00', NULL),
(19, 24, 9, '2026-08-23 20:50:00', '2026-08-23 21:34:00'),
(20, 25, 7, NULL, NULL),
(21, 26, 1, '2026-08-03 21:47:00', '2026-08-03 22:22:00'),
(22, 27, 7, NULL, NULL),
(23, 28, 3, '2026-08-23 18:48:00', '2026-08-23 19:11:00'),
(24, 29, 7, '2026-08-03 10:03:00', '2026-08-03 10:24:00'),
(25, 30, 8, '2026-09-06 11:41:00', '2026-09-06 12:06:00'),
(26, 31, 7, '2026-08-28 10:05:00', '2026-08-28 10:44:00'),
(27, 33, 7, '2026-09-09 17:42:00', '2026-09-09 18:23:00'),
(28, 34, 2, '2026-08-30 15:58:00', '2026-08-30 16:13:00'),
(29, 35, 9, '2026-08-06 22:04:00', '2026-08-06 22:49:00'),
(30, 36, 6, '2026-08-03 11:52:00', '2026-08-03 12:27:00'),
(31, 38, 2, '2026-08-12 21:19:00', '2026-08-12 21:35:00'),
(32, 40, 1, '2026-08-11 20:17:00', NULL);

-- ------------------------------------------------------------
-- payments (36 rows, ~90% of orders)
-- ------------------------------------------------------------
INSERT INTO payments (payment_id, order_id, amount, method, status) VALUES
(1, 1, 319.00, 'netbanking', 'completed'),
(2, 2, 1795.00, 'upi', 'completed'),
(3, 4, 458.00, 'netbanking', 'completed'),
(4, 5, 178.00, 'card', 'pending'),
(5, 6, 437.00, 'upi', 'completed'),
(6, 7, 1175.00, 'cash', 'completed'),
(7, 8, 29.00, 'upi', 'pending'),
(8, 9, 896.00, 'card', 'failed'),
(9, 10, 178.00, 'upi', 'failed'),
(10, 12, 767.00, 'netbanking', 'failed'),
(11, 13, 168.00, 'upi', 'completed'),
(12, 14, 805.00, 'card', 'completed'),
(13, 15, 168.00, 'upi', 'completed'),
(14, 16, 656.00, 'cash', 'completed'),
(15, 17, 528.00, 'upi', 'completed'),
(16, 19, 319.00, 'card', 'pending'),
(17, 20, 807.00, 'cash', 'completed'),
(18, 21, 149.00, 'card', 'completed'),
(19, 22, 758.00, 'cash', 'completed'),
(20, 23, 308.00, 'card', 'completed'),
(21, 24, 528.00, 'card', 'completed'),
(22, 25, 298.00, 'card', 'failed'),
(23, 26, 58.00, 'upi', 'completed'),
(24, 27, 219.00, 'netbanking', 'pending'),
(25, 28, 618.00, 'netbanking', 'completed'),
(26, 29, 696.00, 'upi', 'completed'),
(27, 30, 189.00, 'upi', 'completed'),
(28, 31, 866.00, 'card', 'completed'),
(29, 33, 208.00, 'upi', 'completed'),
(30, 34, 1283.00, 'netbanking', 'completed'),
(31, 35, 229.00, 'card', 'completed'),
(32, 36, 1035.00, 'card', 'completed'),
(33, 37, 299.00, 'card', 'completed'),
(34, 38, 467.00, 'upi', 'completed'),
(35, 39, 596.00, 'upi', 'completed'),
(36, 40, 636.00, 'netbanking', 'completed');

-- ------------------------------------------------------------
-- reviews (12 rows, ~50% of delivered orders)
-- ------------------------------------------------------------
INSERT INTO reviews (review_id, order_id, restaurant_rating, delivery_rating, comment) VALUES
(1, 1, 3, 5, 'Delivery partner was polite and on time.'),
(2, 2, 5, 3, NULL),
(3, 4, 4, 5, 'Delivery partner was polite and on time.'),
(4, 11, 3, 2, 'Excellent service, quick delivery.'),
(5, 13, 3, 5, NULL),
(6, 16, 3, 4, NULL),
(7, 18, 5, 4, 'Delivery partner was polite and on time.'),
(8, 20, 5, 4, 'Loved the biryani, very authentic taste.'),
(9, 28, 5, 4, 'Portion size could be better.'),
(10, 29, 5, 5, 'Excellent service, quick delivery.'),
(11, 30, 4, 4, 'Average experience, food was okay.'),
(12, 33, 3, 3, 'Portion size could be better.');

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- Quick check: row counts per table
-- ------------------------------------------------------------
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'addresses' AS table_name, COUNT(*) AS row_count FROM addresses
UNION ALL
SELECT 'restaurants' AS table_name, COUNT(*) AS row_count FROM restaurants
UNION ALL
SELECT 'menu_items' AS table_name, COUNT(*) AS row_count FROM menu_items
UNION ALL
SELECT 'delivery_partners' AS table_name, COUNT(*) AS row_count FROM delivery_partners
UNION ALL
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'order_items' AS table_name, COUNT(*) AS row_count FROM order_items
UNION ALL
SELECT 'deliveries' AS table_name, COUNT(*) AS row_count FROM deliveries
UNION ALL
SELECT 'payments' AS table_name, COUNT(*) AS row_count FROM payments
UNION ALL
SELECT 'reviews' AS table_name, COUNT(*) AS row_count FROM reviews;