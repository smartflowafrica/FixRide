class CompanyDashboardStats {
  final int totalCars;
  final int activeCars;
  final int inactiveCars;
  final int totalBookings;
  final int pendingBookings;
  final int activeBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalEarnings;
  final double thisMonthEarnings;
  final double thisWeekEarnings;
  final double todayEarnings;
  final double availableBalance;
  final double pendingPayouts;
  final double commissionRate;
  final String lastUpdated;

  CompanyDashboardStats({
    required this.totalCars,
    required this.activeCars,
    required this.inactiveCars,
    required this.totalBookings,
    required this.pendingBookings,
    required this.activeBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.thisWeekEarnings,
    required this.todayEarnings,
    required this.availableBalance,
    required this.pendingPayouts,
    required this.commissionRate,
    required this.lastUpdated,
  });

  factory CompanyDashboardStats.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardStats(
      totalCars: _parseInt(json['total_cars']),
      activeCars: _parseInt(json['active_cars']),
      inactiveCars: _parseInt(json['inactive_cars']),
      totalBookings: _parseInt(json['total_bookings']),
      pendingBookings: _parseInt(json['pending_bookings']),
      activeBookings: _parseInt(json['active_bookings']),
      completedBookings: _parseInt(json['completed_bookings']),
      cancelledBookings: _parseInt(json['cancelled_bookings']),
      totalEarnings: _parseDouble(json['total_earnings']),
      thisMonthEarnings: _parseDouble(json['this_month_earnings']),
      thisWeekEarnings: _parseDouble(json['this_week_earnings']),
      todayEarnings: _parseDouble(json['today_earnings']),
      availableBalance: _parseDouble(json['available_balance']),
      pendingPayouts: _parseDouble(json['pending_payouts']),
      commissionRate: _parseDouble(json['commission_rate'], defaultValue: 15.0),
      lastUpdated: json['last_updated'] ?? DateTime.now().toIso8601String(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_cars': totalCars,
      'active_cars': activeCars,
      'inactive_cars': inactiveCars,
      'total_bookings': totalBookings,
      'pending_bookings': pendingBookings,
      'active_bookings': activeBookings,
      'completed_bookings': completedBookings,
      'cancelled_bookings': cancelledBookings,
      'total_earnings': totalEarnings,
      'this_month_earnings': thisMonthEarnings,
      'this_week_earnings': thisWeekEarnings,
      'today_earnings': todayEarnings,
      'available_balance': availableBalance,
      'pending_payouts': pendingPayouts,
      'commission_rate': commissionRate,
      'last_updated': lastUpdated,
    };
  }

  // Formatted display values
  String get formattedTotalEarnings => _formatCurrency(totalEarnings);
  String get formattedMonthEarnings => _formatCurrency(thisMonthEarnings);
  String get formattedWeekEarnings => _formatCurrency(thisWeekEarnings);
  String get formattedTodayEarnings => _formatCurrency(todayEarnings);
  String get formattedAvailableBalance => _formatCurrency(availableBalance);
  String get formattedPendingPayouts => _formatCurrency(pendingPayouts);
  String get formattedCommissionRate => '${commissionRate.toStringAsFixed(1)}%';

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }

  // Calculated properties
  int get ongoingBookings => pendingBookings + activeBookings;
  double get bookingCompletionRate => totalBookings > 0 ? (completedBookings / totalBookings) * 100 : 0;
  double get carUtilizationRate => totalCars > 0 ? (activeCars / totalCars) * 100 : 0;

  factory CompanyDashboardStats.empty() {
    return CompanyDashboardStats(
      totalCars: 0,
      activeCars: 0,
      inactiveCars: 0,
      totalBookings: 0,
      pendingBookings: 0,
      activeBookings: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      totalEarnings: 0,
      thisMonthEarnings: 0,
      thisWeekEarnings: 0,
      todayEarnings: 0,
      availableBalance: 0,
      pendingPayouts: 0,
      commissionRate: 15.0,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }
}

class EarningsReport {
  final String period; // daily, weekly, monthly, yearly
  final String startDate;
  final String endDate;
  final double grossEarnings;
  final double platformCommission;
  final double netEarnings;
  final int bookingsCount;
  final List<EarningsDataPoint> dataPoints;

  EarningsReport({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.grossEarnings,
    required this.platformCommission,
    required this.netEarnings,
    required this.bookingsCount,
    required this.dataPoints,
  });

