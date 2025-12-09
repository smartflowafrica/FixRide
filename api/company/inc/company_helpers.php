<?php
/**
 * Company Helper Functions
 * Security and utility functions for company APIs
 */

/**
 * Check if a user is an admin of a specific company
 * @param mysqli $db Database connection
 * @param int $userId The user ID to check
 * @param int $companyId The company ID to verify against
 * @return bool True if user is admin of the company
 */
function isCompanyAdmin($db, $userId, $companyId) {
    $userId = intval($userId);
    $companyId = intval($companyId);
    
    if ($userId <= 0 || $companyId <= 0) {
        return false;
    }
    
    $result = $db->query("
        SELECT cu.id, cu.role 
        FROM tbl_company_user cu
        WHERE cu.user_id = $userId 
        AND cu.company_id = $companyId 
        AND cu.role IN ('owner', 'admin')
        AND cu.status = '1'
    ");
    
    return $result && $result->num_rows > 0;
}

/**
 * Check if a user belongs to a company (any role)
 * @param mysqli $db Database connection
 * @param int $userId The user ID to check
 * @param int $companyId The company ID to verify against
 * @return array|false User role info or false if not a member
 */
function getCompanyUserRole($db, $userId, $companyId) {
    $userId = intval($userId);
    $companyId = intval($companyId);
    
    if ($userId <= 0 || $companyId <= 0) {
        return false;
    }
    
    $result = $db->query("
        SELECT cu.id, cu.role, cu.status, c.company_name, c.status as company_status
        FROM tbl_company_user cu
        JOIN tbl_company c ON cu.company_id = c.id
        WHERE cu.user_id = $userId 
        AND cu.company_id = $companyId
    ");
    
    if ($result && $row = $result->fetch_assoc()) {
        return $row;
    }
    
    return false;
}

/**
 * Verify that a company owns a specific car
 * Prevents companies from editing/deleting other companies' cars
 * @param mysqli $db Database connection
 * @param int $carId The car ID to check
 * @param int $companyId The company ID to verify ownership
 * @return bool True if company owns the car
 */
function verifyCarOwnership($db, $carId, $companyId) {
    $carId = intval($carId);
    $companyId = intval($companyId);
    
    if ($carId <= 0 || $companyId <= 0) {
        return false;
    }
    
    $result = $db->query("
        SELECT id FROM tbl_car 
        WHERE id = $carId AND company_id = $companyId
    ");
    
    return $result && $result->num_rows > 0;
}

/**
 * Verify that a booking belongs to a company's car
 * @param mysqli $db Database connection
 * @param int $bookingId The booking ID to check
 * @param int $companyId The company ID to verify
 * @return bool True if booking is for company's car
 */
function verifyBookingOwnership($db, $bookingId, $companyId) {
    $bookingId = intval($bookingId);
    $companyId = intval($companyId);
    
    if ($bookingId <= 0 || $companyId <= 0) {
        return false;
    }
    
    $result = $db->query("
        SELECT b.id FROM tbl_book b
        JOIN tbl_car c ON b.car_id = c.id
        WHERE b.id = $bookingId AND c.company_id = $companyId
    ");
    
    return $result && $result->num_rows > 0;
}

/**
 * Verify company is active and approved
 * @param mysqli $db Database connection
 * @param int $companyId The company ID to check
 * @return array|false Company data or false if not active
 */
function verifyCompanyActive($db, $companyId) {
    $companyId = intval($companyId);
    
    if ($companyId <= 0) {
        return false;
    }
    
    $result = $db->query("
        SELECT id, company_name, status, is_verified 
        FROM tbl_company 
        WHERE id = $companyId AND status = '1'
    ");
    
    if ($result && $row = $result->fetch_assoc()) {
        return $row;
    }
    
    return false;
}

/**
 * Validate company authentication from request
 * @param mysqli $db Database connection
 * @param array $data Request data containing company_id and optionally user_id
 * @return array Response with success status and data/error
 */
function validateCompanyAuth($db, $data) {
    // Check company_id is provided
    if (empty($data['company_id'])) {
        return [
            'success' => false,
            'code' => '400',
            'message' => 'Company ID is required'
        ];
    }
    
    $companyId = intval($data['company_id']);
    
    // Verify company exists and is active
    $company = verifyCompanyActive($db, $companyId);
    if (!$company) {
        return [
            'success' => false,
            'code' => '403',
            'message' => 'Company not found or inactive'
        ];
    }
    
    // If user_id provided, verify they belong to company
    if (!empty($data['user_id'])) {
        $userId = intval($data['user_id']);
        $userRole = getCompanyUserRole($db, $userId, $companyId);
        
        if (!$userRole) {
            return [
                'success' => false,
                'code' => '403',
                'message' => 'User does not belong to this company'
            ];
        }
        
        if ($userRole['status'] != '1') {
            return [
                'success' => false,
                'code' => '403',
                'message' => 'User account is inactive'
            ];
        }
        
        return [
            'success' => true,
            'company' => $company,
            'user_role' => $userRole
        ];
    }
    
    return [
        'success' => true,
        'company' => $company
    ];
}

/**
 * Return JSON error response and exit
 * @param string $message Error message
 * @param string $code Response code
 */
function companyErrorResponse($message, $code = '400') {
    echo json_encode([
        'Result' => 'false',
        'ResponseCode' => $code,
        'ResponseMsg' => $message
    ]);
    exit;
}

/**
 * Return JSON success response
 * @param string $message Success message
 * @param array $data Additional data to include
 */
function companySuccessResponse($message, $data = []) {
    $response = [
        'Result' => 'true',
        'ResponseCode' => '200',
        'ResponseMsg' => $message
    ];
    
    echo json_encode(array_merge($response, $data));
}

/**
 * Log company activity for audit
 * @param mysqli $db Database connection
 * @param int $companyId Company ID
 * @param int $userId User ID who performed action
 * @param string $action Action performed
 * @param string $details Additional details
 * @param int|null $referenceId Related record ID
 */
function logCompanyActivity($db, $companyId, $userId, $action, $details = '', $referenceId = null) {
    $companyId = intval($companyId);
    $userId = intval($userId);
    $action = $db->real_escape_string($action);
    $details = $db->real_escape_string($details);
    $referenceId = $referenceId ? intval($referenceId) : 'NULL';
    $timestamp = date('Y-m-d H:i:s');
    
    $db->query("
        INSERT INTO tbl_company_activity_log 
        (company_id, user_id, action, details, reference_id, created_at)
        VALUES ($companyId, $userId, '$action', '$details', $referenceId, '$timestamp')
    ");
}
?>
