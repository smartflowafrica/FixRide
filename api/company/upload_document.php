<?php
/**
 * Company Document Upload API
 * Endpoint: POST /api/company/upload_document.php
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "405",
        "ResponseMsg" => "Method not allowed"
    ]);
    exit;
}

if (empty($_POST['company_id']) || empty($_POST['document_type'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID and document type are required"
    ]);
    exit;
}

if (!isset($_FILES['document']) || $_FILES['document']['error'] != 0) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Document file is required"
    ]);
    exit;
}

$company_id = intval($_POST['company_id']);
$document_type = $car->real_escape_string($_POST['document_type']);
$document_name = isset($_POST['document_name']) ? $car->real_escape_string($_POST['document_name']) : '';
$expiry_date = isset($_POST['expiry_date']) ? $car->real_escape_string($_POST['expiry_date']) : null;

// Validate document type
$valid_types = ['business_reg', 'tax_id', 'insurance', 'license', 'id_card', 'other'];
if (!in_array($document_type, $valid_types)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Invalid document type"
    ]);
    exit;
}

// Verify company exists
$company = $car->query("SELECT id FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Company not found"
    ]);
    exit;
}

// Validate file type
$allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
if (!in_array($_FILES['document']['type'], $allowed_types)) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Only JPG, PNG, and PDF files are allowed"
    ]);
    exit;
}

// Max file size 5MB
if ($_FILES['document']['size'] > 5 * 1024 * 1024) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "File size must be less than 5MB"
    ]);
    exit;
}

// Create upload directory
$upload_dir = dirname(dirname(__FILE__)) . '/images/company_docs/';
if (!is_dir($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

// Generate filename
$ext = pathinfo($_FILES['document']['name'], PATHINFO_EXTENSION);
$filename = $company_id . '_' . $document_type . '_' . time() . '.' . $ext;
$target = $upload_dir . $filename;

if (move_uploaded_file($_FILES['document']['tmp_name'], $target)) {
    $document_url = 'images/company_docs/' . $filename;
    $expiry_sql = $expiry_date ? "'$expiry_date'" : "NULL";
    
    $sql = "INSERT INTO tbl_company_document (company_id, document_type, document_name, document_url, expiry_date) 
            VALUES ($company_id, '$document_type', '$document_name', '$document_url', $expiry_sql)";
    
    if ($car->query($sql)) {
        $doc_id = $car->insert_id;
        $document = $car->query("SELECT * FROM tbl_company_document WHERE id = $doc_id")->fetch_assoc();
        
        echo json_encode([
            "Result" => "true",
            "ResponseCode" => "200",
            "ResponseMsg" => "Document uploaded successfully",
            "document" => $document
        ]);
    } else {
        unlink($target);
        echo json_encode([
            "Result" => "false",
            "ResponseCode" => "500",
            "ResponseMsg" => "Failed to save document record"
        ]);
    }
} else {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "500",
        "ResponseMsg" => "Failed to upload file"
    ]);
}
?>
