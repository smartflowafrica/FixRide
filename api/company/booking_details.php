<?php
/**
 * Company Booking Details API
 * Endpoint: GET /api/company/booking_details.php?company_id=X&booking_id=Y
 */
require dirname(dirname(__FILE__)) . '/inc/Connection.php';
header('Content-type: application/json');

if (empty($_GET['company_id']) || empty($_GET['booking_id'])) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "400",
        "ResponseMsg" => "Company ID and Booking ID are required"
    ]);
    exit;
}

$company_id = intval($_GET['company_id']);
$booking_id = intval($_GET['booking_id']);

// Get booking with car and user details
$sql = "SELECT 
    b.*,
    c.title as car_title,
    c.img as car_image,
    c.fuel,
    c.transmission,
    c.seat,
    c.price as car_price,
    c.price_type,
    cb.title as brand_name,
    ct.title as type_name,
    u.name as customer_name,
    u.mobile as customer_phone,
    u.email as customer_email,
    u.pro_pic as customer_image,
    city.title as city_name
FROM tbl_book b
JOIN tbl_car c ON b.car_id = c.id
LEFT JOIN tbl_carbrand cb ON c.brand = cb.id
LEFT JOIN tbl_cartype ct ON c.type_id = ct.id
JOIN tbl_user u ON b.uid = u.id
LEFT JOIN tbl_city city ON c.city = city.id
WHERE b.id = $booking_id AND c.company_id = $company_id";

$booking = $car->query($sql)->fetch_assoc();

if (!$booking) {
    echo json_encode([
        "Result" => "false",
        "ResponseCode" => "404",
        "ResponseMsg" => "Booking not found or does not belong to this company"
    ]);
    exit;
}

// Get commission info
$commission = $car->query("SELECT * FROM tbl_commission WHERE booking_id = $booking_id")->fetch_assoc();

// Calculate earnings
$total_amount = floatval($booking['total_amt']);
$commission_rate = $commission ? floatval($commission['commission_rate']) : 15.00;
$commission_amount = $commission ? floatval($commission['commission_amount']) : ($total_amount * $commission_rate / 100);
$company_earning = $commission ? floatval($commission['company_earning']) : ($total_amount - $commission_amount);

// Format response
$response = [
    "Result" => "true",
    "ResponseCode" => "200",
    "ResponseMsg" => "Booking details retrieved successfully",
    "booking" => [
        "id" => $booking['id'],
        "status" => $booking['book_status'],
        "pickup_date" => $booking['pick_date'],
        "pickup_time" => $booking['pick_time'],
        "return_date" => $booking['return_date'],
        "return_time" => $booking['return_time'],
        "total_days" => $booking['total_day'],
        "subtotal" => floatval($booking['subtotal']),
        "tax" => floatval($booking['tax_amt']),
        "coupon_discount" => floatval($booking['cou_amt']),
        "wallet_used" => floatval($booking['wall_amt']),
        "total_amount" => $total_amount,
        "created_at" => $booking['create_date']
    ],
    "car" => [
        "id" => $booking['car_id'],
        "title" => $booking['car_title'],
        "image" => $booking['car_image'],
        "brand" => $booking['brand_name'],
        "type" => $booking['type_name'],
        "fuel" => $booking['fuel'],
        "transmission" => $booking['transmission'],
        "seats" => $booking['seat'],
        "price" => floatval($booking['car_price']),
        "price_type" => $booking['price_type'],
        "city" => $booking['city_name']
    ],
    "customer" => [
        "id" => $booking['uid'],
        "name" => $booking['customer_name'],
        "phone" => $booking['customer_phone'],
        "email" => $booking['customer_email'],
        "image" => $booking['customer_image']
    ],
    "earnings" => [
        "total_amount" => $total_amount,
        "commission_rate" => $commission_rate,
        "commission_amount" => $commission_amount,
        "company_earning" => $company_earning,
        "status" => $commission ? $commission['status'] : 'pending'
    ]
];

// Add pickup/drop info if available
if (!empty($booking['pick_address'])) {
    $response['pickup_location'] = [
        "address" => $booking['pick_address'],
        "lat" => $booking['pick_lat'],
        "lng" => $booking['pick_lng']
    ];
}

if (!empty($booking['drop_address'])) {
    $response['drop_location'] = [
        "address" => $booking['drop_address'],
        "lat" => $booking['drop_lat'],
        "lng" => $booking['drop_lng']
    ];
}

echo json_encode($response);
?>
