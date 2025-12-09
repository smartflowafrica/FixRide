<?php
/**
 * Add Company Review API (Customer endpoint)
 * Endpoint: POST /api/add_company_review.php
 */
require dirname(__FILE__) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate required fields
if (empty($data['company_id']) || empty($data['user_id']) || empty($data['rating'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID, User ID and Rating are required"
    ]);
    exit;
}

$company_id = intval($data['company_id']);
$user_id = intval($data['user_id']);
$booking_id = !empty($data['booking_id']) ? intval($data['booking_id']) : null;
$rating = intval($data['rating']);
$review = !empty($data['review']) ? $car->real_escape_string(trim($data['review'])) : '';

// Validate rating range
if ($rating < 1 || $rating > 5) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Rating must be between 1 and 5"
    ]);
    exit;
}

// Verify company exists
$company = $car->query("SELECT id, company_name FROM tbl_company WHERE id = $company_id AND status = '1'")->fetch_assoc();
if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Verify user exists
$user = $car->query("SELECT id, name FROM tbl_user WHERE id = $user_id")->fetch_assoc();
if (!$user) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "User not found"
    ]);
    exit;
}

// If booking_id provided, verify it belongs to user and company
if ($booking_id) {
    $booking = $car->query("
        SELECT b.id, b.book_status, c.company_id 
        FROM tbl_book b 
        JOIN tbl_car c ON b.car_id = c.id 
        WHERE b.id = $booking_id AND b.uid = $user_id AND c.company_id = $company_id
    ")->fetch_assoc();
    
    if (!$booking) {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "404",
            "ResponseMsg" => "Booking not found or does not match user/company"
        ]);
        exit;
    }
    
    // Only allow review for completed bookings
    if ($booking['book_status'] != 'Completed') {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "400",
            "ResponseMsg" => "Can only review completed bookings"
        ]);
        exit;
    }
    
    // Check if already reviewed this booking
    $existing = $car->query("
        SELECT id FROM tbl_company_review 
        WHERE user_id = $user_id AND booking_id = $booking_id
    ")->fetch_assoc();
    
    if ($existing) {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "400",
            "ResponseMsg" => "You have already reviewed this booking"
        ]);
        exit;
    }
}

// Insert review
$booking_id_sql = $booking_id ? $booking_id : 'NULL';
$result = $car->query("
    INSERT INTO tbl_company_review (company_id, user_id, booking_id, rating, review)
    VALUES ($company_id, $user_id, $booking_id_sql, $rating, '$review')
");

if ($result) {
    $review_id = $car->insert_id;
    
    // Send notification to company
    $car->query("
        INSERT INTO tbl_company_notification (company_id, title, description, type, reference_id)
        VALUES ($company_id, 'New Review!', '{$user['name']} left a $rating-star review', 'review', $review_id)
    ");
    
    // Get updated company stats
    $stats = $car->query("
        SELECT avg_rating, total_reviews 
        FROM tbl_company 
        WHERE id = $company_id
    ")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Review submitted successfully",
        "review_id" => $review_id,
        "company_stats" => [
            "avg_rating" => floatval($stats['avg_rating']),
            "total_reviews" => intval($stats['total_reviews'])
        ]
    ]);
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => "Failed to submit review: " . $car->error
    ]);
}
?>
