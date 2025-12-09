<?php
/**
 * Company Car List API
 * Endpoint: POST /api/company/car_list.php
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
if ($status !== null) {
    $where .= " AND c.status = '$status'";
}

// Get total count
$total = $car->query("SELECT COUNT(*) as count FROM tbl_car c WHERE $where")->fetch_assoc()['count'];

// Get cars
$sql = "SELECT c.*, 
        ct.title as car_type_title,
        cb.title as car_brand_title,
        city.title as city_title,
        (SELECT COUNT(*) FROM tbl_book WHERE car_id = c.id) as total_bookings,
        (SELECT AVG(rate) FROM tbl_rate WHERE car_id = c.id) as avg_rating
        FROM tbl_car c
        LEFT JOIN tbl_car_type ct ON c.type_id = ct.id
        LEFT JOIN tbl_car_brand cb ON c.brand_id = cb.id
        LEFT JOIN tbl_city city ON c.city_id = city.id
        WHERE $where
        ORDER BY c.id DESC
        LIMIT $limit OFFSET $offset";

$result = $car->query($sql);
$cars = [];

while ($row = $result->fetch_assoc()) {
    $cars[] = $row;
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Cars retrieved",
    "total" => (int)$total,
    "page" => $page,
    "limit" => $limit,
    "cars" => $cars
]);
?>
