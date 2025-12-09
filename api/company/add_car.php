<?php
/**
 * Company Add Car API
 * Endpoint: POST /api/company/add_car.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

// Handle multipart form data
$data = $_POST;

// Required fields
$required = ['company_id', 'car_title', 'type_id', 'brand_id', 'city_id', 'car_rent_price'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "400",
            "ResponseMsg" => "Missing required field: $field"
        ]);
        exit;
    }
}

$company_id = intval($data['company_id']);

// Verify company exists and is active
$company = $car->query("SELECT id, status FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

if ($company['status'] != 'active') {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "403",
        "ResponseMsg" => "Company account is not active. Please wait for verification."
    ]);
    exit;
}

// Handle image upload
$car_img = '';
if (isset($_FILES['car_img']) && $_FILES['car_img']['error'] == 0) {
    $upload_dir = dirname(dirname(__FILE__)) . '/images/car/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }
    
    $filename = time() . '_' . basename($_FILES['car_img']['name']);
    $target = $upload_dir . $filename;
    
    if (move_uploaded_file($_FILES['car_img']['tmp_name'], $target)) {
        $car_img = 'images/car/' . $filename;
    }
}

// Escape inputs
$car_title = $car->real_escape_string($data['car_title']);
$type_id = intval($data['type_id']);
$brand_id = intval($data['brand_id']);
$city_id = intval($data['city_id']);
$car_rent_price = floatval($data['car_rent_price']);
$car_rent_price_driver = isset($data['car_rent_price_driver']) ? floatval($data['car_rent_price_driver']) : $car_rent_price;
$price_type = isset($data['price_type']) ? $car->real_escape_string($data['price_type']) : '2'; // 1=hourly, 2=daily
$seat = isset($data['seat']) ? intval($data['seat']) : 4;
$fuel_type = isset($data['fuel_type']) ? $car->real_escape_string($data['fuel_type']) : 'Petrol';
$gear_type = isset($data['gear_type']) ? $car->real_escape_string($data['gear_type']) : 'Automatic';
$engine = isset($data['engine']) ? $car->real_escape_string($data['engine']) : '';
$car_number = isset($data['car_number']) ? $car->real_escape_string($data['car_number']) : '';
$description = isset($data['description']) ? $car->real_escape_string($data['description']) : '';
$facility = isset($data['facility']) ? $car->real_escape_string($data['facility']) : '';

$sql = "INSERT INTO tbl_car (
            company_id, car_title, type_id, brand_id, city_id, 
            car_rent_price, car_rent_price_driver, price_type,
            seat, fuel_type, gear_type, engine, car_number,
            car_description, facility, car_img, status
        ) VALUES (
            $company_id, '$car_title', $type_id, $brand_id, $city_id,
            $car_rent_price, $car_rent_price_driver, '$price_type',
            $seat, '$fuel_type', '$gear_type', '$engine', '$car_number',
            '$description', '$facility', '$car_img', 1
        )";

if ($car->query($sql)) {
    $car_id = $car->insert_id;
    
    // Update company car count
    $car->query("UPDATE tbl_company SET total_cars = total_cars + 1 WHERE id = $company_id");
    
    // Get inserted car
    $newCar = $car->query("SELECT * FROM tbl_car WHERE id = $car_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Car added successfully",
        "car" => $newCar
    ]);
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => "Failed to add car: " . $car->error
    ]);
}
?>
