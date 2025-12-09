# FixRide - Car Rental Application

A complete car rental platform with Flutter mobile app and PHP backend.

## 🚗 Features

### For Customers
- Browse cars by city, type, or brand
- Book cars with/without driver
- Secure payments via Paystack
- Wallet system for quick payments
- Track bookings (Pending → Pickup → Completed)
- Rate and review cars
- Apply discount coupons
- Favorite cars list

### For Car Owners
- List your cars for rent
- Manage bookings
- Track earnings dashboard
- Request payouts (Bank/UPI/PayPal)
- Upload car galleries

### Admin Panel
- Manage users, cars, bookings
- Configure payment gateways
- Set tax rates and commissions
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
│   ├── controller/         # Business logic
│   ├── model/              # Data models
│   ├── screen/             # UI screens
│   ├── payments/           # Payment integrations
│   └── utils/              # Config, helpers
├── api/                    # PHP REST APIs
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

## 🤖 For AI Agents

See [CODEBASE.md](./CODEBASE.md) for detailed codebase structure and entry points.

Key files:
- `lib/main.dart` - Flutter entry point
- `lib/utils/config.dart` - API configuration
- `api/home_data.php` - Main data API
- `inc/Operation.php` - Database operations
