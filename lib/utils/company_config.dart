/// Company API Configuration
/// Add these to the existing Config class or use separately

class CompanyConfig {
  // Base company API path
  static String companyBase = "company/";
  
  // Authentication
  static String companyRegister = "company/register.php";
  static String companyLogin = "company/login.php";
  static String companyCheckStatus = "company/check_status.php";
  
  // Dashboard
  static String companyDashboard = "company/dashboard.php";
  
  // Cars
  static String companyCarList = "company/car_list.php";
  static String companyAddCar = "company/add_car.php";
  static String companyEditCar = "company/edit_car.php";
  static String companyDeleteCar = "company/delete_car.php";
  
  // Bookings
  static String companyBookings = "company/bookings.php";
  static String companyBookingDetails = "company/booking_details.php";
  static String companyUpdateBookingStatus = "company/update_booking_status.php";
  
  // Wallet & Earnings
  static String companyWallet = "company/wallet.php";
  static String companyEarnings = "company/earnings.php";
  static String companyRequestPayout = "company/request_payout.php";
  static String companyPayoutHistory = "company/payout_history.php";
  
  // Profile & Documents
  static String companyUpdateProfile = "company/update_profile.php";
  static String companyUploadDocument = "company/upload_document.php";
  static String companyDocuments = "company/documents.php";
  
  // Notifications
  static String companyNotifications = "company/notifications.php";
  static String companyMarkNotificationRead = "company/mark_notification_read.php";
}
