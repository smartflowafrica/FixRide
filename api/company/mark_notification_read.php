<?php
/**
 * Mark Notification as Read API
 * Endpoint: POST /api/company/mark_notification_read.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['company_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID is required"
    ]);
    exit;
}

$company_id = intval($data['company_id']);

// Mark single notification or all
if (!empty($data['notification_id'])) {
    $notification_id = intval($data['notification_id']);
    $car->query("UPDATE tbl_company_notification SET is_read = 1 
        WHERE id = $notification_id AND company_id = $company_id");
    $msg = "Notification marked as read";
} else {
    // Mark all as read
    $car->query("UPDATE tbl_company_notification SET is_read = 1 WHERE company_id = $company_id");
    $msg = "All notifications marked as read";
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => $msg
]);
?>
