import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../service/company_api_service.dart';

class CompanyAddCarScreen extends StatefulWidget {
  final int companyId;
  final dynamic car; // null for add, car data for edit
  
  const CompanyAddCarScreen({super.key, required this.companyId, this.car});

  @override
  State<CompanyAddCarScreen> createState() => _CompanyAddCarScreenState();
}

class _CompanyAddCarScreenState extends State<CompanyAddCarScreen> {
  final _apiService = CompanyApiService();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late ColorNotifire notifire;
  
  bool get isEditMode => widget.car != null;
  bool _isLoading = false;
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rentController = TextEditingController();
  final _seatController = TextEditingController();
  final _speedController = TextEditingController();
  
  // Dropdowns
  List<dynamic> _brands = [];
  List<dynamic> _carTypes = [];
  List<dynamic> _cities = [];
  List<dynamic> _facilities = [];
  
  String? _selectedBrandId;
  String? _selectedCarTypeId;
  String? _selectedCityId;
  String? _selectedFuelType;
  String? _selectedGearType;
  List<String> _selectedFacilities = [];
  
  // Images
  File? _mainImage;
  List<File> _exteriorImages = [];
  List<File> _interiorImages = [];

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'CNG'];
  final List<String> _gearTypes = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();
    _loadFormData();
    if (isEditMode) {
      _populateForm();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rentController.dispose();
    _seatController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  void _populateForm() {
    final car = widget.car;
    _titleController.text = car['title'] ?? '';
    _descController.text = car['description'] ?? '';
    _rentController.text = car['rent'] ?? '';
    _seatController.text = car['seat'] ?? '';
    _speedController.text = car['speed'] ?? '';
    _selectedBrandId = car['brand_id']?.toString();
    _selectedCarTypeId = car['car_type_id']?.toString();
    _selectedCityId = car['city_id']?.toString();
    _selectedFuelType = car['fueltype'];
    _selectedGearType = car['geartype'];
    
    if (car['facility_ids'] != null) {
      _selectedFacilities = car['facility_ids'].toString().split(',');
    }
  }

  Future<void> _loadFormData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load brands, car types, cities, and facilities
      // These endpoints should exist in your API
      final brandsData = await _apiService.makeRequest('carbrand.php', {'lats': '0', 'longs': '0'});
      final typesData = await _apiService.makeRequest('cartype.php', {'lats': '0', 'longs': '0'});
      final citiesData = await _apiService.makeRequest('citylist.php', {'lats': '0', 'longs': '0'});
      final facilitiesData = await _apiService.makeRequest('facilitylist.php', {});
      
      setState(() {
        if (brandsData['carbrand'] != null) _brands = brandsData['carbrand'];
        if (typesData['cartype'] != null) _carTypes = typesData['cartype'];
        if (citiesData['citylist'] != null) _cities = citiesData['citylist'];
        if (facilitiesData['Faclist'] != null) _facilities = facilitiesData['Faclist'];
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load form data",
        backgroundColor: Colors.red,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'main':
            _mainImage = File(image.path);
            break;
          case 'exterior':
            if (_exteriorImages.length < 5) {
              _exteriorImages.add(File(image.path));
            }
            break;
          case 'interior':
            if (_interiorImages.length < 5) {
              _interiorImages.add(File(image.path));
            }
            break;
        }
      });
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!isEditMode && _mainImage == null) {
      Fluttertoast.showToast(
        msg: "Please select a main car image",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final carData = {
        'company_id': widget.companyId.toString(),
        'title': _titleController.text,
        'description': _descController.text,
        'rent': _rentController.text,
        'seat': _seatController.text,
        'speed': _speedController.text,
        'brand_id': _selectedBrandId ?? '',
        'car_type_id': _selectedCarTypeId ?? '',
        'city_id': _selectedCityId ?? '',
        'fueltype': _selectedFuelType ?? '',
        'geartype': _selectedGearType ?? '',
        'facility_ids': _selectedFacilities.join(','),
      };

      Map<String, dynamic> result;
      
      if (isEditMode) {
        result = await _apiService.updateCar(
          int.parse(widget.car['id'].toString()),
          carData,
        );
      } else {
        result = await _apiService.addCar(
          carData,
          mainImage: _mainImage,
          exteriorImages: _exteriorImages,
          interiorImages: _interiorImages,
        );
      }

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: isEditMode ? "Car updated successfully" : "Car added successfully",
          backgroundColor: Colors.green,
        );
        Get.back(result: true);
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to save car",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error saving car: $e",
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
        backgroundColor: Darkblue,
        title: Text(isEditMode ? "Edit Car" : "Add New Car"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle("Basic Information"),
                  _buildTextField(_titleController, "Car Title", Icons.directions_car),
                  const SizedBox(height: 12),
                  _buildTextField(_descController, "Description", Icons.description, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(_rentController, "Rent Per Day (₦)", Icons.attach_money, keyboardType: TextInputType.number),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Specifications"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_seatController, "Seats", Icons.airline_seat_recline_normal, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(_speedController, "Speed (km/h)", Icons.speed, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown("Fuel Type", _fuelTypes, _selectedFuelType, (v) => setState(() => _selectedFuelType = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDropdown("Gear Type", _gearTypes, _selectedGearType, (v) => setState(() => _selectedGearType = v))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Category"),
                  _buildEntityDropdown("Brand", _brands, _selectedBrandId, (v) => setState(() => _selectedBrandId = v)),
                  const SizedBox(height: 12),
                  _buildEntityDropdown("Car Type", _carTypes, _selectedCarTypeId, (v) => setState(() => _selectedCarTypeId = v)),
                  const SizedBox(height: 12),
                  _buildEntityDropdown("City", _cities, _selectedCityId, (v) => setState(() => _selectedCityId = v)),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Facilities"),
                  _buildFacilitiesChips(),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle("Images"),
                  _buildMainImagePicker(),
                  const SizedBox(height: 12),
                  _buildMultiImagePicker("Exterior Images", _exteriorImages, 'exterior'),
                  const SizedBox(height: 12),
                  _buildMultiImagePicker("Interior Images", _interiorImages, 'interior'),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Darkblue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEditMode ? "Update Car" : "Add Car",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: notifire.getdarkscolor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: greyColor),
        prefixIcon: Icon(icon, color: Darkblue),
        filled: true,
        fillColor: notifire.getbgcolor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Darkblue),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: greyColor),
        filled: true,
        fillColor: notifire.getbgcolor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
        ),
      ),
      dropdownColor: notifire.getbgcolor,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(color: notifire.getdarkscolor)),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildEntityDropdown(String label, List<dynamic> items, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: greyColor),
        filled: true,
        fillColor: notifire.getbgcolor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
        ),
      ),
      dropdownColor: notifire.getbgcolor,
      items: items.map((item) => DropdownMenuItem(
        value: item['id'].toString(),
        child: Text(item['title'] ?? item['name'] ?? '', style: TextStyle(color: notifire.getdarkscolor)),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildFacilitiesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _facilities.map((facility) {
        final id = facility['id'].toString();
        final isSelected = _selectedFacilities.contains(id);
        return FilterChip(
          label: Text(facility['title'] ?? ''),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFacilities.add(id);
              } else {
                _selectedFacilities.remove(id);
              }
            });
          },
          selectedColor: Darkblue.withOpacity(0.2),
          checkmarkColor: Darkblue,
          labelStyle: TextStyle(color: isSelected ? Darkblue : notifire.getdarkscolor),
        );
      }).toList(),
    );
  }

  Widget _buildMainImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Main Image *", style: TextStyle(color: notifire.getdarkscolor)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage('main'),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: greyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: greyColor.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: _mainImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_mainImage!, fit: BoxFit.cover),
                  )
                : isEditMode && widget.car['img'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.car['img'], fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 48, color: greyColor),
                          const SizedBox(height: 8),
                          Text("Tap to upload", style: TextStyle(color: greyColor)),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiImagePicker(String label, List<File> images, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: notifire.getdarkscolor)),
            Text("${images.length}/5", style: TextStyle(color: greyColor, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...images.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => images.removeAt(entry.key)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (images.length < 5)
                GestureDetector(
                  onTap: () => _pickImage(type),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: greyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greyColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.add, color: greyColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
