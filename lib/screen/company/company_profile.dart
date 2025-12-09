import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../model/company_models.dart';
import '../../service/company_api_service.dart';
import 'company_login.dart';

class CompanyProfileScreen extends StatefulWidget {
  final Company company;
  
  const CompanyProfileScreen({super.key, required this.company});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _apiService = CompanyApiService();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late ColorNotifire notifire;
  
  late Company _company;
  bool _isLoading = false;
  bool _isEditing = false;
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  
  File? _newLogo;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _company = widget.company;
    _initControllers();
    _loadDocuments();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: _company.companyName);
    _emailController = TextEditingController(text: _company.email);
    _phoneController = TextEditingController(text: _company.phone);
    _addressController = TextEditingController(text: _company.address ?? '');
    _descController = TextEditingController(text: _company.description ?? '');
    _bankNameController = TextEditingController(text: _company.bankName ?? '');
    _accountNameController = TextEditingController(text: _company.accountName ?? '');
    _accountNumberController = TextEditingController(text: _company.accountNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    try {
      final result = await _apiService.getDocuments(_company.id);
      if (result['Result'] == 'true' && result['documents'] != null) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(result['documents']);
        });
      }
    } catch (e) {
      debugPrint("Error loading documents: $e");
    }
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _newLogo = File(image.path));
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final profileData = {
        'company_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descController.text,
        'bank_name': _bankNameController.text,
        'account_name': _accountNameController.text,
        'account_number': _accountNumberController.text,
      };

      final result = await _apiService.updateProfile(_company.id, profileData, logo: _newLogo);
      
      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          backgroundColor: Colors.green,
        );
        setState(() {
          _isEditing = false;
          _newLogo = null;
        });
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to update",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating profile",
        backgroundColor: Colors.red,
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _uploadDocument(String docType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.uploadDocument(
        _company.id,
        docType,
        File(image.path),
      );

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Document uploaded successfully",
          backgroundColor: Colors.green,
        );
        _loadDocuments();
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to upload",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error uploading document",
        backgroundColor: Colors.red,
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _apiService.logout();
      Get.offAll(() => const CompanyLoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: Darkblue,
        title: const Text("Company Profile"),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isEditing = false;
                _initControllers();
                _newLogo = null;
              }),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Company Information"),
                  _buildTextField(_nameController, "Company Name", Icons.business, enabled: _isEditing),
                  _buildTextField(_emailController, "Email", Icons.email, enabled: _isEditing),
                  _buildTextField(_phoneController, "Phone", Icons.phone, enabled: _isEditing),
                  _buildTextField(_addressController, "Address", Icons.location_on, enabled: _isEditing),
                  _buildTextField(_descController, "Description", Icons.description, enabled: _isEditing, maxLines: 3),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Bank Details"),
                  _buildTextField(_bankNameController, "Bank Name", Icons.account_balance, enabled: _isEditing),
                  _buildTextField(_accountNameController, "Account Name", Icons.person, enabled: _isEditing),
                  _buildTextField(_accountNumberController, "Account Number", Icons.credit_card, enabled: _isEditing),
                  
                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Darkblue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Verification Documents"),
                  _buildDocumentsSection(),
                  
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text("Logout", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickLogo : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Darkblue.withOpacity(0.1),
                  backgroundImage: _newLogo != null
                      ? FileImage(_newLogo!)
                      : (_company.logo != null ? NetworkImage(_company.logo!) as ImageProvider : null),
                  child: _newLogo == null && _company.logo == null
                      ? Text(
                          _company.companyName[0].toUpperCase(),
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Darkblue),
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Darkblue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _company.companyName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: notifire.getdarkscolor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _company.email,
            style: TextStyle(color: greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (_company.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "Verified Company";
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = "Verification Pending";
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = "Verification Rejected";
        break;
      default:
        statusColor = greyColor;
        statusIcon = Icons.info;
        statusText = _company.status;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 16,
                  ),
                ),
                if (_company.status == 'pending')
                  Text(
                    "Upload required documents for verification",
                    style: TextStyle(color: greyColor, fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(
            "${_company.commissionRate}%",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: notifire.getdarkscolor,
            ),
          ),
          Text(" commission", style: TextStyle(color: greyColor, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: notifire.getdarkscolor,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(color: notifire.getdarkscolor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: greyColor),
          prefixIcon: Icon(icon, color: enabled ? Darkblue : greyColor),
          filled: true,
          fillColor: enabled ? notifire.getbgcolor : greyColor.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: greyColor.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final docTypes = [
      {'type': 'business_registration', 'title': 'Business Registration', 'icon': Icons.business},
      {'type': 'id_card', 'title': 'ID Card / Passport', 'icon': Icons.badge},
      {'type': 'utility_bill', 'title': 'Utility Bill', 'icon': Icons.receipt},
    ];

    return Column(
      children: docTypes.map((doc) {
        final existing = _documents.firstWhere(
          (d) => d['document_type'] == doc['type'],
          orElse: () => {},
        );
        final hasDoc = existing.isNotEmpty;
        final status = existing['status'] ?? '';
        
        Color statusColor = greyColor;
        if (status == 'approved') statusColor = Colors.green;
        if (status == 'pending') statusColor = Colors.orange;
        if (status == 'rejected') statusColor = Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifire.getbgcolor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyColor.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Darkblue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(doc['icon'] as IconData, color: Darkblue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: notifire.getdarkscolor,
                      ),
                    ),
                    if (hasDoc)
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        "Not uploaded",
                        style: TextStyle(fontSize: 11, color: greyColor),
                      ),
                  ],
                ),
              ),
              if (hasDoc)
                Icon(Icons.check_circle, color: statusColor)
              else
                ElevatedButton(
                  onPressed: () => _uploadDocument(doc['type'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Darkblue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text("Upload", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
