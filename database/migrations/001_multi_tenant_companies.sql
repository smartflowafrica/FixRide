-- ============================================
-- FixRide Multi-Tenant Company System
-- Migration: 001_multi_tenant_companies.sql
-- Date: December 2025
-- ============================================

-- This migration adds support for multiple rental companies
-- Each company can have their own cars, staff, and earnings

-- ============================================
-- 1. Rental Companies Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city_id INT,
    logo VARCHAR(255),
    cover_image VARCHAR(255),
    description TEXT,
    business_reg_number VARCHAR(100),
    tax_id VARCHAR(100),
    is_verified TINYINT DEFAULT 0,
    commission_rate DECIMAL(5,2) DEFAULT 15.00 COMMENT 'Platform commission percentage',
    min_payout_amount DECIMAL(10,2) DEFAULT 100.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_cars INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    status ENUM('active', 'suspended', 'pending') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (city_id) REFERENCES tbl_city(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 2. Company Users/Admins Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(255),
    role ENUM('owner', 'manager', 'staff') DEFAULT 'owner',
    permissions JSON COMMENT 'Custom permissions for staff',
    last_login TIMESTAMP NULL,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 3. Commission Tracking Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_commission (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    company_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL COMMENT 'Total booking amount',
    commission_rate DECIMAL(5,2) NOT NULL COMMENT 'Commission rate at time of booking',
    commission_amount DECIMAL(10,2) NOT NULL COMMENT 'Platform earnings',
    company_earning DECIMAL(10,2) NOT NULL COMMENT 'Company earnings after commission',
    status ENUM('pending', 'paid', 'cancelled') DEFAULT 'pending',
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES tbl_book(id) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
    INDEX idx_company_status (company_id, status),
    INDEX idx_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 4. Company Payout Requests Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_payout (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('bank_transfer', 'paypal', 'mobile_money') DEFAULT 'bank_transfer',
    bank_name VARCHAR(255),
    account_number VARCHAR(50),
    account_name VARCHAR(255),
    paypal_email VARCHAR(255),
    mobile_money_number VARCHAR(20),
    transaction_ref VARCHAR(100),
    status ENUM('pending', 'processing', 'completed', 'rejected') DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    processed_by INT NULL COMMENT 'Admin user who processed',
    notes TEXT,
    rejection_reason TEXT,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
    INDEX idx_company_status (company_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 5. Company Documents Table (for verification)
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_document (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    document_type ENUM('business_reg', 'tax_id', 'insurance', 'license', 'id_card', 'other') NOT NULL,
    document_name VARCHAR(255),
    document_url VARCHAR(255) NOT NULL,
    expiry_date DATE NULL,
    status ENUM('pending', 'verified', 'rejected', 'expired') DEFAULT 'pending',
    verified_by INT NULL,
    verified_at TIMESTAMP NULL,
    rejection_reason TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
    INDEX idx_company_type (company_id, document_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 6. Company Wallet/Balance Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_wallet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT UNIQUE NOT NULL,
    available_balance DECIMAL(10,2) DEFAULT 0.00,
    pending_balance DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Earnings from incomplete bookings',
    total_earned DECIMAL(10,2) DEFAULT 0.00,
    total_withdrawn DECIMAL(10,2) DEFAULT 0.00,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 7. Company Wallet Transactions
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_wallet_transaction (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    description VARCHAR(255),
    reference_type ENUM('booking', 'payout', 'adjustment', 'refund') NOT NULL,
    reference_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
    INDEX idx_company_date (company_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 8. Modify existing tbl_car to add company_id
-- ============================================
ALTER TABLE tbl_car 
ADD COLUMN company_id INT NULL AFTER id,
ADD FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE SET NULL,
ADD INDEX idx_company (company_id);

-- ============================================
-- 9. Company Settings Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT UNIQUE NOT NULL,
    auto_accept_bookings TINYINT DEFAULT 0,
    instant_booking TINYINT DEFAULT 1,
    advance_booking_days INT DEFAULT 30,
    min_booking_hours INT DEFAULT 4,
    cancellation_policy ENUM('flexible', 'moderate', 'strict') DEFAULT 'moderate',
    cancellation_fee_percent DECIMAL(5,2) DEFAULT 20.00,
    notification_email TINYINT DEFAULT 1,
    notification_sms TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 10. Company Reviews Table
-- ============================================
CREATE TABLE IF NOT EXISTS tbl_company_review (
    id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    user_id INT NOT NULL,
    booking_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    review TEXT,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES tbl_user(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES tbl_book(id) ON DELETE CASCADE,
    UNIQUE KEY unique_booking_review (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger to create wallet when company is created
DELIMITER //
CREATE TRIGGER after_company_insert 
AFTER INSERT ON tbl_company
FOR EACH ROW
BEGIN
    INSERT INTO tbl_company_wallet (company_id) VALUES (NEW.id);
    INSERT INTO tbl_company_settings (company_id) VALUES (NEW.id);
END//
DELIMITER ;

-- Trigger to update company rating when review is added
DELIMITER //
CREATE TRIGGER after_company_review_insert
AFTER INSERT ON tbl_company_review
FOR EACH ROW
BEGIN
    UPDATE tbl_company 
    SET rating = (
        SELECT AVG(rating) FROM tbl_company_review 
        WHERE company_id = NEW.company_id AND status = 1
    )
    WHERE id = NEW.company_id;
END//
DELIMITER ;

-- ============================================
-- INDEXES for Performance
-- ============================================
CREATE INDEX idx_company_status ON tbl_company(status);
CREATE INDEX idx_company_city ON tbl_company(city_id);
CREATE INDEX idx_company_verified ON tbl_company(is_verified);

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================
-- INSERT INTO tbl_company (company_name, slug, email, phone, city_id, status, is_verified) 
-- VALUES ('Demo Rentals', 'demo-rentals', 'demo@fixride.com', '+1234567890', 1, 'active', 1);
