<?php
/**
 * Delete/Disable Company Car API
 * Endpoint: POST /api/company/delete_car.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['company_id']) || empty($data['car_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID and Car ID are required"
    ]);
    exit;
}

$company_id = intval($data['company_id']);
$car_id = intval($data['car_id']);

// Verify car belongs to company
$existing = $car->query("SELECT * FROM tbl_car WHERE id = $car_id AND company_id = $company_id")->fetch_assoc();
if (!$existing) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Car not found or does not belong to this company"
    ]);
    exit;
}

// Check for active bookings
$active_bookings = $car->query("SELECT COUNT(*) as cnt FROM tbl_book 
    WHERE car_id = $car_id AND book_status IN ('Pending', 'Pick_Up')")->fetch_assoc()['cnt'];

if ($active_bookings > 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Cannot delete car with active bookings. Please complete or cancel $active_bookings active booking(s) first."
    ]);
    exit;
}

// Soft delete - set status to 0 (inactive)
$action = isset($data['permanent']) && $data['permanent'] == true ? 'permanent' : 'soft';

if ($action == 'permanent') {
    // Only allow permanent delete if no bookings at all
    $total_bookings = $car->query("SELECT COUNT(*) as cnt FROM tbl_book WHERE car_id = $car_id")->fetch_assoc()['cnt'];
    
    if ($total_bookings > 0) {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "400",
            "ResponseMsg" => "Cannot permanently delete car with booking history. Use soft delete instead."
        ]);
        exit;
    }
    
    // Delete car images
    $car->query("DELETE FROM tbl_car_ext WHERE car_id = $car_id");
    $car->query("DELETE FROM tbl_car_int WHERE car_id = $car_id");
    
    // Delete car
    if ($car->query("DELETE FROM tbl_car WHERE id = $car_id")) {
        // Update company car count
        $car->query("UPDATE tbl_company SET total_cars = total_cars - 1 WHERE id = $company_id AND total_cars > 0");
        
        echo json_encode([
            "Result" => "true",
            "ResponseCode" => "200",
            "ResponseMsg" => "Car permanently deleted"
        ]);
    } else {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "500",
            "ResponseMsg" => "Failed to delete car"
        ]);
    }
} else {
    // Soft delete - disable car
    if ($car->query("UPDATE tbl_car SET status = 0 WHERE id = $car_id")) {
        echo json_encode([
            "Result" => "true",
            "ResponseCode" => "200",
            "ResponseMsg" => "Car disabled successfully. It will no longer appear in listings."
        ]);
    } else {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "500",
            "ResponseMsg" => "Failed to disable car"
        ]);
    }
}
?>
