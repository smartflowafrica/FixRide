# FixRide - Car Rental Application Codebase Documentation

## Project Overview
FixRide is a complete car rental platform consisting of:
- **Flutter Mobile App** - Cross-platform (iOS/Android) customer & car owner app
- **PHP Admin Panel** - Web-based management dashboard
- **REST API** - PHP backend APIs for mobile app

## Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.8.1+
- **State Management**: GetX, Provider
- **Authentication**: Firebase Auth
- **Push Notifications**: OneSignal
- **Maps**: Google Maps
- **Payment Gateway**: Paystack (configured as default)
- **HTTP Client**: http package
- **Local Storage**: SharedPreferences

### Backend (PHP)
- **Server**: Apache (WAMP/LAMP)
- **Database**: MySQL
- **PHP Version**: 8.1+

---

## Directory Structure

```
FixRide/
├── lib/                          # Flutter app source code
│   ├── controller/               # GetX controllers
│   ├── model/                    # Data models (40+ models)
│   ├── screen/                   # UI screens
│   │   ├── login_flow/           # Auth screens (login, signup, OTP)
│   │   ├── bottombar/            # Main app screens (home, explore, profile)
│   │   ├── detailcar/            # Car details, booking, payment
│   │   ├── addcar_screens/       # Car owner features
│   │   └── gerneral_support/     # Settings, wallet, FAQ
│   ├── payments/                 # Payment gateway integrations
│   ├── paypal/                   # PayPal SDK (legacy)
│   ├── helpar/                   # Dependency injection, routes
│   └── utils/                    # Config, colors, widgets
│
├── api/                          # PHP REST API endpoints
│   ├── home_data.php             # Home screen data
│   ├── user_login.php            # User authentication
│   ├── book_now.php              # Booking creation
│   ├── paymentgateway.php        # Payment methods
│   └── src/Twilio/                # Twilio SMS SDK
│
├── inc/                          # PHP includes
│   ├── Connection.php            # Database connection (gitignored)
│   ├── Connection.example.php    # DB connection template
│   ├── Header.php, Footer.php    # Admin panel layout
│   └── Operation.php             # CRUD operations
│
├── android/                      # Android native config
├── ios/                          # iOS native config
├── assets/                       # Images, fonts, CSS, JS
├── images/                       # Uploaded images storage
│
├── [Payment Folders]/            # Payment gateway PHP handlers
│   ├── paypal/, paytm/, flutterwave/
│   ├── Payfast/, Midtrans/, Khalti/
│   └── merpago/, 2checkout/
│
└── [Admin PHP Files]             # Admin panel pages
    ├── dashboard.php, index.php (login)
    ├── add_*.php, list_*.php, edit_*.php
    └── userlist.php, paymentlist.php
```

---

## Key Files Reference

### Flutter Configuration
| File | Purpose |
|------|---------|
| `lib/utils/config.dart` | API base URL, endpoints |
| `lib/utils/Colors.dart` | Theme colors |
| `lib/firebase_options.dart` | Firebase configuration |
| `pubspec.yaml` | Dependencies |

### Flutter Controllers
| File | Purpose |
|------|---------|
| `lib/controller/home_controller.dart` | Home screen logic |
| `lib/controller/login_controller.dart` | Authentication |
| `lib/controller/carpurchase_controller.dart` | Booking flow |

### Flutter Screens
| File | Purpose |
|------|---------|
| `lib/screen/login_flow/login_screen.dart` | User login |
| `lib/screen/bottombar/home_screen.dart` | Main home |
| `lib/screen/detailcar/review_summery.dart` | Payment checkout |
| `lib/screen/gerneral_support/wallet_screen.dart` | Wallet top-up |

### PHP API Endpoints
| Endpoint | Purpose |
|----------|---------|
| `api/reg_user.php` | User registration |
| `api/user_login.php` | User login |
| `api/home_data.php` | Home screen data (banners, cars) |
| `api/book_now.php` | Create booking |
| `api/paymentgateway.php` | Get payment methods |
| `api/car_info.php` | Car details |
| `api/my_car_list.php` | Owner's car list |

### Admin Panel
| File | Purpose |
|------|---------|
| `dashboard.php` | Admin dashboard |
| `list_car.php` | Manage cars |
| `userlist.php` | Manage users |
| `paymentlist.php` | Payment gateway settings |
| `setting.php` | App settings |

---

## Database Tables (Key)

| Table | Purpose |
|-------|---------|
| `tbl_user` | User accounts |
| `tbl_car` | Car listings |
| `tbl_book` | Bookings |
| `tbl_payment_list` | Payment gateways |
| `tbl_city` | Cities |
| `tbl_car_type` | Car types (SUV, Sedan, etc.) |
| `tbl_car_brand` | Car brands |
| `tbl_coupon` | Discount coupons |
| `tbl_wallet` | Wallet transactions |
| `tbl_banner` | Home banners |
| `tbl_facility` | Car facilities/features |

---

## API Response Format

All APIs return JSON:
```json
{
  "Result": "true",
  "ResponseCode": "200",
  "ResponseMsg": "Success message",
  "data": { ... }
}
```

---

## Authentication Flow

1. User enters mobile number
2. OTP sent via Twilio/MSG91
3. OTP verified → User logged in
4. JWT/Session stored in SharedPreferences
5. User ID sent with each API request

---

## Booking Flow

1. User selects car → `car_info.php`
2. Selects dates/time → `book_range.php` (availability check)
3. Reviews summary → applies coupon (`u_check_coupon.php`)
4. Payment via Paystack
5. Booking created → `book_now.php`
6. Owner receives notification
7. Pickup/Drop tracked via `pickup.php`, `drop.php`

---

## Payment Integration

**Current**: Paystack only (configured in `api/paymentgateway.php`)

Payment flow:
1. App calls `paymentgateway.php` → returns Paystack config
2. User redirected to Paystack WebView
3. Payment verified via Paystack API
4. Booking/Wallet updated on success

---

## Environment Setup

### Backend Requirements
- PHP 8.1+
- MySQL 5.7+
- Apache with mod_rewrite

### Database Setup
1. Create MySQL database
2. Import SQL schema (not in repo - from original source)
3. Copy `inc/Connection.example.php` to `inc/Connection.php`
4. Update credentials

### Flutter Setup
1. Install Flutter SDK
2. Update `lib/utils/config.dart` with your API URL
3. Configure Firebase (`firebase_options.dart`)
4. Run `flutter pub get`
5. Run `flutter run`

---

## Customization Guide

### Branding
- App name: `pubspec.yaml`, Android/iOS configs
- Colors: `lib/utils/Colors.dart`
- Logo: `assets/applogo.png`, `assets/sLogo.png`

### API URL
- Update `lib/utils/config.dart`:
```dart
static String baseUrl = "https://yourdomain.com/api/";
```

### Payment Gateway
- Configure in admin panel → Payment Gateway List
- Or modify `api/paymentgateway.php`

---

## For AI Agents

To work with this codebase:

1. **Flutter changes**: Focus on `lib/` folder
2. **API changes**: Focus on `api/` folder  
3. **Admin panel**: Root PHP files + `inc/` folder
4. **Database**: Check `inc/Operation.php` for table references

Key entry points:
- `lib/main.dart` - Flutter app entry
- `index.php` - Admin login
- `dashboard.php` - Admin dashboard
- `api/home_data.php` - Main API endpoint
