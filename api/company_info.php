<?php
/**
 * Get Company Public Profile API
 * Endpoint: GET /api/company_info.php?company_id=X or ?slug=company-slug
 */
require_once 'inc/Connection.php';
header('Content-type: application/json');

$company = null;

if (!empty($_GET['company_id'])) {
    $company_id = intval($_GET['company_id']);
    $company = $car->query("SELECT * FROM tbl_company WHERE id = $company_id AND status = 'active'")->fetch_assoc();
} elseif (!empty($_GET['slug'])) {
    $slug = $car->real_escape_string($_GET['slug']);
    $company = $car->query("SELECT * FROM tbl_company WHERE slug = '$slug' AND status = 'active'")->fetch_assoc();
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID or slug is required"
    ]);
    exit;
}

if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

$company_id = $company['id'];

// Get city info
if ($company['city_id']) {
    $city = $car->query("SELECT * FROM tbl_city WHERE id = " . $company['city_id'])->fetch_assoc();
    $company['city'] = $city;
}

// Get car count
$car_count = $car->query("SELECT COUNT(*) as cnt FROM tbl_car WHERE company_id = $company_id AND status = 1")->fetch_assoc()['cnt'];
$company['active_cars'] = intval($car_count);

// Get recent reviews
$reviews = [];
$review_result = $car->query("SELECT cr.*, u.name as user_name, u.pro_pic as user_image 
    FROM tbl_company_review cr 
    JOIN tbl_user u ON cr.user_id = u.id 
    WHERE cr.company_id = $company_id AND cr.status = 1 
    ORDER BY cr.created_at DESC LIMIT 5");
if ($review_result) {
    while ($row = $review_result->fetch_assoc()) {
        $reviews[] = $row;
    }
}

// Get company cars (limited)
$cars = [];
$car_result = $car->query("SELECT c.*, cb.title as brand_name, ct.title as type_name 
    FROM tbl_car c 
    LEFT JOIN tbl_carbrand cb ON c.brand = cb.id 
    LEFT JOIN tbl_cartype ct ON c.type_id = ct.id 
    WHERE c.company_id = $company_id AND c.status = 1 
    ORDER BY c.id DESC LIMIT 6");
while ($row = $car_result->fetch_assoc()) {
    $cars[] = $row;
}

// Remove sensitive data
unset($company['commission_rate']);
unset($company['min_payout_amount']);

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Company data retrieved successfully",
    "company" => $company,
    "recent_reviews" => $reviews,
    "featured_cars" => $cars
]);
?>
