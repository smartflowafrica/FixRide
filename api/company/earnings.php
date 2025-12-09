<?php
/**
 * Company Earnings/Commission History API
 * Endpoint: POST /api/company/earnings.php
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
$page = isset($data['page']) ? intval($data['page']) : 1;
$limit = isset($data['limit']) ? intval($data['limit']) : 20;
$offset = ($page - 1) * $limit;

// Date filters
$from_date = isset($data['from_date']) ? $car->real_escape_string($data['from_date']) : null;
$to_date = isset($data['to_date']) ? $car->real_escape_string($data['to_date']) : null;

$where = "c.company_id = $company_id";
if ($from_date) {
    $where .= " AND DATE(c.created_at) >= '$from_date'";
}
if ($to_date) {
    $where .= " AND DATE(c.created_at) <= '$to_date'";
}

// Get total count
$total = $car->query("SELECT COUNT(*) as count FROM tbl_commission c WHERE $where")->fetch_assoc()['count'];

// Get summary
$summary = $car->query("
    SELECT 
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(company_earning), 0) as total_earnings,
        COALESCE(SUM(commission_amount), 0) as platform_commission,
        COUNT(*) as total_transactions
    FROM tbl_commission c 
    WHERE $where
")->fetch_assoc();

// Get commission history
$sql = "SELECT c.*, 
        b.pickup_date, b.return_date, b.book_status,
        car.car_title, car.car_img,
        u.name as customer_name
        FROM tbl_commission c
        JOIN tbl_book b ON c.booking_id = b.id
        JOIN tbl_car car ON b.car_id = car.id
        JOIN tbl_user u ON b.uid = u.id
        WHERE $where
        ORDER BY c.created_at DESC
        LIMIT $limit OFFSET $offset";

$result = $car->query($sql);
$commissions = [];

while ($row = $result->fetch_assoc()) {
    $commissions[] = $row;
}

// Get monthly breakdown for chart
$monthly = [];
$monthly_query = $car->query("
    SELECT 
        DATE_FORMAT(created_at, '%Y-%m') as month,
        SUM(company_earning) as earnings,
        SUM(total_amount) as revenue,
        COUNT(*) as bookings
    FROM tbl_commission 
    WHERE company_id = $company_id 
    AND created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
    ORDER BY month ASC
");
while ($row = $monthly_query->fetch_assoc()) {
    $monthly[] = $row;
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Earnings retrieved",
    "total" => (int)$total,
    "page" => $page,
    "limit" => $limit,
    "summary" => [
        "total_revenue" => floatval($summary['total_revenue']),
        "total_earnings" => floatval($summary['total_earnings']),
        "platform_commission" => floatval($summary['platform_commission']),
        "total_transactions" => (int)$summary['total_transactions']
    ],
    "monthly" => $monthly,
    "commissions" => $commissions
]);
?>
