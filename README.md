# FixRide - Car Rental Application

A complete car rental platform with Flutter mobile app and PHP backend, supporting multi-tenant car rental companies.

## 🚗 Features

### For Customers
- Browse cars by city, type, or brand
- Book cars with/without driver
- Secure payments via Paystack
- Wallet system for quick payments
- Track bookings (Pending → Pickup → Completed)
- Rate and review cars & companies
- Apply discount coupons
- Favorite cars list

### For Car Owners (Individual)
- List your cars for rent
- Manage bookings
- Track earnings dashboard
- Request payouts (Bank/UPI/PayPal)
- Upload car galleries

### For Rental Companies (Multi-Tenant)
- Company registration with document verification
- Manage fleet of cars
- Dashboard with earnings & booking stats
- Commission-based revenue sharing
- Company reviews & ratings system
- Payout management
- Activity audit logging

### Admin Panel
- Manage users, cars, bookings
- Approve/reject rental companies
- Configure payment gateways
- Set tax rates and commissions (per company)
- Manage cities, car types, brands
- Banner management
- Coupon system
- FAQ and pages management

---

## 📱 Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter 3.8+ |
| State Management | GetX, Provider |
| Backend | PHP 8.1+ |
| Database | MySQL |
| Authentication | Firebase Auth |
| Push Notifications | OneSignal |
| Maps | Google Maps |
| Payment | Paystack |
| SMS OTP | Twilio / MSG91 |

---

## 📁 Project Structure

```
FixRide/
├── lib/                    # Flutter app source
│   ├── controller/         # Business logic (includes company controllers)
│   ├── model/              # Data models (includes company models)
│   ├── screen/             # UI screens
│   │   └── company/        # Company owner screens
│   ├── service/            # API services
│   ├── payments/           # Payment integrations
│   └── utils/              # Config, helpers
├── api/                    # PHP REST APIs
│   ├── company/            # Company management APIs
│   │   ├── inc/            # Company helper functions
│   │   └── sql/            # Database schemas
│   └── [other APIs]
├── inc/                    # PHP includes (DB, operations)
├── assets/                 # Static assets
├── android/                # Android config
├── ios/                    # iOS config
└── [Admin PHP files]       # Web admin panel
```

---

## 🚀 Quick Start

### Backend Setup
1. Set up WAMP/LAMP server with PHP 8.1+
2. Create MySQL database
3. Import database schema
4. Copy `inc/Connection.example.php` to `inc/Connection.php`
5. Update database credentials

### Flutter Setup
```bash
# Install dependencies
flutter pub get

# Update API URL in lib/utils/config.dart
# Configure Firebase

# Run app
flutter run
```

---

## 📚 Documentation

- **[CODEBASE.md](./CODEBASE.md)** - Full codebase documentation
- **[API_DOCS.md](./API_DOCS.md)** - Complete API reference

---

## 🔧 Configuration

### API URL
Edit `lib/utils/config.dart`:
```dart
static String baseUrl = "https://yourdomain.com/api/";
```

### Database
Edit `inc/Connection.php`:
```php
$host = "localhost";
$user = "your_username";
$pass = "your_password";
$dbname = "your_database";
```

### Payment Gateway
Configure Paystack in admin panel or directly in `api/paymentgateway.php`

---

## 📄 License

This project is proprietary software.

---

## 🏢 Company System

The multi-tenant company system allows car rental businesses to register and manage their fleet:

### Company APIs (`api/company/`)
| Endpoint | Description |
|----------|-------------|
| `register.php` | Company registration |
| `login.php` | Company authentication |
| `dashboard.php` | Stats & earnings overview |
| `car_list.php` | List company cars |
| `add_car.php` | Add new car to fleet |
| `edit_car.php` | Update car details |
| `delete_car.php` | Remove car |
| `bookings.php` | View company bookings |
| `update_booking_status.php` | Manage booking status |
| `wallet.php` | View wallet balance |
| `request_payout.php` | Request earnings withdrawal |
| `reviews.php` | View company reviews |
| `reply_review.php` | Respond to customer reviews |

### Security Features
- Company ownership verification for all car/booking operations
- Role-based access (owner, admin, staff)
- Activity audit logging
- Commission calculation with company-specific rates

---

## 🤖 For AI Agents

See [CODEBASE.md](./CODEBASE.md) for detailed codebase structure and entry points.

Key files:
- `lib/main.dart` - Flutter entry point
- `lib/utils/config.dart` - API configuration
- `api/home_data.php` - Main data API
- `inc/Operation.php` - Database operations
