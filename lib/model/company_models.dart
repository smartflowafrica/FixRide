import 'dart:convert';

// Company Model
class Company {
  final int id;
  final String companyName;
  final String slug;
  final String email;
  final String? phone;
  final String? address;
  final int? cityId;
  final String? logo;
  final String? coverImage;
  final String? description;
  final String? businessRegNumber;
  final bool isVerified;
  final double commissionRate;
  final double rating;
  final int totalCars;
  final int totalBookings;
  final String status;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.companyName,
    required this.slug,
    required this.email,
    this.phone,
    this.address,
    this.cityId,
    this.logo,
    this.coverImage,
    this.description,
    this.businessRegNumber,
    this.isVerified = false,
    this.commissionRate = 15.0,
    this.rating = 0.0,
    this.totalCars = 0,
    this.totalBookings = 0,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.parse(json['id'].toString()),
      companyName: json['company_name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      cityId: json['city_id'] != null ? int.tryParse(json['city_id'].toString()) : null,
      logo: json['logo'],
      coverImage: json['cover_image'],
      description: json['description'],
      businessRegNumber: json['business_reg_number'],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == '1' || json['is_verified'] == true,
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '15') ?? 15.0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalCars: int.tryParse(json['total_cars']?.toString() ?? '0') ?? 0,
      totalBookings: int.tryParse(json['total_bookings']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'slug': slug,
      'email': email,
      'phone': phone,
      'address': address,
      'city_id': cityId,
      'logo': logo,
      'cover_image': coverImage,
      'description': description,
      'business_reg_number': businessRegNumber,
      'is_verified': isVerified,
      'commission_rate': commissionRate,
      'rating': rating,
      'total_cars': totalCars,
      'total_bookings': totalBookings,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Company User Model
class CompanyUser {
  final int id;
  final int companyId;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String role;
  final int status;

  CompanyUser({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.role = 'owner',
    this.status = 1,
  });

  factory CompanyUser.fromJson(Map<String, dynamic> json) {
    return CompanyUser(
      id: int.parse(json['id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      role: json['role'] ?? 'owner',
      status: int.tryParse(json['status']?.toString() ?? '1') ?? 1,
    );
  }
}

// Company Login Response
class CompanyLoginResponse {
  final bool success;
  final String message;
  final Company? company;
  final CompanyUser? user;

  CompanyLoginResponse({
    required this.success,
    required this.message,
    this.company,
    this.user,
  });

  factory CompanyLoginResponse.fromJson(Map<String, dynamic> json) {
    return CompanyLoginResponse(
      success: json['Result'] == 'true',
      message: json['ResponseMsg'] ?? '',
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      user: json['user'] != null ? CompanyUser.fromJson(json['user']) : null,
    );
  }
}

// Dashboard Stats Model
class CompanyDashboardStats {
  final int totalCars;
  final int activeCars;
  final int activeBookings;
  final int pendingBookings;
  final int completedBookings;
  final double totalEarnings;
  final double pendingPayouts;
  final double availableBalance;
  final double commissionRate;
  final double thisMonthEarnings;

  CompanyDashboardStats({
    this.totalCars = 0,
    this.activeCars = 0,
    this.activeBookings = 0,
    this.pendingBookings = 0,
    this.completedBookings = 0,
    this.totalEarnings = 0,
    this.pendingPayouts = 0,
    this.availableBalance = 0,
    this.commissionRate = 15.0,
    this.thisMonthEarnings = 0,
  });

  factory CompanyDashboardStats.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardStats(
      totalCars: int.tryParse(json['total_cars']?.toString() ?? '0') ?? 0,
      activeCars: int.tryParse(json['active_cars']?.toString() ?? '0') ?? 0,
      activeBookings: int.tryParse(json['active_bookings']?.toString() ?? '0') ?? 0,
      pendingBookings: int.tryParse(json['pending_bookings']?.toString() ?? '0') ?? 0,
      completedBookings: int.tryParse(json['completed_bookings']?.toString() ?? '0') ?? 0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0,
      pendingPayouts: double.tryParse(json['pending_payouts']?.toString() ?? '0') ?? 0,
      availableBalance: double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0,
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '15') ?? 15.0,
      thisMonthEarnings: double.tryParse(json['this_month_earnings']?.toString() ?? '0') ?? 0,
    );
  }
}

// Company Wallet Model
class CompanyWallet {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final double pendingPayouts;
  final double thisMonthEarnings;

  CompanyWallet({
    this.availableBalance = 0,
    this.pendingBalance = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.pendingPayouts = 0,
    this.thisMonthEarnings = 0,
  });

  factory CompanyWallet.fromJson(Map<String, dynamic> json) {
    return CompanyWallet(
      availableBalance: double.tryParse(json['available_balance']?.toString() ?? '0') ?? 0,
      pendingBalance: double.tryParse(json['pending_balance']?.toString() ?? '0') ?? 0,
      totalEarned: double.tryParse(json['total_earned']?.toString() ?? '0') ?? 0,
      totalWithdrawn: double.tryParse(json['total_withdrawn']?.toString() ?? '0') ?? 0,
      pendingPayouts: double.tryParse(json['pending_payouts']?.toString() ?? '0') ?? 0,
      thisMonthEarnings: double.tryParse(json['this_month_earnings']?.toString() ?? '0') ?? 0,
    );
  }
}

// Company Booking Model
class CompanyBooking {
  final int id;
  final String carTitle;
  final String? carImage;
  final String customerName;
  final String? customerPhone;
  final String pickupDate;
  final String returnDate;
  final double totalAmount;
  final double companyEarning;
  final String status;
  final String createdAt;

  CompanyBooking({
    required this.id,
    required this.carTitle,
    this.carImage,
    required this.customerName,
    this.customerPhone,
    required this.pickupDate,
    required this.returnDate,
    required this.totalAmount,
    required this.companyEarning,
    required this.status,
    required this.createdAt,
  });

  factory CompanyBooking.fromJson(Map<String, dynamic> json) {
    return CompanyBooking(
      id: int.parse(json['id'].toString()),
      carTitle: json['car_title'] ?? json['car_name'] ?? '',
      carImage: json['car_image'] ?? json['car_img'],
      customerName: json['customer_name'] ?? json['user_name'] ?? '',
      customerPhone: json['customer_phone'],
      pickupDate: json['pickup_date'] ?? json['pick_date'] ?? '',
      returnDate: json['return_date'] ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? json['o_total']?.toString() ?? '0') ?? 0,
      companyEarning: double.tryParse(json['company_earning']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? json['book_status'] ?? '',
      createdAt: json['created_at'] ?? json['create_date'] ?? '',
    );
  }
}

// Company Payout Model
class CompanyPayout {
  final int id;
  final double amount;
  final String paymentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String status;
  final String requestedAt;
  final String? processedAt;

  CompanyPayout({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    this.bankName,
    this.accountNumber,
    this.accountName,
    required this.status,
    required this.requestedAt,
    this.processedAt,
  });

  factory CompanyPayout.fromJson(Map<String, dynamic> json) {
    return CompanyPayout(
      id: int.parse(json['id'].toString()),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'] ?? 'bank_transfer',
      bankName: json['bank_name'],
      accountNumber: json['account_number_masked'] ?? json['account_number'],
      accountName: json['account_name'],
      status: json['status'] ?? 'pending',
      requestedAt: json['requested_at'] ?? '',
      processedAt: json['processed_at'],
    );
  }
}

// Company Notification Model
class CompanyNotification {
  final int id;
  final String title;
  final String? description;
  final String type;
  final int? referenceId;
  final bool isRead;
  final String createdAt;

  CompanyNotification({
    required this.id,
    required this.title,
    this.description,
    this.type = 'other',
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  factory CompanyNotification.fromJson(Map<String, dynamic> json) {
    return CompanyNotification(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'other',
      referenceId: json['reference_id'] != null ? int.tryParse(json['reference_id'].toString()) : null,
      isRead: json['is_read'] == 1 || json['is_read'] == '1' || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}
