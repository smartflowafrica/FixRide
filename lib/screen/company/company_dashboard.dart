import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../model/company_models.dart';
import '../../service/company_api_service.dart';
import 'company_login.dart';
import 'company_car_list.dart';
import 'company_booking_list.dart';
import 'company_earnings.dart';
import 'company_profile.dart';

class CompanyDashboardScreen extends StatefulWidget {
  final Company company;
  
  const CompanyDashboardScreen({super.key, required this.company});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  final _apiService = CompanyApiService();
  late ColorNotifire notifire;
  
  CompanyDashboardStats? _stats;
  List<CompanyBooking> _recentBookings = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    
    try {
      final stats = await _apiService.getDashboard(widget.company.id);
      final bookingsData = await _apiService.getBookings(widget.company.id);
      
      setState(() {
        _stats = stats;
        if (bookingsData['Result'] == 'true' && bookingsData['bookings'] != null) {
          _recentBookings = (bookingsData['bookings'] as List)
              .take(5)
              .map((b) => CompanyBooking.fromJson(b))
              .toList();
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load dashboard",
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
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildRecentBookings(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Darkblue,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: widget.company.logo != null
                ? ClipOval(
                    child: Image.network(
                      widget.company.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        widget.company.companyName[0].toUpperCase(),
                        style: TextStyle(color: Darkblue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Text(
                    widget.company.companyName[0].toUpperCase(),
                    style: TextStyle(color: Darkblue, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.company.companyName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (widget.company.isVerified)
                      const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                    Text(
                      widget.company.isVerified ? " Verified" : widget.company.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Darkblue, Darkblue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Balance",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_stats?.commissionRate ?? 15}% commission",
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "₦${_formatNumber(_stats?.availableBalance ?? 0)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBalanceItem("This Month", "₦${_formatNumber(_stats?.thisMonthEarnings ?? 0)}"),
              const SizedBox(width: 24),
              _buildBalanceItem("Pending", "₦${_formatNumber(_stats?.pendingPayouts ?? 0)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Cars", "${_stats?.totalCars ?? 0}", Icons.directions_car, Colors.blue),
        _buildStatCard("Active Cars", "${_stats?.activeCars ?? 0}", Icons.check_circle, Colors.green),
        _buildStatCard("Pending Bookings", "${_stats?.pendingBookings ?? 0}", Icons.pending, Colors.orange),
        _buildStatCard("Completed", "${_stats?.completedBookings ?? 0}", Icons.done_all, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: notifire.getdarkscolor,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: greyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: notifire.getdarkscolor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Add Car",
                Icons.add_circle,
                () => Get.to(() => CompanyCarListScreen(companyId: widget.company.id)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "Withdraw",
                Icons.account_balance_wallet,
                () => Get.to(() => CompanyEarningsScreen(companyId: widget.company.id)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "View All",
                Icons.list_alt,
                () => Get.to(() => CompanyBookingListScreen(companyId: widget.company.id)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Darkblue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Darkblue, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: notifire.getdarkscolor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Bookings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: notifire.getdarkscolor,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => CompanyBookingListScreen(companyId: widget.company.id)),
              child: Text("See All", style: TextStyle(color: Darkblue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.inbox, size: 48, color: greyColor),
                const SizedBox(height: 8),
                Text("No bookings yet", style: TextStyle(color: greyColor)),
              ],
            ),
          )
        else
          ...List.generate(_recentBookings.length, (index) {
            final booking = _recentBookings[index];
            return _buildBookingItem(booking);
          }),
      ],
    );
  }

  Widget _buildBookingItem(CompanyBooking booking) {
    Color statusColor;
    switch (booking.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Pick_Up':
        statusColor = Colors.blue;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = greyColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifire.getbgcolor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Darkblue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.directions_car, color: Darkblue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.carTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: notifire.getdarkscolor,
                  ),
                ),
                Text(
                  booking.customerName,
                  style: TextStyle(fontSize: 12, color: greyColor),
                ),
                Text(
                  booking.pickupDate,
                  style: TextStyle(fontSize: 11, color: greyColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "₦${_formatNumber(booking.companyEarning)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Get.to(() => CompanyCarListScreen(companyId: widget.company.id));
            break;
          case 2:
            Get.to(() => CompanyBookingListScreen(companyId: widget.company.id));
            break;
          case 3:
            Get.to(() => CompanyEarningsScreen(companyId: widget.company.id));
            break;
          case 4:
            Get.to(() => CompanyProfileScreen(company: widget.company));
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: notifire.getbgcolor,
      selectedItemColor: Darkblue,
      unselectedItemColor: greyColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Cars'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}
