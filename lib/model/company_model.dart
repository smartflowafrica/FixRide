class Company {
  final int id;
  final String companyName;
  final String email;
  final String phone;
  final String? ownerName;
  final String? logo;
  final String? address;
  final String? description;
  final String? businessRegNumber;
  final int cityId;
  final String? cityName;
  final String status; // pending, approved, rejected, suspended
  final bool isVerified;
  final double commissionRate;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String createdAt;
  final String? updatedAt;

  Company({
    required this.id,
    required this.companyName,
    required this.email,
    required this.phone,
    this.ownerName,
    this.logo,
    this.address,
    this.description,
    this.businessRegNumber,
    required this.cityId,
    this.cityName,
    required this.status,
    this.isVerified = false,
    this.commissionRate = 15.0,
    this.bankName,
    this.accountName,
    this.accountNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.parse(json['id'].toString()),
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      ownerName: json['owner_name'],
      logo: json['logo'],
      address: json['address'],
      description: json['description'],
      businessRegNumber: json['business_reg_number'],
      cityId: int.tryParse(json['city_id']?.toString() ?? '0') ?? 0,
      cityName: json['city_name'],
      status: json['status'] ?? 'pending',
      isVerified: json['is_verified'] == '1' || json['is_verified'] == true,
      commissionRate: double.tryParse(json['commission_rate']?.toString() ?? '15') ?? 15.0,
      bankName: json['bank_name'],
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'owner_name': ownerName,
      'logo': logo,
      'address': address,
      'description': description,
      'business_reg_number': businessRegNumber,
      'city_id': cityId,
      'city_name': cityName,
      'status': status,
      'is_verified': isVerified ? '1' : '0',
      'commission_rate': commissionRate,
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isSuspended => status == 'suspended';
  bool get canOperate => isApproved && !isSuspended;

  Company copyWith({
    int? id,
    String? companyName,
    String? email,
    String? phone,
    String? ownerName,
    String? logo,
    String? address,
    String? description,
    String? businessRegNumber,
    int? cityId,
    String? cityName,
    String? status,
    bool? isVerified,
    double? commissionRate,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? createdAt,
    String? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      ownerName: ownerName ?? this.ownerName,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      description: description ?? this.description,
      businessRegNumber: businessRegNumber ?? this.businessRegNumber,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      commissionRate: commissionRate ?? this.commissionRate,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CompanyUser {
  final int id;
  final int companyId;
  final String name;
  final String email;
  final String? phone;
  final String role; // owner, manager, staff
  final String status;
  final String createdAt;

  CompanyUser({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory CompanyUser.fromJson(Map<String, dynamic> json) {
    return CompanyUser(
      id: int.parse(json['id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'staff',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'created_at': createdAt,
    };
  }

  bool get isOwner => role == 'owner';
  bool get isManager => role == 'manager';
  bool get isStaff => role == 'staff';
  bool get isActive => status == 'active';
}

class CompanyDocument {
  final int id;
  final int companyId;
  final String documentType;
  final String documentUrl;
  final String status; // pending, approved, rejected
  final String? remarks;
  final String uploadedAt;
  final String? reviewedAt;

  CompanyDocument({
    required this.id,
    required this.companyId,
    required this.documentType,
    required this.documentUrl,
    required this.status,
    this.remarks,
    required this.uploadedAt,
    this.reviewedAt,
  });

  factory CompanyDocument.fromJson(Map<String, dynamic> json) {
    return CompanyDocument(
      id: int.parse(json['id'].toString()),
      companyId: int.parse(json['company_id'].toString()),
      documentType: json['document_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
      status: json['status'] ?? 'pending',
      remarks: json['remarks'],
      uploadedAt: json['uploaded_at'] ?? json['created_at'] ?? '',
      reviewedAt: json['reviewed_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'document_type': documentType,
      'document_url': documentUrl,
      'status': status,
      'remarks': remarks,
      'uploaded_at': uploadedAt,
      'reviewed_at': reviewedAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get documentTypeName {
    switch (documentType) {
      case 'business_registration':
        return 'Business Registration';
      case 'id_card':
        return 'ID Card / Passport';
      case 'utility_bill':
        return 'Utility Bill';
      case 'tax_certificate':
        return 'Tax Certificate';
      default:
        return documentType.replaceAll('_', ' ').toUpperCase();
    }
  }
}

class CompanyLoginResponse {
  final bool success;
  final String message;
  final Company? company;
  final CompanyUser? user;
  final String? token;

  CompanyLoginResponse({
    required this.success,
    required this.message,
    this.company,
    this.user,
    this.token,
  });

  factory CompanyLoginResponse.fromJson(Map<String, dynamic> json) {
    return CompanyLoginResponse(
      success: json['Result'] == 'true',
      message: json['ResponseMsg'] ?? '',
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      user: json['user'] != null ? CompanyUser.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}
