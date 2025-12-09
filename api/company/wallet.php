<?php
/**
 * Company Wallet API
 * Endpoint: GET /api/company/wallet.php?company_id=X
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

if (empty($_GET['company_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID is required"
    ]);
    exit;
}

$company_id = intval($_GET['company_id']);

// Get wallet
$wallet = $car->query("SELECT * FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();

if (!$wallet) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Wallet not found"
    ]);
    exit;
}

// Get recent transactions
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 20;
$offset = ($page - 1) * $limit;

$transactions = [];
$trans_result = $car->query("SELECT * FROM tbl_company_wallet_transaction 
    WHERE company_id = $company_id 
    ORDER BY created_at DESC 
    LIMIT $limit OFFSET $offset");

while ($row = $trans_result->fetch_assoc()) {
    $transactions[] = $row;
}

// Get transaction count
$total = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_wallet_transaction WHERE company_id = $company_id")->fetch_assoc()['cnt'];

// Get pending payouts
$pending_payouts = $car->query("SELECT SUM(amount) as total FROM tbl_company_payout 
    WHERE company_id = $company_id AND status IN ('pending', 'processing')")->fetch_assoc()['total'] ?? 0;

// Get this month's earnings
$this_month = date('Y-m-01');
$month_earnings = $car->query("SELECT SUM(amount) as total FROM tbl_company_wallet_transaction 
    WHERE company_id = $company_id AND type = 'credit' AND created_at >= '$this_month'")->fetch_assoc()['total'] ?? 0;

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Wallet data retrieved successfully",
    "wallet" => [
        "available_balance" => floatval($wallet['available_balance']),
        "pending_balance" => floatval($wallet['pending_balance']),
        "total_earned" => floatval($wallet['total_earned']),
        "total_withdrawn" => floatval($wallet['total_withdrawn']),
        "pending_payouts" => floatval($pending_payouts),
        "this_month_earnings" => floatval($month_earnings)
    ],
    "transactions" => $transactions,
    "pagination" => [
        "current_page" => $page,
        "per_page" => $limit,
        "total" => intval($total),
        "total_pages" => ceil($total / $limit)
    ]
]);
?>
