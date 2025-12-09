import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../model/company_models.dart';
import '../../service/company_api_service.dart';

class CompanyBookingListScreen extends StatefulWidget {
  final int companyId;
  
  const CompanyBookingListScreen({super.key, required this.companyId});

  @override
  State<CompanyBookingListScreen> createState() => _CompanyBookingListScreenState();
}

class _CompanyBookingListScreenState extends State<CompanyBookingListScreen> with SingleTickerProviderStateMixin {
  final _apiService = CompanyApiService();
  late ColorNotifire notifire;
  late TabController _tabController;
  
  List<CompanyBooking> _allBookings = [];
  List<CompanyBooking> _pendingBookings = [];
  List<CompanyBooking> _activeBookings = [];
  List<CompanyBooking> _completedBookings = [];
  List<CompanyBooking> _cancelledBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _apiService.getBookings(widget.companyId);
      if (data['Result'] == 'true' && data['bookings'] != null) {
        final bookings = (data['bookings'] as List)
            .map((b) => CompanyBooking.fromJson(b))
            .toList();
        
        setState(() {
          _allBookings = bookings;
          _pendingBookings = bookings.where((b) => b.status == 'Pending').toList();
          _activeBookings = bookings.where((b) => b.status == 'Pick_Up' || b.status == 'On_Trip').toList();
          _completedBookings = bookings.where((b) => b.status == 'Completed').toList();
          _cancelledBookings = bookings.where((b) => b.status == 'Cancelled').toList();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load bookings",
        backgroundColor: Colors.red,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _updateBookingStatus(int bookingId, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Status"),
        content: Text("Change booking status to ${newStatus.replaceAll('_', ' ')}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Darkblue),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final result = await _apiService.updateBookingStatus(bookingId, newStatus);
        if (result['Result'] == 'true') {
          Fluttertoast.showToast(
            msg: "Status updated successfully",
            backgroundColor: Colors.green,
          );
          _loadBookings();
        } else {
          Fluttertoast.showToast(
            msg: result['ResponseMsg'] ?? "Failed to update",
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error updating status",
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
        title: const Text("Bookings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "All (${_allBookings.length})"),
            Tab(text: "Pending (${_pendingBookings.length})"),
            Tab(text: "Active (${_activeBookings.length})"),
            Tab(text: "Completed (${_completedBookings.length})"),
            Tab(text: "Cancelled (${_cancelledBookings.length})"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(_allBookings),
                _buildBookingList(_pendingBookings),
                _buildBookingList(_activeBookings),
                _buildBookingList(_completedBookings),
                _buildBookingList(_cancelledBookings),
              ],
            ),
    );
  }

  Widget _buildBookingList(List<CompanyBooking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: greyColor),
            const SizedBox(height: 16),
            Text(
              "No bookings found",
              style: TextStyle(fontSize: 18, color: greyColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(CompanyBooking booking) {
    Color statusColor;
    switch (booking.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Pick_Up':
      case 'On_Trip':
        statusColor = Colors.blue;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = greyColor;
    }

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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Darkblue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking #${booking.id}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: notifire.getdarkscolor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    booking.status.replaceAll('_', ' '),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Car Info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Darkblue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.directions_car, color: Darkblue, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.carTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: notifire.getdarkscolor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: greyColor),
                              const SizedBox(width: 4),
                              Text(
                                booking.customerName,
                                style: TextStyle(color: greyColor, fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: greyColor),
                              const SizedBox(width: 4),
                              Text(
                                booking.customerPhone,
                                style: TextStyle(color: greyColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Date Info
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInfo("Pick Up", booking.pickupDate, Icons.login),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: greyColor.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildDateInfo("Return", booking.returnDate, Icons.logout),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                // Earnings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Amount", style: TextStyle(color: greyColor, fontSize: 12)),
                        Text(
                          "₦${booking.totalAmount.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 16,
                            color: notifire.getdarkscolor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Your Earning", style: TextStyle(color: greyColor, fontSize: 12)),
                        Text(
                          "₦${booking.companyEarning.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          if (booking.status == 'Pending' || booking.status == 'Pick_Up')
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  if (booking.status == 'Pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateBookingStatus(booking.id, 'Cancelled'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateBookingStatus(booking.id, 'Pick_Up'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                  if (booking.status == 'Pick_Up')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateBookingStatus(booking.id, 'Completed'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text("Mark Completed", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String date, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Darkblue),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: greyColor, fontSize: 11)),
        Text(
          date,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: notifire.getdarkscolor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
