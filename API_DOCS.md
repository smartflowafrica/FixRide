# FixRide API Documentation

## Base URL
```
https://yourdomain.com/api/
```

## Authentication
Most endpoints require `uid` (user ID) in request body.

---

## User Endpoints

### Register User
**POST** `/reg_user.php`
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "ccode": "+1",
  "password": "password123",
  "refercode": ""
}
```

### Login
**POST** `/user_login.php`
```json
{
  "mobile": "1234567890",
  "password": "password123"
}
```

### Check Mobile
**POST** `/mobile_check.php`
```json
{
  "mobile": "1234567890"
}
```

### Forgot Password
**POST** `/forget_password.php`
```json
{
  "mobile": "1234567890"
}
```

### Edit Profile
**POST** `/profile_edit.php`
```json
{
  "uid": "1",
  "name": "John Doe",
  "email": "john@example.com"
}
```

### Profile Image Upload
**POST** `/pro_image.php`
- Multipart form data with `uid` and `img` file

### Delete Account
**POST** `/acc_delete.php`
```json
{
  "uid": "1"
}
```

---

## Home & Discovery

### Home Data
**POST** `/home_data.php`
```json
{
  "uid": "1",
  "city_id": "1"
}
```
Returns: banners, featured cars, popular cars, settings

### City List
**POST** `/citylist.php`
```json
{}
```

### Car Types
**POST** `/cartype.php`
```json
{}
```

### Car Brands
**POST** `/carbrand.php`
```json
{}
```

### Facility List
**POST** `/facilitylist.php`
```json
{}
```

---

## Car Search & Details

### Cars by City
**POST** `/citywisecar.php`
```json
{
  "city_id": "1",
  "uid": "1"
}
```

### Cars by Type
**POST** `/typewisecar.php`
```json
{
  "type_id": "1",
  "uid": "1"
}
```

### Cars by Brand
**POST** `/brandwisecar.php`
```json
{
  "brand_id": "1",
  "uid": "1"
}
```

### Car Info
**POST** `/car_info.php`
```json
{
  "car_id": "1",
  "uid": "1"
}
```

### View All Featured
**POST** `/view_all_feature.php`
```json
{
  "uid": "1"
}
```

### View All Popular
**POST** `/view_all_popular.php`
```json
{
  "uid": "1"
}
```

---

## Booking

### Check Availability
**POST** `/book_range.php`
```json
{
  "car_id": "1",
  "pickup_date": "2024-01-15",
  "return_date": "2024-01-17"
}
```

### Create Booking
**POST** `/book_now.php`
```json
{
  "car_id": "1",
  "uid": "1",
  "car_price": "100",
  "price_type": "days",
  "pickup_date": "2024-01-15",
  "pickup_time": "10:00 AM",
  "return_date": "2024-01-17",
  "return_time": "10:00 AM",
  "cou_id": "0",
  "cou_amt": "0",
  "wall_amt": "0",
  "total_day_or_hr": "2",
  "subtotal": "200",
  "tax_per": "10",
  "tax_amt": "20",
  "o_total": "220",
  "p_method_id": "4",
  "transaction_id": "pay_xxx",
  "type_id": "1",
  "brand_id": "1",
  "book_type": "Without",
  "city_id": "1"
}
```

### Booking History
**POST** `/book_history.php`
```json
{
  "uid": "1"
}
```

### Booking Details
**POST** `/book_details.php`
```json
{
  "book_id": "1"
}
```

### Pickup
**POST** `/pickup.php`
```json
{
  "book_id": "1"
}
```

### Drop
**POST** `/drop.php`
```json
{
  "book_id": "1"
}
```

### Cancel Booking
**POST** `/cancel.php`
```json
{
  "book_id": "1",
  "uid": "1"
}
```

---

## Car Owner Endpoints

### Add Car
**POST** `/add_car.php`
- Multipart form data with car details and images

### Update Car
**POST** `/update_car.php`
```json
{
  "car_id": "1",
  "car_title": "Updated Title",
  ...
}
```

### My Car List
**POST** `/my_car_list.php`
```json
{
  "uid": "1"
}
```

### Add Gallery
**POST** `/add_gallery.php`
- Multipart form with `car_id` and `img` file

### Gallery List
**POST** `/gallery_list.php`
```json
{
  "car_id": "1"
}
```

### My Bookings (as owner)
**POST** `/my_book_history.php`
```json
{
  "uid": "1"
}
```

### Complete Booking
**POST** `/complete_book.php`
```json
{
  "book_id": "1"
}
```

---

## Wallet

### Wallet Report
**POST** `/wallet_report.php`
```json
{
  "uid": "1"
}
```

### Wallet Update
**POST** `/wallet_up.php`
```json
{
  "uid": "1",
  "wallet": "100"
}
```

---

## Favorites

### Add/Remove Favorite
**POST** `/u_fav.php`
```json
{
  "uid": "1",
  "car_id": "1"
}
```

### Favorite Cars List
**POST** `/u_fav_car.php`
```json
{
  "uid": "1"
}
```

---

## Coupons

### Coupon List
**POST** `/u_couponlist.php`
```json
{
  "uid": "1"
}
```

### Check Coupon
**POST** `/u_check_coupon.php`
```json
{
  "uid": "1",
  "cid": "1"
}
```

---

## Ratings

### Rate Car
**POST** `/u_rate_update.php`
```json
{
  "uid": "1",
  "car_id": "1",
  "rate": "5",
  "comment": "Great car!"
}
```

### Rating List
**POST** `/ratelist.php`
```json
{
  "car_id": "1"
}
```

---

## Payouts (Car Owners)

### Owner Dashboard
**POST** `/u_dashboard.php`
```json
{
  "uid": "1"
}
```

### Request Withdrawal
**POST** `/request_withdraw.php`
```json
{
  "uid": "1",
  "amt": "100",
  "r_type": "BANK Transfer",
  "bank_name": "Bank",
  "acc_number": "123456",
  "acc_name": "John",
  "ifsc_code": "IFSC001",
  "upi_id": "",
  "paypal_id": ""
}
```

### Payout List
**POST** `/payout_list.php`
```json
{
  "uid": "1"
}
```

---

## Other

### Payment Gateway
**POST** `/paymentgateway.php`
```json
{}
```

### FAQ
**POST** `/faq.php`
```json
{}
```

### Pages (Terms, Privacy)
**POST** `/pagelist.php`
```json
{}
```

### Notifications
**POST** `/u_notification_list.php`
```json
{
  "uid": "1"
}
```

### Referral Data
**POST** `/referdata.php`
```json
{
  "uid": "1"
}
```

---

## Response Format

### Success
```json
{
  "Result": "true",
  "ResponseCode": "200",
  "ResponseMsg": "Success message",
  "data": { ... }
}
```

### Error
```json
{
  "Result": "false",
  "ResponseCode": "401",
  "ResponseMsg": "Error message"
}
```

---

## Company/Multi-Tenant APIs

### Company Registration
**POST** `/company/register.php`
```json
{
  "company_name": "ABC Rentals",
  "email": "company@example.com",
  "password": "password123",
  "phone": "+1234567890",
  "city_id": 1,
  "owner_name": "John Doe",
  "address": "123 Main Street",
  "business_reg_number": "BRN123456"
}
```

### Company Login
**POST** `/company/login.php`
```json
{
  "email": "company@example.com",
  "password": "password123"
}
```

### Company Dashboard
**GET** `/company/dashboard.php?company_id=1`

Returns: total_cars, active_bookings, total_earnings, pending_payouts, recent_bookings, commission_rate

### Company Cars
**GET** `/company/car_list.php?company_id=1`

Query params:
- `company_id` (required)
- `status` (optional): 1 = active, 0 = inactive
- `page` (optional): pagination
- `limit` (optional): items per page

### Add Company Car
**POST** `/company/add_car.php`
```json
{
  "company_id": 1,
  "title": "Toyota Camry 2024",
  "brand": 1,
  "type_id": 1,
  "fuel": "petrol",
  "transmission": "automatic",
  "seat": 5,
  "city": 1,
  "ac_heater": "AC",
  "price": 100,
  "price_type": "days",
  "description": "Well maintained car"
}
```

### Company Bookings
**GET** `/company/bookings.php?company_id=1`

Query params:
- `company_id` (required)
- `status` (optional): Pending, Pick_Up, Completed, Cancelled
- `page`, `limit` for pagination

### Company Earnings
**GET** `/company/earnings.php?company_id=1`

Query params:
- `company_id` (required)
- `start_date`, `end_date` (optional)
- `page`, `limit` for pagination

### Update Company Profile
**POST** `/company/update_profile.php`
- Supports JSON or multipart form data
- Can upload `logo` and `cover_image`
```json
{
  "company_id": 1,
  "company_name": "Updated Name",
  "phone": "+1234567890",
  "address": "New Address",
  "description": "Company description"
}
```

### Request Payout
**POST** `/company/request_payout.php`
```json
{
  "company_id": 1,
  "amount": 500.00,
  "payment_method": "bank_transfer",
  "bank_name": "Chase Bank",
  "account_number": "123456789",
  "account_name": "ABC Rentals LLC"
}
```
Payment methods: `bank_transfer`, `paypal`, `mobile_money`

### Company Wallet
**GET** `/company/wallet.php?company_id=1`

Returns: available_balance, pending_balance, total_earned, total_withdrawn, transactions

### Upload Document
**POST** `/company/upload_document.php`
- Multipart form data
- `company_id` (required)
- `document_type` (required): business_reg, tax_id, insurance, license, id_card, other
- `document` (required): file
- `document_name` (optional)
- `expiry_date` (optional)

### Get Documents
**GET** `/company/documents.php?company_id=1`

Query params:
- `company_id` (required)
- `document_type` (optional)
- `status` (optional): pending, verified, rejected, expired

### Public Company Profile
**GET** `/company_info.php?company_id=1` or `?slug=company-slug`

Returns public company info, featured cars, recent reviews

---

## Database Schema

For the complete database schema including the multi-tenant company system, see:
`database/migrations/001_multi_tenant_companies.sql`

