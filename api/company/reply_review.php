<?php
/**
 * Reply to Company Review API
 * Endpoint: POST /api/company/reply_review.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
require __DIR__ . '/inc/company_helpers.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['company_id']) || empty($data['review_id']) || empty($data['reply'])) {
    companyErrorResponse('Company ID, Review ID and Reply are required', '400');
}

$company_id = intval($data['company_id']);
$review_id = intval($data['review_id']);
$reply = $car->real_escape_string(trim($data['reply']));

// Validate company is active
$companyAuth = validateCompanyAuth($car, $data);
if (!$companyAuth['success']) {
    companyErrorResponse($companyAuth['message'], $companyAuth['code']);
}

// Verify review belongs to this company
$review = $car->query("
    SELECT * FROM tbl_company_review 
    WHERE id = $review_id AND company_id = $company_id
")->fetch_assoc();

if (!$review) {
    companyErrorResponse('Review not found or does not belong to this company', '404');
}

// Update review with reply
$now = date('Y-m-d H:i:s');
$result = $car->query("
    UPDATE tbl_company_review 
    SET company_reply = '$reply', reply_at = '$now'
    WHERE id = $review_id
");

if ($result) {
    // Log activity
    $userId = isset($data['user_id']) ? intval($data['user_id']) : 0;
    logCompanyActivity($car, $company_id, $userId, 'review_reply', "Replied to review #$review_id", $review_id);
    
    companySuccessResponse('Reply added successfully', [
        'review_id' => $review_id,
        'reply' => $reply,
        'reply_at' => $now
    ]);
} else {
    companyErrorResponse('Failed to add reply', '500');
}
?>
