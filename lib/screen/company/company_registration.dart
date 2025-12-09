import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../service/company_api_service.dart';
import 'company_login.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = CompanyApiService();
  
  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessRegController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int? _selectedCityId;
  
  late ColorNotifire notifire;

  // TODO: Load cities from API
  final List<Map<String, dynamic>> _cities = [
    {'id': 1, 'name': 'Lagos'},
    {'id': 2, 'name': 'Abuja'},
    {'id': 3, 'name': 'Port Harcourt'},
    {'id': 4, 'name': 'Kano'},
    {'id': 5, 'name': 'Ibadan'},
  ];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityId == null) {
      Fluttertoast.showToast(
        msg: "Please select a city",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        companyName: _companyNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        cityId: _selectedCityId!,
        ownerName: _ownerNameController.text.trim(),
        address: _addressController.text.trim(),
        businessRegNumber: _businessRegController.text.trim(),
      );

      if (response['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Registration successful! Please login.",
          backgroundColor: Colors.green,
        );
        Get.off(() => const CompanyLoginScreen());
      } else {
        Fluttertoast.showToast(
          msg: response['ResponseMsg'] ?? 'Registration failed',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Registration failed. Please try again.",
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
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Register Company",
          style: TextStyle(color: notifire.getdarkscolor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _register();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Darkblue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading && _currentStep == 2
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 2 ? "Register" : "Continue",
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text("Back", style: TextStyle(color: greyColor)),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Company Info
            Step(
              title: Text("Company Info", style: TextStyle(color: notifire.getdarkscolor)),
              subtitle: Text("Basic details", style: TextStyle(color: greyColor)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _buildTextField(
                    controller: _companyNameController,
                    label: "Company Name",
                    icon: Icons.business,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ownerNameController,
                    label: "Owner/Manager Name",
                    icon: Icons.person,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: "Business Address",
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            
            // Step 2: Contact & Business
            Step(
              title: Text("Contact Details", style: TextStyle(color: notifire.getdarkscolor)),
              subtitle: Text("Email & phone", style: TextStyle(color: greyColor)),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (!GetUtils.isEmail(v)) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessRegController,
                    label: "Business Registration Number (Optional)",
                    icon: Icons.badge,
                  ),
                ],
              ),
            ),
            
            // Step 3: Account Setup
            Step(
              title: Text("Account Setup", style: TextStyle(color: notifire.getdarkscolor)),
              subtitle: Text("Create password", style: TextStyle(color: greyColor)),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: greyColor,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: greyColor,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Darkblue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Darkblue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Your company will be reviewed before activation. You'll be notified via email.",
                            style: TextStyle(
                              fontSize: 12,
                              color: notifire.getdarkscolor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: TextStyle(color: notifire.getdarkscolor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: greyColor),
        prefixIcon: Icon(icon, color: Darkblue),
        suffixIcon: suffixIcon,
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
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCityId,
      decoration: InputDecoration(
        labelText: "City",
        labelStyle: TextStyle(color: greyColor),
        prefixIcon: Icon(Icons.location_city, color: Darkblue),
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
      dropdownColor: notifire.getbgcolor,
      style: TextStyle(color: notifire.getdarkscolor),
      items: _cities.map((city) {
        return DropdownMenuItem<int>(
          value: city['id'],
          child: Text(city['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCityId = value);
      },
      validator: (v) => v == null ? 'Please select a city' : null,
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _businessRegController.dispose();
    super.dispose();
  }
}
