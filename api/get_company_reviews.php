<?php
/**
 * Get Company Reviews API (Public endpoint)
 * Endpoint: POST /api/get_company_reviews.php
 */
require dirname(__FILE__) . '/inc/Connection.php';
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
$limit = isset($data['limit']) ? intval($data['limit']) : 10;
$offset = ($page - 1) * $limit;

// Verify company exists
$company = $car->query("
    SELECT id, company_name, avg_rating, total_reviews 
    FROM tbl_company 
    WHERE id = $company_id AND status = '1'
")->fetch_assoc();

if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Get rating breakdown
$breakdown = $car->query("
    SELECT 
        SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star,
        SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star,
        SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star,
        SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star,
        SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star
    FROM tbl_company_review 
    WHERE company_id = $company_id AND status = 'approved'
")->fetch_assoc();

// Get reviews
$sql = "SELECT r.id, r.rating, r.review, r.company_reply, r.reply_at, r.created_at,
        u.name as user_name, u.pro_pic as user_image
        FROM tbl_company_review r
        JOIN tbl_user u ON r.user_id = u.id
        WHERE r.company_id = $company_id AND r.status = 'approved'
        ORDER BY r.created_at DESC
        LIMIT $limit OFFSET $offset";

$result = $car->query($sql);
$reviews = [];

while ($row = $result->fetch_assoc()) {
    $reviews[] = [
        'id' => intval($row['id']),
        'rating' => intval($row['rating']),
        'review' => $row['review'],
        'company_reply' => $row['company_reply'],
        'reply_at' => $row['reply_at'],
        'created_at' => $row['created_at'],
        'user_name' => $row['user_name'],
        'user_image' => $row['user_image']
    ];
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Reviews fetched successfully",
    "company" => [
        "id" => intval($company['id']),
        "name" => $company['company_name'],
        "avg_rating" => floatval($company['avg_rating']),
        "total_reviews" => intval($company['total_reviews'])
    ],
    "rating_breakdown" => [
        "5" => intval($breakdown['five_star'] ?? 0),
        "4" => intval($breakdown['four_star'] ?? 0),
        "3" => intval($breakdown['three_star'] ?? 0),
        "2" => intval($breakdown['two_star'] ?? 0),
        "1" => intval($breakdown['one_star'] ?? 0)
    ],
    "reviews" => $reviews,
    "page" => $page,
    "limit" => $limit
]);
?>
