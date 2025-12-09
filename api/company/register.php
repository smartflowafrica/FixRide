<?php
/**
 * Company Registration API
 * Endpoint: POST /api/company/register.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Required fields
$required = ['company_name', 'email', 'password', 'phone', 'city_id'];
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

$company_name = $car->real_escape_string($data['company_name']);
$email = $car->real_escape_string($data['email']);
$password = password_hash($data['password'], PASSWORD_DEFAULT);
$phone = $car->real_escape_string($data['phone']);
$city_id = intval($data['city_id']);
$address = isset($data['address']) ? $car->real_escape_string($data['address']) : '';
$business_reg_number = isset($data['business_reg_number']) ? $car->real_escape_string($data['business_reg_number']) : '';

// Generate slug
$slug = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '-', $company_name));
$slug = $slug . '-' . rand(1000, 9999);

// Check if email already exists
$check = $car->query("SELECT id FROM tbl_company WHERE email = '$email'");
if ($check->num_rows > 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "409",
        "ResponseMsg" => "Email already registered"
    ]);
    exit;
}

// Check company user email
$checkUser = $car->query("SELECT id FROM tbl_company_user WHERE email = '$email'");
if ($checkUser->num_rows > 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "409",
        "ResponseMsg" => "Email already registered"
    ]);
    exit;
}

// Start transaction
$car->begin_transaction();

try {
    // Insert company
    $sql = "INSERT INTO tbl_company (company_name, slug, email, phone, address, city_id, business_reg_number, status) 
            VALUES ('$company_name', '$slug', '$email', '$phone', '$address', $city_id, '$business_reg_number', 'pending')";
    
    if (!$car->query($sql)) {
        throw new Exception("Failed to create company");
    }
    
    $company_id = $car->insert_id;
    
    // Get owner name from data or use company name
    $owner_name = isset($data['owner_name']) ? $car->real_escape_string($data['owner_name']) : $company_name;
    
    // Insert company owner user
    $sql2 = "INSERT INTO tbl_company_user (company_id, name, email, password, phone, role, status) 
             VALUES ($company_id, '$owner_name', '$email', '$password', '$phone', 'owner', 1)";
    
    if (!$car->query($sql2)) {
        throw new Exception("Failed to create company user");
    }
    
    $user_id = $car->insert_id;
    
    $car->commit();
    
    // Get company data
    $companyData = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();
    $userData = $car->query("SELECT id, company_id, name, email, phone, role, status FROM tbl_company_user WHERE id = $user_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Company registered successfully. Pending verification.",
        "company" => $companyData,
        "user" => $userData
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
