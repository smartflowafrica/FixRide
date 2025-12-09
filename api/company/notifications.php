<?php
/**
 * Company Notifications API
 * Endpoint: GET /api/company/notifications.php?company_id=X
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

if (empty($_GET['company_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID is required"
    ]);
    exit;
}

$company_id = intval($_GET['company_id']);

// Pagination
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
$offset = ($page - 1) * $limit;

// Check if table exists, if not create it
$table_check = $car->query("SHOW TABLES LIKE 'tbl_company_notification'");
if ($table_check->num_rows == 0) {
    $car->query("CREATE TABLE IF NOT EXISTS tbl_company_notification (
        id INT PRIMARY KEY AUTO_INCREMENT,
        company_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        type ENUM('booking', 'payout', 'system', 'document', 'other') DEFAULT 'other',
        reference_id INT NULL,
        is_read TINYINT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (company_id) REFERENCES tbl_company(id) ON DELETE CASCADE,
        INDEX idx_company_read (company_id, is_read)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}

// Get notifications
$notifications = [];
$result = $car->query("SELECT * FROM tbl_company_notification 
    WHERE company_id = $company_id 
    ORDER BY created_at DESC 
    LIMIT $limit OFFSET $offset");

while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

// Get counts
$total = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_notification WHERE company_id = $company_id")->fetch_assoc()['cnt'];
$unread = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_notification WHERE company_id = $company_id AND is_read = 0")->fetch_assoc()['cnt'];

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Notifications retrieved successfully",
    "unread_count" => intval($unread),
    "notifications" => $notifications,
    "pagination" => [
        "current_page" => $page,
        "per_page" => $limit,
        "total" => intval($total),
        "total_pages" => ceil($total / $limit)
    ]
]);
?>