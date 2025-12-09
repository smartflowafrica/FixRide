<?php
/**
 * Get Company Reviews API
 * Endpoint: POST /api/company/reviews.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
require __DIR__ . '/inc/company_helpers.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['company_id'])) {
    companyErrorResponse('Company ID is required', '400');
}

$company_id = intval($data['company_id']);
$page = isset($data['page']) ? intval($data['page']) : 1;
$limit = isset($data['limit']) ? intval($data['limit']) : 20;
$offset = ($page - 1) * $limit;

// Validate company exists
$company = verifyCompanyActive($car, $company_id);
if (!$company) {
    companyErrorResponse('Company not found', '404');
}

// Get review stats
$stats = $car->query("
    SELECT 
        COUNT(*) as total_reviews,
        COALESCE(ROUND(AVG(rating), 2), 0) as avg_rating,
        SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star,
        SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star,
        SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star,
        SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star,
        SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star
    FROM tbl_company_review 
    WHERE company_id = $company_id AND status = 'approved'
")->fetch_assoc();

// Get reviews with user info
$sql = "SELECT r.*, 
        u.name as user_name, u.pro_pic as user_image,
        b.car_id, c.car_title
        FROM tbl_company_review r
        JOIN tbl_user u ON r.user_id = u.id
        LEFT JOIN tbl_book b ON r.booking_id = b.id
        LEFT JOIN tbl_car c ON b.car_id = c.id
        WHERE r.company_id = $company_id AND r.status = 'approved'
        ORDER BY r.created_at DESC
        LIMIT $limit OFFSET $offset";

$result = $car->query($sql);
$reviews = [];

while ($row = $result->fetch_assoc()) {
    $reviews[] = [
        'id' => $row['id'],
        'rating' => intval($row['rating']),
        'review' => $row['review'],
        'company_reply' => $row['company_reply'],
        'reply_at' => $row['reply_at'],
        'created_at' => $row['created_at'],
        'user' => [
            'id' => $row['user_id'],
            'name' => $row['user_name'],
            'image' => $row['user_image']
        ],
        'car_title' => $row['car_title']
    ];
}

companySuccessResponse('Reviews fetched successfully', [
    'stats' => [
        'total_reviews' => intval($stats['total_reviews']),
        'avg_rating' => floatval($stats['avg_rating']),
        'rating_breakdown' => [
            '5' => intval($stats['five_star']),
            '4' => intval($stats['four_star']),
            '3' => intval($stats['three_star']),
            '2' => intval($stats['two_star']),
            '1' => intval($stats['one_star'])
        ]
    ],
    'reviews' => $reviews,
    'pagination' => [
        'page' => $page,
        'limit' => $limit,
        'total' => intval($stats['total_reviews'])
    ]
]);
?>
