<?php
/**
 * Company Payout Request API
 * Endpoint: POST /api/company/request_payout.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Required fields
if (empty($data['company_id']) || empty($data['amount'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID and amount are required"
    ]);
    exit;
}

$company_id = intval($data['company_id']);
$amount = floatval($data['amount']);
$payment_method = isset($data['payment_method']) ? $car->real_escape_string($data['payment_method']) : 'bank_transfer';

// Get company wallet
$wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();

if (!$wallet) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Wallet not found"
    ]);
    exit;
}

// Check minimum payout
$company = $car->query("SELECT min_payout_amount FROM tbl_company WHERE id = $company_id")->fetch_assoc();
$min_payout = floatval($company['min_payout_amount'] ?? 100);

if ($amount < $min_payout) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Minimum payout amount is $min_payout"
    ]);
    exit;
}

// Check available balance
if ($amount > $wallet['available_balance']) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Insufficient balance. Available: " . $wallet['available_balance']
    ]);
    exit;
}

// Check for pending payout
$pending = $car->query("SELECT id FROM tbl_company_payout WHERE company_id = $company_id AND status IN ('pending', 'processing')")->num_rows;
if ($pending > 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "You have a pending payout request. Please wait for it to be processed."
    ]);
    exit;
}

// Get payment details based on method
$bank_name = isset($data['bank_name']) ? $car->real_escape_string($data['bank_name']) : '';
$account_number = isset($data['account_number']) ? $car->real_escape_string($data['account_number']) : '';
$account_name = isset($data['account_name']) ? $car->real_escape_string($data['account_name']) : '';
$paypal_email = isset($data['paypal_email']) ? $car->real_escape_string($data['paypal_email']) : '';
$mobile_money_number = isset($data['mobile_money_number']) ? $car->real_escape_string($data['mobile_money_number']) : '';

// Validate payment method details
if ($payment_method == 'bank_transfer' && (empty($bank_name) || empty($account_number) || empty($account_name))) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Bank details are required for bank transfer"
    ]);
    exit;
}

if ($payment_method == 'paypal' && empty($paypal_email)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "PayPal email is required"
    ]);
    exit;
}

if ($payment_method == 'mobile_money' && empty($mobile_money_number)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Mobile money number is required"
    ]);
    exit;
}

// Start transaction
$car->begin_transaction();

try {
    // Create payout request
    $sql = "INSERT INTO tbl_company_payout (
                company_id, amount, payment_method, 
                bank_name, account_number, account_name,
                paypal_email, mobile_money_number, status
            ) VALUES (
                $company_id, $amount, '$payment_method',
                '$bank_name', '$account_number', '$account_name',
                '$paypal_email', '$mobile_money_number', 'pending'
            )";
    
    if (!$car->query($sql)) {
        throw new Exception("Failed to create payout request");
    }
    
    $payout_id = $car->insert_id;
    
    // Deduct from available balance
    $new_balance = $wallet['available_balance'] - $amount;
    $car->query("UPDATE tbl_company_wallet SET available_balance = $new_balance WHERE company_id = $company_id");
    
    // Record transaction
    $car->query("INSERT INTO tbl_company_wallet_transaction 
                (company_id, type, amount, balance_after, description, reference_type, reference_id)
                VALUES ($company_id, 'debit', $amount, $new_balance, 'Payout request', 'payout', $payout_id)");
    
    $car->commit();
    
    $payout = $car->query("SELECT * FROM tbl_company_payout WHERE id = $payout_id")->fetch_assoc();
    
    echo json_encode([
        "Result" => "true",
        "ResponseCode" => "200",
        "ResponseMsg" => "Payout request submitted successfully",
        "payout" => $payout,
        "new_balance" => $new_balance
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
