-- =======================================================
-- WeFeed: Food Donation Application
-- Designed by Ganesh Kothule
-- Database Schema: MySQL 8.0+
-- Description: MySQL Backend database management to store 
--              user, donation, NGO, and pickup request data.
-- =======================================================

CREATE DATABASE IF NOT EXISTS wefeed_db;
USE wefeed_db;

-- -------------------------------------------------------
-- Table: users (Stores Donors and NGO representatives)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role ENUM('donor', 'ngo', 'admin') DEFAULT 'donor',
    address TEXT,
    pincode VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- -------------------------------------------------------
-- Table: ngos (NGO Organization Details)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS ngos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    ngo_name VARCHAR(200) NOT NULL,
    registration_number VARCHAR(100),
    contact_person VARCHAR(150),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(150),
    address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    verified BOOLEAN DEFAULT TRUE,
    meals_served INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: donations (Food Donations uploaded by Donors)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    donor_name VARCHAR(150) NOT NULL,
    food_title VARCHAR(200) NOT NULL,
    description TEXT,
    food_type ENUM('Cooked Food', 'Raw Food', 'Packaged Food', 'Bakery', 'Other') DEFAULT 'Cooked Food',
    quantity VARCHAR(100) NOT NULL,
    expiry_date VARCHAR(50) NOT NULL,
    photo_url VARCHAR(500),
    address TEXT NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    status ENUM('Available', 'Requested', 'Approved', 'Picked Up', 'Rejected') DEFAULT 'Available',
    pickup_status BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES users(id) ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: food_requests (NGO pickup/claim requests)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS food_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donation_id INT NOT NULL,
    ngo_id INT NOT NULL,
    request_status ENUM('Pending', 'Approved', 'Rejected', 'Completed') DEFAULT 'Pending',
    request_note TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (donation_id) REFERENCES donations(id) ON DELETE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES ngos(id) ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: donation_history (Tracking of completed pickups)
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS donation_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donation_id INT NOT NULL,
    donor_name VARCHAR(150) NOT NULL,
    ngo_name VARCHAR(200) NOT NULL,
    quantity VARCHAR(100) NOT NULL,
    pickup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_status VARCHAR(50) DEFAULT 'Delivered',
    feedback TEXT,
    FOREIGN KEY (donation_id) REFERENCES donations(id) ON DELETE CASCADE
);

-- =======================================================
-- Sample Seed Data for Testing & Demonstration
-- =======================================================

INSERT INTO users (id, name, email, password_hash, phone, role, address, pincode) VALUES
(1, 'Ganesh Kothule (Lead)', 'ganesh@wefeed.org', 'e10adc3949ba59abbe56e057f20f883e', '+919699468358', 'donor', 'Pune, Maharashtra', '411001'),
(2, 'Smile Foundation NGO', 'contact@smilefoundation.org', 'e10adc3949ba59abbe56e057f20f883e', '+919812345678', 'ngo', 'Shivaji Nagar, Pune', '411005'),
(3, 'City Food Bank NGO', 'info@cityfoodbank.org', 'e10adc3949ba59abbe56e057f20f883e', '+919833445566', 'ngo', 'FC Road, Pune', '411004');

INSERT INTO ngos (id, user_id, ngo_name, registration_number, contact_person, phone, email, address, pincode, verified, meals_served) VALUES
(1, 2, 'Smile Foundation', 'NGO-MH-2021-9876', 'Rahul Sharma', '+919812345678', 'contact@smilefoundation.org', 'Shivaji Nagar, Pune', '411005', 1, 500),
(2, 3, 'City Food Bank', 'NGO-MH-2022-1122', 'Pooja Verma', '+919833445566', 'info@cityfoodbank.org', 'FC Road, Pune', '411004', 1, 350);

INSERT INTO donations (id, donor_id, donor_name, food_title, description, food_type, quantity, expiry_date, photo_url, address, pincode, status, pickup_status) VALUES
(1, 1, 'Ganesh Kothule', 'Cooked Veg Meals (Rice & Curry)', 'Freshly prepared vegetarian meal surplus from banquet event.', 'Cooked Food', '25 Packets', 'Today by 11:00 PM', 'uploads/meals_rice.jpg', 'Hotel Grand, Pune', '411001', 'Available', 0),
(2, 1, 'Ganesh Kothule', 'Fresh Bread & Bakery Items', 'Unsold bakery buns, bread loaves, and pastries.', 'Bakery', '40 Loaves', 'Tomorrow 6:00 PM', 'uploads/bakery.jpg', 'BakeHouse Bakery, Pune', '411001', 'Approved', 1);

INSERT INTO donation_history (id, donation_id, donor_name, ngo_name, quantity, pickup_date, delivery_status, feedback) VALUES
(1, 2, 'Ganesh Kothule', 'Smile Foundation', '40 Loaves', NOW(), 'Delivered', 'Distributed to local shelter successfully.');
