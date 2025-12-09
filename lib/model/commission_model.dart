class Commission {
  final int id;
  final int bookingId;
  final int companyId;
  final double totalAmount;
  final double commissionRate;
  final double commissionAmount;
  final double companyEarning;
  final String status; // pending, credited, paid_out
  final String createdAt;

  Commission({
    required this.id,
    required this.bookingId,
    required this.companyId,
    required this.totalAmount,
    required this.commissionRate,
    required this.commissionAmount,
    required this.companyEarning,
    required this.status,
    required this.createdAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    final total = double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0;
    final rate = double.tryParse(json['commission_rate']?.toString() ?? '15') ?? 15;
    final commission = double.tryParse(json['commission_amount']?.toString() ?? '0') ?? (total * rate / 100);
    final earning = double.tryParse(json['company_earning']?.toString() ?? '0') ?? (total - commission);

    return Commission(
      id: int.parse(json['id'].toString()),
      bookingId: int.parse(json['booking_id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      totalAmount: total,
      commissionRate: rate,
      commissionAmount: commission,
      companyEarning: earning,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'company_id': companyId,
      'total_amount': totalAmount,
      'commission_rate': commissionRate,
      'commission_amount': commissionAmount,
      'company_earning': companyEarning,
      'status': status,
      'created_at': createdAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCredited => status == 'credited';
  bool get isPaidOut => status == 'paid_out';
}

class CommissionCalculator {
  final double defaultRate;

  CommissionCalculator({this.defaultRate = 15.0});

  /// Calculate commission breakdown for a booking
  CommissionBreakdown calculate(double totalAmount, {double? customRate}) {
    final rate = customRate ?? defaultRate;
    final platformCommission = totalAmount * rate / 100;
    final companyEarning = totalAmount - platformCommission;

    return CommissionBreakdown(
      totalAmount: totalAmount,
      commissionRate: rate,
      platformCommission: platformCommission,
      companyEarning: companyEarning,
    );
  }

  /// Calculate from daily rate and number of days
  CommissionBreakdown calculateFromDays(double dailyRate, int days, {double? customRate}) {
    final totalAmount = dailyRate * days;
    return calculate(totalAmount, customRate: customRate);
  }
}

class CommissionBreakdown {
  final double totalAmount;
  final double commissionRate;
  final double platformCommission;
  final double companyEarning;

  CommissionBreakdown({
    required this.totalAmount,
    required this.commissionRate,
    required this.platformCommission,
    required this.companyEarning,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_amount': totalAmount,
      'commission_rate': commissionRate,
      'platform_commission': platformCommission,
      'company_earning': companyEarning,
    };
  }

  String get formattedTotal => '₦${_formatNumber(totalAmount)}';
  String get formattedCommission => '₦${_formatNumber(platformCommission)}';
  String get formattedEarning => '₦${_formatNumber(companyEarning)}';
  String get formattedRate => '${commissionRate.toStringAsFixed(1)}%';

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class CommissionSummary {
  final double totalEarnings;
  final double totalCommissions;
  final double totalCompanyPayouts;
  final int totalBookings;
  final double averageCommissionRate;

  CommissionSummary({
    required this.totalEarnings,
    required this.totalCommissions,
    required this.totalCompanyPayouts,
    required this.totalBookings,
    required this.averageCommissionRate,
  });

  factory CommissionSummary.fromJson(Map<String, dynamic> json) {
    return CommissionSummary(
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0,
      totalCommissions: double.tryParse(json['total_commissions']?.toString() ?? '0') ?? 0,
      totalCompanyPayouts: double.tryParse(json['total_company_payouts']?.toString() ?? '0') ?? 0,
      totalBookings: int.tryParse(json['total_bookings']?.toString() ?? '0') ?? 0,
      averageCommissionRate: double.tryParse(json['average_commission_rate']?.toString() ?? '15') ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings': totalEarnings,
      'total_commissions': totalCommissions,
      'total_company_payouts': totalCompanyPayouts,
      'total_bookings': totalBookings,
      'average_commission_rate': averageCommissionRate,
    };
  }
}
