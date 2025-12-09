class Payout {
  final int id;
  final int companyId;
  final String? companyName;
  final double amount;
  final String paymentMethod; // bank_transfer, paystack, mobile_money
  final String status; // pending, processing, completed, rejected
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? transactionRef;
  final String? remarks;
  final String requestedAt;
  final String? processedAt;

  Payout({
    required this.id,
    required this.companyId,
    this.companyName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.transactionRef,
    this.remarks,
    required this.requestedAt,
    this.processedAt,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: int.parse(json['id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      companyName: json['company_name'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'] ?? 'bank_transfer',
      status: json['status'] ?? 'pending',
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      accountName: json['account_name'],
      transactionRef: json['transaction_ref'],
      remarks: json['remarks'],
      requestedAt: json['requested_at'] ?? json['created_at'] ?? '',
      processedAt: json['processed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'transaction_ref': transactionRef,
      'remarks': remarks,
      'requested_at': requestedAt,
      'processed_at': processedAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  String get formattedAmount => '₦${_formatNumber(amount)}';

  String get paymentMethodName {
    switch (paymentMethod) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paystack':
        return 'Paystack';
      case 'mobile_money':
        return 'Mobile Money';
      default:
        return paymentMethod;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class PayoutRequest {
  final int companyId;
  final double amount;
  final String paymentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;

  PayoutRequest({
    required this.companyId,
    required this.amount,
    this.paymentMethod = 'bank_transfer',
    this.bankName,
    this.accountNumber,
    this.accountName,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'amount': amount,
      'payment_method': paymentMethod,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (accountName != null) 'account_name': accountName,
    };
  }

  bool validate() {
    if (amount <= 0) return false;
    if (paymentMethod == 'bank_transfer') {
      return bankName != null && accountNumber != null && accountName != null;
    }
    return true;
  }
}

class PayoutSummary {
  final double totalRequested;
  final double totalCompleted;
  final double totalPending;
  final int requestCount;
  final int completedCount;
  final int pendingCount;

  PayoutSummary({
    required this.totalRequested,
    required this.totalCompleted,
    required this.totalPending,
    required this.requestCount,
    required this.completedCount,
    required this.pendingCount,
  });

  factory PayoutSummary.fromJson(Map<String, dynamic> json) {
    return PayoutSummary(
      totalRequested: double.tryParse(json['total_requested']?.toString() ?? '0') ?? 0,
      totalCompleted: double.tryParse(json['total_completed']?.toString() ?? '0') ?? 0,
      totalPending: double.tryParse(json['total_pending']?.toString() ?? '0') ?? 0,
      requestCount: int.tryParse(json['request_count']?.toString() ?? '0') ?? 0,
      completedCount: int.tryParse(json['completed_count']?.toString() ?? '0') ?? 0,
      pendingCount: int.tryParse(json['pending_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_requested': totalRequested,
      'total_completed': totalCompleted,
      'total_pending': totalPending,
      'request_count': requestCount,
      'completed_count': completedCount,
      'pending_count': pendingCount,
    };
  }
}

class WalletTransaction {
  final int id;
  final int companyId;
  final String type; // credit, debit
  final double amount;
  final String description;
  final String? referenceType; // booking, payout, adjustment
  final int? referenceId;
  final double balanceAfter;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.companyId,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceType,
    this.referenceId,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: int.parse(json['id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      type: json['type'] ?? 'credit',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      referenceType: json['reference_type'],
      referenceId: json['reference_id'] != null ? int.tryParse(json['reference_id'].toString()) : null,
      balanceAfter: double.tryParse(json['balance_after']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'type': type,
      'amount': amount,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'balance_after': balanceAfter,
      'created_at': createdAt,
    };
  }

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  String get formattedAmount => '${isCredit ? '+' : '-'}₦${amount.toStringAsFixed(0)}';
}

class CompanyWallet {
  final int companyId;
  final double totalEarnings;
  final double totalWithdrawn;
  final double pendingAmount;
  final double availableBalance;
  final String lastUpdated;

  CompanyWallet({
    required this.companyId,
    required this.totalEarnings,
    required this.totalWithdrawn,
    required this.pendingAmount,
    required this.availableBalance,
    required this.lastUpdated,
  });

  factory CompanyWallet.fromJson(Map<String, dynamic> json) {
    final total = double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0;
    final withdrawn = double.tryParse(json['total_withdrawn']?.toString() ?? '0') ?? 0;
    final pending = double.tryParse(json['pending_amount']?.toString() ?? '0') ?? 0;
    final available = double.tryParse(json['available_balance']?.toString() ?? '0') ?? (total - withdrawn - pending);

    return CompanyWallet(
      companyId: int.parse(json['company_id'].toString()),
      totalEarnings: total,
      totalWithdrawn: withdrawn,
      pendingAmount: pending,
      availableBalance: available,
      lastUpdated: json['last_updated'] ?? json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'total_earnings': totalEarnings,
      'total_withdrawn': totalWithdrawn,
      'pending_amount': pendingAmount,
      'available_balance': availableBalance,
      'last_updated': lastUpdated,
    };
  }

  bool canWithdraw(double amount) => amount > 0 && amount <= availableBalance;
}
