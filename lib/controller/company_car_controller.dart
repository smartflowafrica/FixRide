import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../service/company_api_service.dart';

class CompanyCarController extends GetxController {
  static CompanyCarController get to => Get.find();

  final CompanyApiService _apiService = CompanyApiService();

  // Car lists
  final RxList<Map<String, dynamic>> allCars = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> activeCars = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> inactiveCars = <Map<String, dynamic>>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Form data
  final RxInt selectedBrandId = 0.obs;
  final RxInt selectedTypeId = 0.obs;
  final RxInt selectedCityId = 0.obs;
  final RxString selectedFuelType = ''.obs;
  final RxString selectedGearType = ''.obs;
  final RxList<int> selectedFacilities = <int>[].obs;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final rentController = TextEditingController();
  final seatController = TextEditingController();
  final speedController = TextEditingController();

  // Images
  final Rx<File?> mainImage = Rx<File?>(null);
  final RxList<File> exteriorImages = <File>[].obs;
  final RxList<File> interiorImages = <File>[].obs;

  // Dropdown data
  final RxList<Map<String, dynamic>> brands = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> carTypes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cities = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> facilities = <Map<String, dynamic>>[].obs;

  int companyId = 0;

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    rentController.dispose();
    seatController.dispose();
    speedController.dispose();
    super.onClose();
  }

  void setCompanyId(int id) {
    companyId = id;
  }

  Future<void> loadCars() async {
    if (companyId == 0) return;

    isLoading.value = true;

    try {
      final data = await _apiService.getCars(companyId);
      if (data['Result'] == 'true' && data['cars'] != null) {
        final cars = List<Map<String, dynamic>>.from(data['cars']);
        allCars.value = cars;
        activeCars.value = cars.where((c) => c['status'] == '1').toList();
        inactiveCars.value = cars.where((c) => c['status'] != '1').toList();
      }
    } catch (e) {
      debugPrint('Error loading cars: $e');
      Fluttertoast.showToast(
        msg: "Failed to load cars",
        backgroundColor: Colors.red,
      );
    }

    isLoading.value = false;
  }

  Future<void> loadFormData() async {
    try {
      final brandsData = await _apiService.makeRequest('carbrand.php', {'lats': '0', 'longs': '0'});
      final typesData = await _apiService.makeRequest('cartype.php', {'lats': '0', 'longs': '0'});
      final citiesData = await _apiService.makeRequest('citylist.php', {'lats': '0', 'longs': '0'});
      final facilitiesData = await _apiService.makeRequest('facilitylist.php', {});

      if (brandsData['carbrand'] != null) {
        brands.value = List<Map<String, dynamic>>.from(brandsData['carbrand']);
      }
      if (typesData['cartype'] != null) {
        carTypes.value = List<Map<String, dynamic>>.from(typesData['cartype']);
      }
      if (citiesData['citylist'] != null) {
        cities.value = List<Map<String, dynamic>>.from(citiesData['citylist']);
      }
      if (facilitiesData['Faclist'] != null) {
        facilities.value = List<Map<String, dynamic>>.from(facilitiesData['Faclist']);
      }
    } catch (e) {
      debugPrint('Error loading form data: $e');
    }
  }

  Future<bool> addCar() async {
    if (!validateCarForm()) return false;

    isSaving.value = true;

    try {
      final carData = {
        'company_id': companyId.toString(),
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'rent': rentController.text.trim(),
        'seat': seatController.text.trim(),
        'speed': speedController.text.trim(),
        'brand_id': selectedBrandId.value.toString(),
        'car_type_id': selectedTypeId.value.toString(),
        'city_id': selectedCityId.value.toString(),
        'fueltype': selectedFuelType.value,
        'geartype': selectedGearType.value,
        'facility_ids': selectedFacilities.join(','),
      };

      final result = await _apiService.addCar(
        carData,
        mainImage: mainImage.value,
        exteriorImages: exteriorImages,
        interiorImages: interiorImages,
      );

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Car added successfully",
          backgroundColor: Colors.green,
        );
        clearForm();
        await loadCars();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to add car",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error adding car: $e');
      Fluttertoast.showToast(
        msg: "Error adding car",
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateCar(int carId, {Map<String, dynamic>? additionalData}) async {
    isSaving.value = true;

    try {
      final updates = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'rent': rentController.text.trim(),
        'seat': seatController.text.trim(),
        'speed': speedController.text.trim(),
        'brand_id': selectedBrandId.value.toString(),
        'car_type_id': selectedTypeId.value.toString(),
        'city_id': selectedCityId.value.toString(),
        'fueltype': selectedFuelType.value,
        'geartype': selectedGearType.value,
        'facility_ids': selectedFacilities.join(','),
        ...?additionalData,
      };

      final result = await _apiService.updateCar(carId, updates);

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Car updated successfully",
          backgroundColor: Colors.green,
        );
        await loadCars();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to update car",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error updating car: $e');
      Fluttertoast.showToast(
        msg: "Error updating car",
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> toggleCarStatus(int carId, String currentStatus) async {
    final newStatus = currentStatus == '1' ? '0' : '1';

    try {
      final result = await _apiService.updateCar(carId, {'status': newStatus});

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Car status updated",
          backgroundColor: Colors.green,
        );
        await loadCars();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to update status",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling car status: $e');
      Fluttertoast.showToast(
        msg: "Error updating status",
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  Future<bool> deleteCar(int carId) async {
    try {
      final result = await _apiService.deleteCar(carId);

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Car deleted successfully",
          backgroundColor: Colors.green,
        );
        await loadCars();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to delete car",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting car: $e');
      Fluttertoast.showToast(
        msg: "Error deleting car",
        backgroundColor: Colors.red,
      );
      return false;
    }
  }

  void populateFormForEdit(Map<String, dynamic> car) {
    titleController.text = car['title'] ?? '';
    descriptionController.text = car['description'] ?? '';
    rentController.text = car['rent'] ?? '';
    seatController.text = car['seat'] ?? '';
    speedController.text = car['speed'] ?? '';
    selectedBrandId.value = int.tryParse(car['brand_id']?.toString() ?? '0') ?? 0;
    selectedTypeId.value = int.tryParse(car['car_type_id']?.toString() ?? '0') ?? 0;
    selectedCityId.value = int.tryParse(car['city_id']?.toString() ?? '0') ?? 0;
    selectedFuelType.value = car['fueltype'] ?? '';
    selectedGearType.value = car['geartype'] ?? '';

    if (car['facility_ids'] != null && car['facility_ids'].toString().isNotEmpty) {
      selectedFacilities.value = car['facility_ids']
          .toString()
          .split(',')
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e > 0)
          .toList();
    }
  }

  bool validateCarForm() {
    if (titleController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter car title", backgroundColor: Colors.red);
      return false;
    }
    if (rentController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please enter rent amount", backgroundColor: Colors.red);
      return false;
    }
    if (selectedBrandId.value == 0) {
      Fluttertoast.showToast(msg: "Please select a brand", backgroundColor: Colors.red);
      return false;
    }
    if (selectedTypeId.value == 0) {
      Fluttertoast.showToast(msg: "Please select car type", backgroundColor: Colors.red);
      return false;
    }
    if (selectedCityId.value == 0) {
      Fluttertoast.showToast(msg: "Please select a city", backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    rentController.clear();
    seatController.clear();
    speedController.clear();
    selectedBrandId.value = 0;
    selectedTypeId.value = 0;
    selectedCityId.value = 0;
    selectedFuelType.value = '';
    selectedGearType.value = '';
    selectedFacilities.clear();
    mainImage.value = null;
    exteriorImages.clear();
    interiorImages.clear();
  }

  void setMainImage(File file) {
    mainImage.value = file;
  }

  void addExteriorImage(File file) {
    if (exteriorImages.length < 5) {
      exteriorImages.add(file);
    }
  }

  void removeExteriorImage(int index) {
    if (index >= 0 && index < exteriorImages.length) {
      exteriorImages.removeAt(index);
    }
  }

  void addInteriorImage(File file) {
    if (interiorImages.length < 5) {
      interiorImages.add(file);
    }
  }

  void removeInteriorImage(int index) {
    if (index >= 0 && index < interiorImages.length) {
      interiorImages.removeAt(index);
    }
  }

  void toggleFacility(int facilityId) {
    if (selectedFacilities.contains(facilityId)) {
      selectedFacilities.remove(facilityId);
    } else {
      selectedFacilities.add(facilityId);
    }
  }
}
