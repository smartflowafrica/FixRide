<?php
/**
 * Company Payout History API
 * Endpoint: GET /api/company/payout_history.php?company_id=X
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

// Filter by status
$where = "company_id = $company_id";
if (!empty($_GET['status'])) {
    $status = $car->real_escape_string($_GET['status']);
    $where .= " AND status = '$status'";
}

// Date range filter
if (!empty($_GET['start_date'])) {
    $start = $car->real_escape_string($_GET['start_date']);
    $where .= " AND requested_at >= '$start'";
}
if (!empty($_GET['end_date'])) {
    $end = $car->real_escape_string($_GET['end_date']);
    $where .= " AND requested_at <= '$end 23:59:59'";
}

// Get payouts
$payouts = [];
$result = $car->query("SELECT * FROM tbl_company_payout 
    WHERE $where 
    ORDER BY requested_at DESC 
    LIMIT $limit OFFSET $offset");

while ($row = $result->fetch_assoc()) {
    // Mask sensitive data
    if ($row['account_number']) {
        $row['account_number_masked'] = '****' . substr($row['account_number'], -4);
    }
    $payouts[] = $row;
}

// Get total count
$total = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_payout WHERE $where")->fetch_assoc()['cnt'];

// Get summary
$summary = $car->query("SELECT 
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as total_paid,
    SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END) as total_pending,
    SUM(CASE WHEN status = 'processing' THEN amount ELSE 0 END) as total_processing,
    SUM(CASE WHEN status = 'rejected' THEN amount ELSE 0 END) as total_rejected,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count
FROM tbl_company_payout WHERE company_id = $company_id")->fetch_assoc();

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Payout history retrieved successfully",
    "summary" => [
        "total_paid" => floatval($summary['total_paid'] ?? 0),
        "total_pending" => floatval($summary['total_pending'] ?? 0),
        "total_processing" => floatval($summary['total_processing'] ?? 0),
        "total_rejected" => floatval($summary['total_rejected'] ?? 0),
        "completed_count" => intval($summary['completed_count'] ?? 0),
        "pending_count" => intval($summary['pending_count'] ?? 0)
    ],
    "payouts" => $payouts,
    "pagination" => [
        "current_page" => $page,
        "per_page" => $limit,
        "total" => intval($total),
        "total_pages" => ceil($total / $limit)
    ]
]);
?>
