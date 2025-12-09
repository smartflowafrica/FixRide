<?php
/**
 * Company Dashboard API
 * Endpoint: POST /api/company/dashboard.php
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

// Get company info
$company = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();

if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Get wallet
$wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();

// Get car stats
$total_cars = $car->query("SELECT COUNT(*) as count FROM tbl_car WHERE company_id = $company_id")->fetch_assoc()['count'];
$active_cars = $car->query("SELECT COUNT(*) as count FROM tbl_car WHERE company_id = $company_id AND status = 1")->fetch_assoc()['count'];

// Get booking stats - join with tbl_car to filter by company
$total_bookings = $car->query("
    SELECT COUNT(*) as count FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE c.company_id = $company_id
")->fetch_assoc()['count'];

$pending_bookings = $car->query("
    SELECT COUNT(*) as count FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE c.company_id = $company_id AND b.book_status = 'Pending'
")->fetch_assoc()['count'];

$active_bookings = $car->query("
    SELECT COUNT(*) as count FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE c.company_id = $company_id AND b.book_status IN ('Confirm', 'PickUp')
")->fetch_assoc()['count'];

$completed_bookings = $car->query("
    SELECT COUNT(*) as count FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE c.company_id = $company_id AND b.book_status = 'Completed'
")->fetch_assoc()['count'];

// Get earnings stats
$commission_stats = $car->query("
    SELECT 
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(company_earning), 0) as total_earnings,
        COALESCE(SUM(commission_amount), 0) as total_commission
    FROM tbl_commission 
    WHERE company_id = $company_id
")->fetch_assoc();

// Get this month's earnings
$month_earnings = $car->query("
    SELECT COALESCE(SUM(company_earning), 0) as earnings
    FROM tbl_commission 
    WHERE company_id = $company_id 
    AND MONTH(created_at) = MONTH(CURRENT_DATE())
    AND YEAR(created_at) = YEAR(CURRENT_DATE())
")->fetch_assoc()['earnings'];

// Get recent bookings
$recent_bookings = [];
$rb_query = $car->query("
    SELECT b.*, c.car_title, c.car_img, u.name as customer_name, u.mobile as customer_phone
    FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    JOIN tbl_user u ON b.uid = u.id
    WHERE c.company_id = $company_id 
    ORDER BY b.id DESC LIMIT 5
");
while ($row = $rb_query->fetch_assoc()) {
    $recent_bookings[] = $row;
}

// Get pending payouts
$pending_payouts = $car->query("
    SELECT COALESCE(SUM(amount), 0) as total 
    FROM tbl_company_payout 
    WHERE company_id = $company_id AND status = 'pending'
")->fetch_assoc()['total'];

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Dashboard data retrieved",
    "company" => $company,
    "wallet" => $wallet,
    "stats" => [
        "total_cars" => (int)$total_cars,
        "active_cars" => (int)$active_cars,
        "total_bookings" => (int)$total_bookings,
        "pending_bookings" => (int)$pending_bookings,
        "active_bookings" => (int)$active_bookings,
        "completed_bookings" => (int)$completed_bookings
    ],
    "earnings" => [
        "total_revenue" => floatval($commission_stats['total_revenue']),
        "total_earnings" => floatval($commission_stats['total_earnings']),
        "total_commission" => floatval($commission_stats['total_commission']),
        "this_month" => floatval($month_earnings),
        "available_balance" => floatval($wallet['available_balance'] ?? 0),
        "pending_balance" => floatval($wallet['pending_balance'] ?? 0),
        "pending_payouts" => floatval($pending_payouts)
    ],
    "recent_bookings" => $recent_bookings
]);
?>
