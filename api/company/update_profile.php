<?php
/**
 * Company Profile Update API
 * Endpoint: POST /api/company/update_profile.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

// Handle both JSON and multipart form data
$data = $_POST;
if (empty($data)) {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
}

if (empty($data['company_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID is required"
    ]);
    exit;
}

$company_id = intval($data['company_id']);

// Verify company exists
$company = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Build update fields
$updates = [];

if (isset($data['company_name'])) {
    $updates[] = "company_name = '" . $car->real_escape_string($data['company_name']) . "'";
}
if (isset($data['phone'])) {
    $updates[] = "phone = '" . $car->real_escape_string($data['phone']) . "'";
}
if (isset($data['address'])) {
    $updates[] = "address = '" . $car->real_escape_string($data['address']) . "'";
}
if (isset($data['description'])) {
    $updates[] = "description = '" . $car->real_escape_string($data['description']) . "'";
}
if (isset($data['city_id'])) {
    $updates[] = "city_id = " . intval($data['city_id']);
}

// Handle logo upload
if (isset($_FILES['logo']) && $_FILES['logo']['error'] == 0) {
    $upload_dir = dirname(dirname(__FILE__)) . '/images/company/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }
    
    $filename = 'logo_' . $company_id . '_' . time() . '.' . pathinfo($_FILES['logo']['name'], PATHINFO_EXTENSION);
    $target = $upload_dir . $filename;
    
    if (move_uploaded_file($_FILES['logo']['tmp_name'], $target)) {
        $updates[] = "logo = 'images/company/$filename'";
    }
}

// Handle cover image upload
if (isset($_FILES['cover_image']) && $_FILES['cover_image']['error'] == 0) {
    $upload_dir = dirname(dirname(__FILE__)) . '/images/company/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }
    
    $filename = 'cover_' . $company_id . '_' . time() . '.' . pathinfo($_FILES['cover_image']['name'], PATHINFO_EXTENSION);
    $target = $upload_dir . $filename;
    
    if (move_uploaded_file($_FILES['cover_image']['tmp_name'], $target)) {
        $updates[] = "cover_image = 'images/company/$filename'";
    }
}

if (empty($updates)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "No fields to update"
    ]);
    exit;
}

$sql = "UPDATE tbl_company SET " . implode(', ', $updates) . " WHERE id = $company_id";

if ($car->query($sql)) {
    $updated = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Profile updated successfully",
        "company" => $updated
    ]);
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => "Failed to update profile"
    ]);
}
?>
