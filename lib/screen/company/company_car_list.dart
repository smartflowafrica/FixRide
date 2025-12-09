import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../service/company_api_service.dart';
import 'company_add_car.dart';

class CompanyCarListScreen extends StatefulWidget {
  final int companyId;
  
  const CompanyCarListScreen({super.key, required this.companyId});

  @override
  State<CompanyCarListScreen> createState() => _CompanyCarListScreenState();
}

class _CompanyCarListScreenState extends State<CompanyCarListScreen> with SingleTickerProviderStateMixin {
  final _apiService = CompanyApiService();
  late ColorNotifire notifire;
  late TabController _tabController;
  
  List<dynamic> _allCars = [];
  List<dynamic> _activeCars = [];
  List<dynamic> _inactiveCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCars();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _apiService.getCars(widget.companyId);
      if (data['Result'] == 'true' && data['cars'] != null) {
        final cars = data['cars'] as List;
        setState(() {
          _allCars = cars;
          _activeCars = cars.where((c) => c['status'] == '1').toList();
          _inactiveCars = cars.where((c) => c['status'] != '1').toList();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load cars",
        backgroundColor: Colors.red,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _toggleCarStatus(int carId, String currentStatus) async {
    final newStatus = currentStatus == '1' ? '0' : '1';
    
    try {
      final result = await _apiService.updateCar(carId, {'status': newStatus});
      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Car status updated",
          backgroundColor: Colors.green,
        );
        _loadCars();
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to update",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating car status",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _deleteCar(int carId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Car"),
        content: const Text("Are you sure you want to delete this car? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await _apiService.deleteCar(carId);
        if (result['Result'] == 'true') {
          Fluttertoast.showToast(
            msg: "Car deleted successfully",
            backgroundColor: Colors.green,
          );
          _loadCars();
        } else {
          Fluttertoast.showToast(
            msg: result['ResponseMsg'] ?? "Failed to delete",
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error deleting car",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: Darkblue,
        title: const Text("My Cars"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCars,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "All (${_allCars.length})"),
            Tab(text: "Active (${_activeCars.length})"),
            Tab(text: "Inactive (${_inactiveCars.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCarList(_allCars),
                _buildCarList(_activeCars),
                _buildCarList(_inactiveCars),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => CompanyAddCarScreen(companyId: widget.companyId));
          if (result == true) {
            _loadCars();
          }
        },
        backgroundColor: Darkblue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Car", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCarList(List<dynamic> cars) {
    if (cars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: greyColor),
            const SizedBox(height: 16),
            Text(
              "No cars found",
              style: TextStyle(fontSize: 18, color: greyColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first car to start earning",
              style: TextStyle(fontSize: 14, color: greyColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCars,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cars.length,
        itemBuilder: (context, index) => _buildCarCard(cars[index]),
      ),
    );
  }

  Widget _buildCarCard(dynamic car) {
    final isActive = car['status'] == '1';
    final carImage = car['img'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: carImage.isNotEmpty
                    ? Image.network(
                        carImage,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: greyColor.withOpacity(0.2),
                          child: Icon(Icons.directions_car, size: 48, color: greyColor),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: greyColor.withOpacity(0.2),
                        child: Icon(Icons.directions_car, size: 48, color: greyColor),
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? "Active" : "Inactive",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          
          // Car Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        car['title'] ?? 'Untitled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: notifire.getdarkscolor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "₦${car['rent'] ?? '0'}/day",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Darkblue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCarSpec(Icons.airline_seat_recline_normal, "${car['seat'] ?? 0} seats"),
                    const SizedBox(width: 16),
                    _buildCarSpec(Icons.local_gas_station, car['fueltype'] ?? 'N/A'),
                    const SizedBox(width: 16),
                    _buildCarSpec(Icons.settings, car['geartype'] ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      Icons.edit,
                      "Edit",
                      Colors.blue,
                      () async {
                        final result = await Get.to(() => CompanyAddCarScreen(
                          companyId: widget.companyId,
                          car: car,
                        ));
                        if (result == true) {
                          _loadCars();
                        }
                      },
                    ),
                    _buildActionButton(
                      isActive ? Icons.visibility_off : Icons.visibility,
                      isActive ? "Deactivate" : "Activate",
                      isActive ? Colors.orange : Colors.green,
                      () => _toggleCarStatus(int.parse(car['id'].toString()), car['status']),
                    ),
                    _buildActionButton(
                      Icons.delete,
                      "Delete",
                      Colors.red,
                      () => _deleteCar(int.parse(car['id'].toString())),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: greyColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: greyColor)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
