import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/payout_model.dart';
import '../service/company_api_service.dart';

class CompanyPayoutController extends GetxController {
  static CompanyPayoutController get to => Get.find();

  final CompanyApiService _apiService = CompanyApiService();

  // Wallet data
  final Rx<CompanyWallet?> wallet = Rx<CompanyWallet?>(null);

  // Transactions
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;

  // Payouts
  final RxList<Payout> payouts = <Payout>[].obs;
  final RxList<Payout> pendingPayouts = <Payout>[].obs;
  final RxList<Payout> completedPayouts = <Payout>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRequesting = false.obs;

  // Form controller
  final amountController = TextEditingController();

  int companyId = 0;

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void setCompanyId(int id) {
    companyId = id;
  }

  Future<void> loadWalletData() async {
    if (companyId == 0) return;

    isLoading.value = true;

    try {
      final walletData = await _apiService.getWallet(companyId);
      if (walletData['Result'] == 'true' && walletData['wallet'] != null) {
        wallet.value = CompanyWallet.fromJson(walletData['wallet']);

        if (walletData['transactions'] != null) {
          transactions.value = (walletData['transactions'] as List)
              .map((t) => WalletTransaction.fromJson(t))
              .toList();
        }
      }

      final payoutData = await _apiService.getPayoutHistory(companyId);
      if (payoutData['Result'] == 'true' && payoutData['payouts'] != null) {
        final allPayouts = (payoutData['payouts'] as List)
            .map((p) => Payout.fromJson(p))
            .toList();

        payouts.value = allPayouts;
        pendingPayouts.value = allPayouts.where((p) => p.isPending || p.isProcessing).toList();
        completedPayouts.value = allPayouts.where((p) => p.isCompleted).toList();
      }
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
      Fluttertoast.showToast(
        msg: "Failed to load wallet data",
        backgroundColor: Colors.red,
      );
    }

    isLoading.value = false;
  }

  Future<void> refreshData() async {
    await loadWalletData();
  }

  Future<bool> requestPayout({
    required double amount,
    String paymentMethod = 'bank_transfer',
    String? bankName,
    String? accountNumber,
    String? accountName,
  }) async {
    if (amount <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid amount",
        backgroundColor: Colors.red,
      );
      return false;
    }

    if (wallet.value == null || amount > wallet.value!.availableBalance) {
      Fluttertoast.showToast(
        msg: "Insufficient balance",
        backgroundColor: Colors.red,
      );
      return false;
    }

    isRequesting.value = true;

    try {
      final result = await _apiService.requestPayout(companyId, amount);

      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Payout request submitted",
          backgroundColor: Colors.green,
        );
        amountController.clear();
        await loadWalletData();
        return true;
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to request payout",
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting payout: $e');
      Fluttertoast.showToast(
        msg: "Error requesting payout",
        backgroundColor: Colors.red,
      );
      return false;
    } finally {
      isRequesting.value = false;
    }
  }

  Future<bool> requestPayoutFromForm() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null) {
      Fluttertoast.showToast(
        msg: "Please enter a valid amount",
        backgroundColor: Colors.red,
      );
      return false;
    }
    return requestPayout(amount: amount);
  }

  void setQuickAmount(double amount) {
    amountController.text = amount.toStringAsFixed(0);
  }

  void setMaxAmount() {
    if (wallet.value != null) {
      amountController.text = wallet.value!.availableBalance.toStringAsFixed(0);
    }
  }

  // Getters
  double get availableBalance => wallet.value?.availableBalance ?? 0;
  double get totalEarnings => wallet.value?.totalEarnings ?? 0;
  double get totalWithdrawn => wallet.value?.totalWithdrawn ?? 0;
  double get pendingAmount => wallet.value?.pendingAmount ?? 0;

  String get formattedAvailableBalance => _formatCurrency(availableBalance);
  String get formattedTotalEarnings => _formatCurrency(totalEarnings);
  String get formattedTotalWithdrawn => _formatCurrency(totalWithdrawn);
  String get formattedPendingAmount => _formatCurrency(pendingAmount);

  bool canWithdraw(double amount) {
    return wallet.value?.canWithdraw(amount) ?? false;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₦${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₦${amount.toStringAsFixed(0)}';
  }
}
