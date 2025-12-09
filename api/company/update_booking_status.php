<?php
/**
 * Update Booking Status API
 * Endpoint: POST /api/company/update_booking_status.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
require __DIR__ . '/inc/company_helpers.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['company_id']) || empty($data['booking_id']) || empty($data['status'])) {
    companyErrorResponse('Company ID, Booking ID and Status are required', '400');
}

$company_id = intval($data['company_id']);
$booking_id = intval($data['booking_id']);
$new_status = $car->real_escape_string($data['status']);

// Validate company is active
$companyAuth = validateCompanyAuth($car, $data);
if (!$companyAuth['success']) {
    companyErrorResponse($companyAuth['message'], $companyAuth['code']);
}

// Valid statuses
$valid_statuses = ['Pending', 'Pick_Up', 'Completed', 'Cancelled'];
if (!in_array($new_status, $valid_statuses)) {
    companyErrorResponse('Invalid status. Must be: ' . implode(', ', $valid_statuses), '400');
}

// Verify booking belongs to company using helper function
if (!verifyBookingOwnership($car, $booking_id, $company_id)) {
    companyErrorResponse('Booking not found or does not belong to this company', '404');
}

// Get booking details
$booking = $car->query("SELECT b.*, c.company_id 
    FROM tbl_book b 
    JOIN tbl_car c ON b.car_id = c.id 
    WHERE b.id = $booking_id AND c.company_id = $company_id")->fetch_assoc();

$current_status = $booking['book_status'];

// Validate status transitions
$allowed_transitions = [
    'Pending' => ['Pick_Up', 'Cancelled'],
    'Pick_Up' => ['Completed', 'Cancelled'],
    'Completed' => [],
    'Cancelled' => []
];

if (!in_array($new_status, $allowed_transitions[$current_status])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Cannot change status from $current_status to $new_status"
    ]);
    exit;
}

$car->begin_transaction();

try {
    // Update booking status
    $car->query("UPDATE tbl_book SET book_status = '$new_status' WHERE id = $booking_id");
    
    // Handle status-specific actions
    if ($new_status == 'Pick_Up') {
        // Record pickup time
        $car->query("UPDATE tbl_book SET pick_up_time = NOW() WHERE id = $booking_id");
    }
    
    if ($new_status == 'Completed') {
        // Record drop time
        $car->query("UPDATE tbl_book SET drop_time = NOW() WHERE id = $booking_id");
        
        // Credit company wallet
        $commission = $car->query("SELECT * FROM tbl_commission WHERE booking_id = $booking_id")->fetch_assoc();
        
        if ($commission) {
            $company_earning = floatval($commission['company_earning']);
            
            // Update commission status
            $car->query("UPDATE tbl_commission SET status = 'paid', paid_at = NOW() WHERE booking_id = $booking_id");
            
            // Get current wallet balance
            $wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();
            
            if ($wallet) {
                $new_balance = $wallet['available_balance'] + $company_earning;
                $new_total = $wallet['total_earned'] + $company_earning;
                
                $car->query("UPDATE tbl_company_wallet SET 
                    available_balance = $new_balance,
                    total_earned = $new_total
                WHERE company_id = $company_id");
                
                // Record transaction
                $car->query("INSERT INTO tbl_company_wallet_transaction 
                    (company_id, type, amount, balance_after, description, reference_type, reference_id)
                    VALUES ($company_id, 'credit', $company_earning, $new_balance, 'Booking #$booking_id completed', 'booking', $booking_id)");
            }
        }
        
        // Update company total bookings
        $car->query("UPDATE tbl_company SET total_bookings = total_bookings + 1 WHERE id = $company_id");
    }
    
    if ($new_status == 'Cancelled') {
        // Update commission status
        $car->query("UPDATE tbl_commission SET status = 'cancelled' WHERE booking_id = $booking_id");
        
        // Note: Refund logic would go here if needed
        $cancellation_reason = isset($data['reason']) ? $car->real_escape_string($data['reason']) : '';
        if ($cancellation_reason) {
            $car->query("UPDATE tbl_book SET cancel_reason = '$cancellation_reason' WHERE id = $booking_id");
        }
    }
    
    // Send notification to user
    $user_id = $booking['uid'];
    $notification_msg = "";
    
    switch ($new_status) {
        case 'Pick_Up':
            $notification_msg = "Your car is ready for pickup! Booking #$booking_id";
            break;
        case 'Completed':
            $notification_msg = "Your booking #$booking_id has been completed. Thank you!";
            break;
        case 'Cancelled':
            $notification_msg = "Your booking #$booking_id has been cancelled.";
            break;
    }
    
    if ($notification_msg) {
        $car->query("INSERT INTO tbl_noti (uid, title, description) 
            VALUES ($user_id, 'Booking Update', '$notification_msg')");
    }
    
    $car->commit();
    
    // Get updated booking
    $updated = $car->query("SELECT * FROM tbl_book WHERE id = $booking_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Booking status updated to $new_status",
        "booking" => $updated
    ]);
    
} catch (Exception $e) {
    $car->rollback();
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => $e->getMessage()
    ]);
}
?>
