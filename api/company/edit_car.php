<?php
/**
 * Edit Company Car API
 * Endpoint: POST /api/company/edit_car.php
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

// Build update query
$updates = [];

$fields = [
    'title' => 'string',
    'brand' => 'int',
    'type_id' => 'int',
    'fuel' => 'string',
    'transmission' => 'string',
    'seat' => 'int',
    'city' => 'int',
    'ac_heater' => 'string',
    'price' => 'float',
    'price_type' => 'string',
    'description' => 'string',
    'status' => 'int'
];

foreach ($fields as $field => $type) {
    if (isset($data[$field])) {
        if ($type == 'string') {
            $value = $car->real_escape_string($data[$field]);
            $updates[] = "$field = '$value'";
        } elseif ($type == 'int') {
            $updates[] = "$field = " . intval($data[$field]);
        } elseif ($type == 'float') {
            $updates[] = "$field = " . floatval($data[$field]);
        }
    }
}

// Handle facilities array
if (isset($data['facility']) && is_array($data['facility'])) {
    $facility = $car->real_escape_string(implode(',', $data['facility']));
    $updates[] = "facility = '$facility'";
}

if (empty($updates)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "No fields to update"
    ]);
    exit;
}

$sql = "UPDATE tbl_car SET " . implode(', ', $updates) . " WHERE id = $car_id";

if ($car->query($sql)) {
    $updated = $car->query("SELECT c.*, cb.title as brand_name, ct.title as type_name 
        FROM tbl_car c 
        LEFT JOIN tbl_carbrand cb ON c.brand = cb.id 
        LEFT JOIN tbl_cartype ct ON c.type_id = ct.id 
        WHERE c.id = $car_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Car updated successfully",
        "car" => $updated
    ]);
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => "Failed to update car"
    ]);
}
?>
