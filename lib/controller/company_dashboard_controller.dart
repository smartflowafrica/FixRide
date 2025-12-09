import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/company_model.dart';
import '../model/company_stats_model.dart';
import '../service/company_api_service.dart';

class CompanyDashboardController extends GetxController {
  static CompanyDashboardController get to => Get.find();

  final CompanyApiService _apiService = CompanyApiService();

  // Company data
  final Rx<Company?> company = Rx<Company?>(null);
  final Rx<CompanyDashboardStats> stats = Rx<CompanyDashboardStats>(CompanyDashboardStats.empty());

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Recent bookings
  final RxList<Map<String, dynamic>> recentBookings = <Map<String, dynamic>>[].obs;

  // Notifications
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxInt unreadNotifications = 0.obs;

  int get companyId => company.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
  }

  void setCompany(Company comp) {
    company.value = comp;
    loadDashboard();
    loadNotifications();
  }

  Future<void> loadDashboard() async {
    if (companyId == 0) return;

    isLoading.value = true;

    try {
      final dashboardStats = await _apiService.getDashboard(companyId);
      stats.value = dashboardStats;

      // Load recent bookings
      final bookingsData = await _apiService.getBookings(companyId);
      if (bookingsData['Result'] == 'true' && bookingsData['bookings'] != null) {
        recentBookings.value = List<Map<String, dynamic>>.from(
          (bookingsData['bookings'] as List).take(5),
        );
      }
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      Fluttertoast.showToast(
        msg: "Failed to load dashboard",
        backgroundColor: Colors.red,
      );
    }

    isLoading.value = false;
  }

  Future<void> refreshDashboard() async {
    if (companyId == 0) return;

    isRefreshing.value = true;

    try {
      final dashboardStats = await _apiService.getDashboard(companyId);
      stats.value = dashboardStats;

      final bookingsData = await _apiService.getBookings(companyId);
      if (bookingsData['Result'] == 'true' && bookingsData['bookings'] != null) {
        recentBookings.value = List<Map<String, dynamic>>.from(
          (bookingsData['bookings'] as List).take(5),
        );
      }

      await loadNotifications();
    } catch (e) {
      debugPrint('Error refreshing dashboard: $e');
    }

    isRefreshing.value = false;
  }

  Future<void> loadNotifications() async {
    if (companyId == 0) return;

    try {
      final result = await _apiService.getNotifications(companyId);
      if (result['Result'] == 'true' && result['notifications'] != null) {
        notifications.value = List<Map<String, dynamic>>.from(result['notifications']);
        unreadNotifications.value = notifications.where((n) => n['is_read'] != '1').length;
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await _apiService.markNotificationRead(companyId, notificationId: notificationId);
      
      // Update local state
      final index = notifications.indexWhere((n) => n['id'].toString() == notificationId.toString());
      if (index != -1) {
        notifications[index]['is_read'] = '1';
        notifications.refresh();
        unreadNotifications.value = notifications.where((n) => n['is_read'] != '1').length;
      }
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _apiService.markNotificationRead(companyId);
      
      // Update local state
      for (var n in notifications) {
        n['is_read'] = '1';
      }
      notifications.refresh();
      unreadNotifications.value = 0;
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }

  // Quick stats getters
  int get totalCars => stats.value.totalCars;
  int get activeCars => stats.value.activeCars;
  int get pendingBookings => stats.value.pendingBookings;
  int get completedBookings => stats.value.completedBookings;
  double get availableBalance => stats.value.availableBalance;
  double get thisMonthEarnings => stats.value.thisMonthEarnings;
  double get commissionRate => stats.value.commissionRate;

  String get formattedBalance => stats.value.formattedAvailableBalance;
  String get formattedMonthEarnings => stats.value.formattedMonthEarnings;
}