  factory EarningsReport.fromJson(Map<String, dynamic> json) {
    return EarningsReport(
      period: json['period'] ?? 'monthly',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      grossEarnings: double.tryParse(json['gross_earnings']?.toString() ?? '0') ?? 0,
      platformCommission: double.tryParse(json['platform_commission']?.toString() ?? '0') ?? 0,
      netEarnings: double.tryParse(json['net_earnings']?.toString() ?? '0') ?? 0,
      bookingsCount: int.tryParse(json['bookings_count']?.toString() ?? '0') ?? 0,
      dataPoints: json['data_points'] != null
          ? (json['data_points'] as List).map((d) => EarningsDataPoint.fromJson(d)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate,
      'end_date': endDate,
      'gross_earnings': grossEarnings,
      'platform_commission': platformCommission,
      'net_earnings': netEarnings,
      'bookings_count': bookingsCount,
      'data_points': dataPoints.map((d) => d.toJson()).toList(),
    };
  }
}

class EarningsDataPoint {
  final String label;
  final String date;
  final double amount;
  final int bookings;

  EarningsDataPoint({
    required this.label,
    required this.date,
    required this.amount,
    required this.bookings,
  });

  factory EarningsDataPoint.fromJson(Map<String, dynamic> json) {
    return EarningsDataPoint(
      label: json['label'] ?? '',
      date: json['date'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      bookings: int.tryParse(json['bookings']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'date': date,
      'amount': amount,
      'bookings': bookings,
    };
  }
}

class CarPerformanceStats {
  final int carId;
  final String carTitle;
  final int totalBookings;
  final int completedBookings;
  final double totalRevenue;
  final double averageRating;
  final int reviewsCount;
  final double utilizationRate; // percentage of days booked

  CarPerformanceStats({
    required this.carId,
    required this.carTitle,
    required this.totalBookings,
    required this.completedBookings,
    required this.totalRevenue,
    required this.averageRating,
    required this.reviewsCount,
    required this.utilizationRate,
  });

  factory CarPerformanceStats.fromJson(Map<String, dynamic> json) {
    return CarPerformanceStats(
      carId: int.parse(json['car_id'].toString()),
      carTitle: json['car_title'] ?? '',
      totalBookings: int.tryParse(json['total_bookings']?.toString() ?? '0') ?? 0,
      completedBookings: int.tryParse(json['completed_bookings']?.toString() ?? '0') ?? 0,
      totalRevenue: double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0,
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      reviewsCount: int.tryParse(json['reviews_count']?.toString() ?? '0') ?? 0,
      utilizationRate: double.tryParse(json['utilization_rate']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'car_title': carTitle,
      'total_bookings': totalBookings,
      'completed_bookings': completedBookings,
      'total_revenue': totalRevenue,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
      'utilization_rate': utilizationRate,
    };
  }

  String get formattedRevenue {
    if (totalRevenue >= 1000000) {
      return '₦${(totalRevenue / 1000000).toStringAsFixed(1)}M';
    } else if (totalRevenue >= 1000) {
      return '₦${(totalRevenue / 1000).toStringAsFixed(1)}K';
    }
    return '₦${totalRevenue.toStringAsFixed(0)}';
  }

  String get formattedRating => averageRating.toStringAsFixed(1);
  String get formattedUtilization => '${utilizationRate.toStringAsFixed(0)}%';
}

class BookingStats {
  final int pending;
  final int confirmed;
  final int inProgress;
  final int completed;
  final int cancelled;
  final int total;

  BookingStats({
    required this.pending,
    required this.confirmed,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
    required this.total,
  });

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    final p = int.tryParse(json['pending']?.toString() ?? '0') ?? 0;
    final c = int.tryParse(json['confirmed']?.toString() ?? '0') ?? 0;
    final i = int.tryParse(json['in_progress']?.toString() ?? '0') ?? 0;
    final comp = int.tryParse(json['completed']?.toString() ?? '0') ?? 0;
    final can = int.tryParse(json['cancelled']?.toString() ?? '0') ?? 0;
    final t = int.tryParse(json['total']?.toString() ?? '0') ?? (p + c + i + comp + can);

    return BookingStats(
      pending: p,
      confirmed: c,
      inProgress: i,
      completed: comp,
      cancelled: can,
      total: t,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'confirmed': confirmed,
      'in_progress': inProgress,
      'completed': completed,
      'cancelled': cancelled,
      'total': total,
    };
  }

  int get active => pending + confirmed + inProgress;
  double get completionRate => total > 0 ? (completed / total) * 100 : 0;
  double get cancellationRate => total > 0 ? (cancelled / total) * 100 : 0;
}
