<?php
/**
 * Company Login API
 * Endpoint: POST /api/company/login.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (empty($data['email']) || empty($data['password'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Email and password are required"
    ]);
    exit;
}

$email = $car->real_escape_string($data['email']);
$password = $data['password'];

// Get user with company info
$sql = "SELECT cu.*, c.company_name, c.slug, c.logo, c.status as company_status, c.is_verified 
        FROM tbl_company_user cu 
        JOIN tbl_company c ON cu.company_id = c.id 
        WHERE cu.email = '$email' AND cu.status = 1";

$result = $car->query($sql);

if ($result->num_rows == 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "401",
        "ResponseMsg" => "Invalid email or password"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// Verify password
if (!password_verify($password, $user['password'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "401",
        "ResponseMsg" => "Invalid email or password"
    ]);
    exit;
}

// Check company status
if ($user['company_status'] == 'suspended') {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "403",
        "ResponseMsg" => "Your company account has been suspended"
    ]);
    exit;
}

// Update last login
$car->query("UPDATE tbl_company_user SET last_login = NOW() WHERE id = " . $user['id']);

// Remove password from response
unset($user['password']);

// Get wallet info
$wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = " . $user['company_id'])->fetch_assoc();

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Login successful",
    "user" => $user,
    "wallet" => $wallet
]);
?>
