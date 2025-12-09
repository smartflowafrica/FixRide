<?php
/**
 * Company Bookings API
 * Endpoint: POST /api/company/bookings.php
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
$status = isset($data['status']) ? $car->real_escape_string($data['status']) : null;
$page = isset($data['page']) ? intval($data['page']) : 1;
$limit = isset($data['limit']) ? intval($data['limit']) : 20;
$offset = ($page - 1) * $limit;

// Build query
$where = "c.company_id = $company_id";
if ($status !== null && $status !== 'all') {
    $where .= " AND b.book_status = '$status'";
}

// Get total count
$total = $car->query("
    SELECT COUNT(*) as count 
    FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE $where
")->fetch_assoc()['count'];

// Get bookings
$sql = "SELECT b.*, 
        c.car_title, c.car_img, c.car_number,
        u.name as customer_name, u.mobile as customer_phone, u.email as customer_email,
        u.pro_pic as customer_image,
        ct.title as car_type,
        city.title as city_name
        FROM tbl_book b
        JOIN tbl_car c ON b.car_id = c.id
        JOIN tbl_user u ON b.uid = u.id
        LEFT JOIN tbl_car_type ct ON c.type_id = ct.id
        LEFT JOIN tbl_city city ON c.city_id = city.id
        WHERE $where
        ORDER BY b.id DESC
        LIMIT $limit OFFSET $offset";

$result = $car->query($sql);
$bookings = [];

while ($row = $result->fetch_assoc()) {
    // Get commission info if exists
    $commission = $car->query("SELECT * FROM tbl_commission WHERE booking_id = " . $row['id'])->fetch_assoc();
    $row['commission'] = $commission;
    $bookings[] = $row;
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Bookings retrieved",
    "total" => (int)$total,
    "page" => $page,
    "limit" => $limit,
    "bookings" => $bookings
]);
?>
