<?php
/**
 * Check Company Status API
 * Endpoint: GET /api/company/check_status.php?company_id=X
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

$company = $car->query("SELECT 
    id, company_name, email, status, is_verified, 
    commission_rate, created_at
FROM tbl_company WHERE id = $company_id")->fetch_assoc();

if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Get document verification status
$docs = $car->query("SELECT 
    document_type, status 
FROM tbl_company_document WHERE company_id = $company_id");

$documents = [];
while ($row = $docs->fetch_assoc()) {
    $documents[$row['document_type']] = $row['status'];
}

// Get pending documents count
$pending_docs = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_document 
    WHERE company_id = $company_id AND status = 'pending'")->fetch_assoc()['cnt'];

$verified_docs = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_document 
    WHERE company_id = $company_id AND status = 'verified'")->fetch_assoc()['cnt'];

$status_message = "";
$next_steps = [];

switch ($company['status']) {
    case 'pending':
        $status_message = "Your company registration is pending approval.";
        if ($pending_docs > 0) {
            $next_steps[] = "Wait for document verification ($pending_docs pending)";
        } else {
            $next_steps[] = "Upload required documents for verification";
        }
        break;
    case 'active':
        $status_message = "Your company is active and ready to list cars.";
        if (!$company['is_verified']) {
            $next_steps[] = "Complete verification to increase visibility";
        }
        break;
    case 'suspended':
        $status_message = "Your company has been suspended. Please contact support.";
        break;
}

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Status retrieved successfully",
    "company" => [
        "id" => $company['id'],
        "name" => $company['company_name'],
        "email" => $company['email'],
        "status" => $company['status'],
        "is_verified" => (bool)$company['is_verified'],
        "commission_rate" => floatval($company['commission_rate']),
        "created_at" => $company['created_at']
    ],
    "documents" => $documents,
    "document_stats" => [
        "pending" => intval($pending_docs),
        "verified" => intval($verified_docs)
    ],
    "status_message" => $status_message,
    "next_steps" => $next_steps
]);
?>
