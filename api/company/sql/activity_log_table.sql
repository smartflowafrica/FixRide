-- Company Activity Log Table
-- Tracks all company actions for audit purposes

CREATE TABLE IF NOT EXISTS `tbl_company_activity_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL COMMENT 'Action type: car_add, car_edit, car_delete, booking_update, payout_request, etc.',
  `details` text DEFAULT NULL COMMENT 'Additional action details',
  `reference_id` int(11) DEFAULT NULL COMMENT 'Related record ID (car_id, booking_id, etc.)',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_company_id` (`company_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_activity_company` FOREIGN KEY (`company_id`) REFERENCES `tbl_company` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
