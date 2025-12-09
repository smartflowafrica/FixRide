import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import '../utils/company_config.dart';
import '../model/company_models.dart';

class CompanyApiService {
  static final CompanyApiService _instance = CompanyApiService._internal();
  factory CompanyApiService() => _instance;
  CompanyApiService._internal();

  String get baseUrl => Config.baseUrl;

  // ==================== Authentication ====================

  Future<Map<String, dynamic>> register({
    required String companyName,
    required String email,
    required String password,
    required String phone,
    required int cityId,
    String? ownerName,
    String? address,
    String? businessRegNumber,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyRegister),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_name': companyName,
        'email': email,
        'password': password,
        'phone': phone,
        'city_id': cityId,
        'owner_name': ownerName ?? companyName,
        'address': address,
        'business_reg_number': businessRegNumber,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<CompanyLoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    return CompanyLoginResponse.fromJson(data);
  }

  Future<void> saveCompanySession(Company company, CompanyUser user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('company_data', jsonEncode(company.toJson()));
    prefs.setInt('company_id', company.id);
    prefs.setInt('company_user_id', user.id);
    prefs.setBool('is_company_logged_in', true);
  }

  Future<bool> isCompanyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_company_logged_in') ?? false;
  }

  Future<int?> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('company_id');
  }

  Future<Company?> getSavedCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('company_data');
    if (data != null) {
      return Company.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('company_data');
    prefs.remove('company_id');
    prefs.remove('company_user_id');
    prefs.setBool('is_company_logged_in', false);
  }

  Future<Map<String, dynamic>> checkStatus(int companyId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyCheckStatus}?company_id=$companyId'),
    );
    return jsonDecode(response.body);
  }

  // ==================== Dashboard ====================

  Future<CompanyDashboardStats> getDashboard(int companyId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyDashboard}?company_id=$companyId'),
    );
    final data = jsonDecode(response.body);
    if (data['Result'] == 'true') {
      return CompanyDashboardStats.fromJson(data);
    }
    throw Exception(data['ResponseMsg'] ?? 'Failed to load dashboard');
  }

  // ==================== Cars ====================

  Future<List<dynamic>> getCarList(int companyId, {int page = 1, int? status}) async {
    String url = '${baseUrl}${CompanyConfig.companyCarList}?company_id=$companyId&page=$page';
    if (status != null) url += '&status=$status';
    
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data['Result'] == 'true') {
      return data['cars'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> addCar({
    required int companyId,
    required String title,
    required int brandId,
    required int typeId,
    required String fuel,
    required String transmission,
    required int seats,
    required int cityId,
    required String acHeater,
    required double price,
    required String priceType,
    String? description,
    List<int>? facilities,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyAddCar),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'title': title,
        'brand': brandId,
        'type_id': typeId,
        'fuel': fuel,
        'transmission': transmission,
        'seat': seats,
        'city': cityId,
        'ac_heater': acHeater,
        'price': price,
        'price_type': priceType,
        'description': description,
        'facility': facilities,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> editCar({
    required int companyId,
    required int carId,
    Map<String, dynamic>? updates,
  }) async {
    final body = {
      'company_id': companyId,
      'car_id': carId,
      ...?updates,
    };
    
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyEditCar),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteCar(int companyId, int carId, {bool permanent = false}) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyDeleteCar),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'car_id': carId,
        'permanent': permanent,
      }),
    );
    return jsonDecode(response.body);
  }

  // ==================== Bookings ====================

  Future<Map<String, dynamic>> getBookings(int companyId, {int page = 1, String? status}) async {
    String url = '${baseUrl}${CompanyConfig.companyBookings}?company_id=$companyId&page=$page';
    if (status != null) url += '&status=$status';
    
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getBookingDetails(int companyId, int bookingId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyBookingDetails}?company_id=$companyId&booking_id=$bookingId'),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateBookingStatus(int companyId, int bookingId, String status, {String? reason}) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyUpdateBookingStatus),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'booking_id': bookingId,
        'status': status,
        if (reason != null) 'reason': reason,
      }),
    );
    return jsonDecode(response.body);
  }

  // ==================== Wallet & Earnings ====================

  Future<Map<String, dynamic>> getWallet(int companyId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyWallet}?company_id=$companyId&page=$page'),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getEarnings(int companyId, {int page = 1, String? startDate, String? endDate}) async {
    String url = '${baseUrl}${CompanyConfig.companyEarnings}?company_id=$companyId&page=$page';
    if (startDate != null) url += '&start_date=$startDate';
    if (endDate != null) url += '&end_date=$endDate';
    
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> requestPayout({
    required int companyId,
    required double amount,
    required String paymentMethod,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? paypalEmail,
    String? mobileMoney,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyRequestPayout),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'amount': amount,
        'payment_method': paymentMethod,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
        'paypal_email': paypalEmail,
        'mobile_money_number': mobileMoney,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getPayoutHistory(int companyId, {int page = 1, String? status}) async {
    String url = '${baseUrl}${CompanyConfig.companyPayoutHistory}?company_id=$companyId&page=$page';
    if (status != null) url += '&status=$status';
    
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  // ==================== Profile ====================

  Future<Map<String, dynamic>> updateProfile(int companyId, Map<String, dynamic> updates) async {
    final body = {'company_id': companyId, ...updates};
    
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyUpdateProfile),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  // ==================== Notifications ====================

  Future<Map<String, dynamic>> getNotifications(int companyId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyNotifications}?company_id=$companyId&page=$page'),
    );
    return jsonDecode(response.body);
  }

  Future<void> markNotificationRead(int companyId, {int? notificationId}) async {
    await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyMarkNotificationRead),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        if (notificationId != null) 'notification_id': notificationId,
      }),
    );
  }

  // ==================== Documents ====================

  Future<Map<String, dynamic>> getDocuments(int companyId) async {
    final response = await http.get(
      Uri.parse('${baseUrl}${CompanyConfig.companyDocuments}?company_id=$companyId'),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> uploadDocument(int companyId, String docType, dynamic file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + CompanyConfig.companyUploadDocument),
    );
    
    request.fields['company_id'] = companyId.toString();
    request.fields['document_type'] = docType;
    
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('document', file.path));
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  // ==================== Generic Methods ====================

  Future<Map<String, dynamic>> getCars(int companyId, {int page = 1, String? status}) async {
    String url = '${baseUrl}${CompanyConfig.companyCarList}?company_id=$companyId&page=$page';
    if (status != null) url += '&status=$status';
    
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addCar(
    Map<String, dynamic> carData, {
    dynamic mainImage,
    List<dynamic>? exteriorImages,
    List<dynamic>? interiorImages,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + CompanyConfig.companyAddCar),
    );
    
    carData.forEach((key, value) {
      request.fields[key] = value.toString();
    });
    
    if (mainImage != null) {
      request.files.add(await http.MultipartFile.fromPath('img', mainImage.path));
    }
    
    if (exteriorImages != null) {
      for (var i = 0; i < exteriorImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('exterior_$i', exteriorImages[i].path));
      }
    }
    
    if (interiorImages != null) {
      for (var i = 0; i < interiorImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('interior_$i', interiorImages[i].path));
      }
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCar(int carId, Map<String, dynamic> updates) async {
    final body = {'car_id': carId, ...updates};
    
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyEditCar),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteCar(int carId) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyDeleteCar),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'car_id': carId}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateBookingStatus(int bookingId, String status) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyUpdateBookingStatus),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'booking_id': bookingId,
        'status': status,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> requestPayout(int companyId, double amount) async {
    final response = await http.post(
      Uri.parse(baseUrl + CompanyConfig.companyRequestPayout),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'company_id': companyId,
        'amount': amount,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile(int companyId, Map<String, dynamic> profileData, {dynamic logo}) async {
    if (logo != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl + CompanyConfig.companyUpdateProfile),
      );
      
      request.fields['company_id'] = companyId.toString();
      profileData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } else {
      final body = {'company_id': companyId, ...profileData};
      
      final response = await http.post(
        Uri.parse(baseUrl + CompanyConfig.companyUpdateProfile),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    }
  }

  // Make generic API request
  Future<Map<String, dynamic>> makeRequest(String endpoint, Map<String, dynamic> params) async {
    final uri = Uri.parse(baseUrl + endpoint).replace(queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
    final response = await http.get(uri);
    return jsonDecode(response.body);
  }
}
