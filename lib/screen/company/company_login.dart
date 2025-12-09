import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../service/company_api_service.dart';
import 'company_dashboard.dart';
import 'company_registration.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = CompanyApiService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    if (await _apiService.isCompanyLoggedIn()) {
      final company = await _apiService.getSavedCompany();
      if (company != null) {
        Get.offAll(() => CompanyDashboardScreen(company: company));
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response.success && response.company != null && response.user != null) {
        await _apiService.saveCompanySession(response.company!, response.user!);
        
        Fluttertoast.showToast(
          msg: "Login successful!",
          backgroundColor: Colors.green,
        );
        
        Get.offAll(() => CompanyDashboardScreen(company: response.company!));
      } else {
        Fluttertoast.showToast(
          msg: response.message,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Login failed. Please try again.",
        backgroundColor: Colors.red,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo/Header
                Icon(
                  Icons.business,
                  size: 80,
                  color: Darkblue,
                ),
                const SizedBox(height: 16),
                
                Text(
                  "Company Portal",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: notifire.getdarkscolor,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  "Sign in to manage your rental business",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: greyColor,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: notifire.getdarkscolor),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: greyColor),
                    prefixIcon: Icon(Icons.email_outlined, color: Darkblue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Darkblue, width: 2),
                    ),
                    filled: true,
                    fillColor: notifire.getbgcolor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: notifire.getdarkscolor),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: greyColor),
                    prefixIcon: Icon(Icons.lock_outlined, color: Darkblue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: greyColor,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Darkblue, width: 2),
                    ),
                    filled: true,
                    fillColor: notifire.getbgcolor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Login Button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Darkblue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have a company account? ",
                      style: TextStyle(color: greyColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const CompanyRegistrationScreen());
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          color: Darkblue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Back to User App
                TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: greyColor),
                  label: Text(
                    "Back to User App",
                    style: TextStyle(color: greyColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
