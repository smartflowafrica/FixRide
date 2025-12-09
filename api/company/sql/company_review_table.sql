-- Company Review Table
-- Stores customer reviews and ratings for rental companies

CREATE TABLE IF NOT EXISTS `tbl_company_review` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `company_id` INT(11) NOT NULL,
    `user_id` INT(11) NOT NULL,
    `booking_id` INT(11) DEFAULT NULL COMMENT 'Optional link to specific booking',
    `rating` INT(1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    `review` TEXT DEFAULT NULL,
    `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
    `company_reply` TEXT DEFAULT NULL,
    `reply_at` DATETIME DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_company_id` (`company_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_booking_id` (`booking_id`),
    KEY `idx_rating` (`rating`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_review_company` FOREIGN KEY (`company_id`) REFERENCES `tbl_company` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_review_user` FOREIGN KEY (`user_id`) REFERENCES `tbl_user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_review_booking` FOREIGN KEY (`booking_id`) REFERENCES `tbl_book` (`id`) ON DELETE SET NULL,
    UNIQUE KEY `unique_user_booking_review` (`user_id`, `booking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add average rating column to company table if not exists
ALTER TABLE `tbl_company` 
ADD COLUMN IF NOT EXISTS `avg_rating` DECIMAL(3,2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS `total_reviews` INT(11) DEFAULT 0;

-- Trigger to update company average rating after insert
DELIMITER //
CREATE TRIGGER IF NOT EXISTS `update_company_rating_insert` 
AFTER INSERT ON `tbl_company_review`
FOR EACH ROW
BEGIN
    UPDATE `tbl_company` 
    SET avg_rating = (
        SELECT ROUND(AVG(rating), 2) 
        FROM `tbl_company_review` 
        WHERE company_id = NEW.company_id AND status = 'approved'
    ),
    total_reviews = (
        SELECT COUNT(*) 
        FROM `tbl_company_review` 
        WHERE company_id = NEW.company_id AND status = 'approved'
    )
    WHERE id = NEW.company_id;
END//

-- Trigger to update company average rating after update
CREATE TRIGGER IF NOT EXISTS `update_company_rating_update` 
AFTER UPDATE ON `tbl_company_review`
FOR EACH ROW
BEGIN
    UPDATE `tbl_company` 
    SET avg_rating = (
        SELECT ROUND(AVG(rating), 2) 
        FROM `tbl_company_review` 
        WHERE company_id = NEW.company_id AND status = 'approved'
    ),
    total_reviews = (
        SELECT COUNT(*) 
        FROM `tbl_company_review` 
        WHERE company_id = NEW.company_id AND status = 'approved'
    )
    WHERE id = NEW.company_id;
END//

-- Trigger to update company average rating after delete
CREATE TRIGGER IF NOT EXISTS `update_company_rating_delete` 
AFTER DELETE ON `tbl_company_review`
FOR EACH ROW
BEGIN
    UPDATE `tbl_company` 
    SET avg_rating = (
        SELECT COALESCE(ROUND(AVG(rating), 2), 0) 
        FROM `tbl_company_review` 
        WHERE company_id = OLD.company_id AND status = 'approved'
    ),
    total_reviews = (
        SELECT COUNT(*) 
        FROM `tbl_company_review` 
        WHERE company_id = OLD.company_id AND status = 'approved'
    )
    WHERE id = OLD.company_id;
END//
DELIMITER ;
