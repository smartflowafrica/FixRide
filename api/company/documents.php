<?php
/**
 * Get Company Documents API
 * Endpoint: GET /api/company/documents.php?company_id=X
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

// Verify company exists
$company = $car->query("SELECT id, company_name FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Filter by document type if provided
$where = "company_id = $company_id";
if (!empty($_GET['document_type'])) {
    $type = $car->real_escape_string($_GET['document_type']);
    $where .= " AND document_type = '$type'";
}

// Filter by status if provided
if (!empty($_GET['status'])) {
    $status = $car->real_escape_string($_GET['status']);
    $where .= " AND status = '$status'";
}

$documents = [];
$result = $car->query("SELECT * FROM tbl_company_document WHERE $where ORDER BY uploaded_at DESC");
while ($row = $result->fetch_assoc()) {
    $documents[] = $row;
}

// Get summary
$summary = $car->query("SELECT 
    COUNT(*) as total,
    SUM(status = 'verified') as verified,
    SUM(status = 'pending') as pending,
    SUM(status = 'rejected') as rejected,
    SUM(status = 'expired') as expired
FROM tbl_company_document WHERE company_id = $company_id")->fetch_assoc();

echo json_encode([
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Documents retrieved successfully",
    "company" => $company,
    "summary" => $summary,
    "documents" => $documents
]);
?>
