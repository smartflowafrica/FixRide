import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/company_model.dart';
import '../service/company_api_service.dart';
import '../screen/company/company_dashboard.dart';
import '../screen/company/company_login.dart';

class CompanyAuthController extends GetxController {
  static CompanyAuthController get to => Get.find();

  final CompanyApiService _apiService = CompanyApiService();

  // Observables
  final Rx<Company?> company = Rx<Company?>(null);
  final Rx<CompanyUser?> user = Rx<CompanyUser?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString errorMessage = ''.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyNameController = TextEditingController();
  final phoneController = TextEditingController();
  final ownerNameController = TextEditingController();
  final addressController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  int? selectedCityId;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    phoneController.dispose();
    ownerNameController.dispose();
    addressController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    isLoading.value = true;
    try {
      final loggedIn = await _apiService.isCompanyLoggedIn();
      isLoggedIn.value = loggedIn;

      if (loggedIn) {
        final savedCompany = await _apiService.getSavedCompany();
        if (savedCompany != null) {
          company.value = savedCompany;
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
    isLoading.value = false;
  }

  Future<bool> login() async {
    if (!loginFormKey.currentState!.validate()) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _apiService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.success && response.company != null) {
        company.value = response.company;
        user.value = response.user;
        isLoggedIn.value = true;

        await _apiService.saveCompanySession(response.company!, response.user!);

        Fluttertoast.showToast(
          msg: "Login successful!",
          backgroundColor: Colors.green,
        );

        // Clear form
        emailController.clear();
        passwordController.clear();

        // Navigate to dashboard
        Get.offAll(() => CompanyDashboardScreen(company: response.company!));
        return true;
      } else {
        errorMessage.value = response.message;
        Fluttertoast.showToast(
          msg: response.message,
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
      Fluttertoast.showToast(
        msg: "Login failed. Please try again.",
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register() async {
    if (!registerFormKey.currentState!.validate()) return false;

    if (passwordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
        backgroundColor: Colors.red,
      );
      return false;
    }

    if (selectedCityId == null) {
      Fluttertoast.showToast(
        msg: "Please select a city",
        backgroundColor: Colors.red,
      );
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _apiService.register(
        companyName: companyNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        cityId: selectedCityId!,
        ownerName: ownerNameController.text.trim(),
        address: addressController.text.trim(),
      );

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Registration successful! Please login.",
          backgroundColor: Colors.green,
        );

        // Clear form
        clearRegistrationForm();

        // Navigate to login
        Get.off(() => const CompanyLoginScreen());
        return true;
      } else {
        errorMessage.value = result['ResponseMsg'] ?? 'Registration failed';
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Registration failed",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
      Fluttertoast.showToast(
        msg: "Registration failed. Please try again.",
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    company.value = null;
    user.value = null;
    isLoggedIn.value = false;
    Get.offAll(() => const CompanyLoginScreen());
  }

  void clearRegistrationForm() {
    companyNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    ownerNameController.clear();
    addressController.clear();
    selectedCityId = null;
  }

  Future<Map<String, dynamic>> checkCompanyStatus() async {
    if (company.value == null) return {'status': 'unknown'};

    try {
      final result = await _apiService.checkStatus(company.value!.id);
      if (result['Result'] == 'true') {
        // Update local company data if status changed
        if (result['company'] != null) {
          company.value = Company.fromJson(result['company']);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('company_data', company.value!.toJson().toString());
        }
      }
      return result;
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
