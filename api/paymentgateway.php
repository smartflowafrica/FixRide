<?php 
require dirname( dirname(__FILE__) ).'/inc/Connection.php';
header('Content-type: text/json');
// Only return Paystack payment gateway
$sel = $car->query("select * from tbl_payment_list where title = 'PayStack' and status = 1 LIMIT 1");
$myarray = array();
while($row = $sel->fetch_assoc())
{
	$myarray[] = $row;
}
// If Paystack not found, return empty with message
if(empty($myarray)) {
    $returnArr = array("paymentdata"=>$myarray,"ResponseCode"=>"404","Result"=>"false","ResponseMsg"=>"PayStack payment gateway not configured. Please enable it in admin panel.");
} else {
    $returnArr = array("paymentdata"=>$myarray,"ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Payment Gateway List Founded!");
}
echo json_encode($returnArr);
?> 