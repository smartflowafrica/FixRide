import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';
import '../../model/company_models.dart';
import '../../service/company_api_service.dart';

class CompanyEarningsScreen extends StatefulWidget {
  final int companyId;
  
  const CompanyEarningsScreen({super.key, required this.companyId});

  @override
  State<CompanyEarningsScreen> createState() => _CompanyEarningsScreenState();
}

class _CompanyEarningsScreenState extends State<CompanyEarningsScreen> with SingleTickerProviderStateMixin {
  final _apiService = CompanyApiService();
  late ColorNotifire notifire;
  late TabController _tabController;
  
  CompanyWallet? _wallet;
  List<WalletTransaction> _transactions = [];
  List<CompanyPayout> _payouts = [];
  bool _isLoading = true;
  bool _isRequesting = false;

  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final walletData = await _apiService.getWallet(widget.companyId);
      final payoutData = await _apiService.getPayoutHistory(widget.companyId);
      
      setState(() {
        if (walletData['Result'] == 'true') {
          _wallet = CompanyWallet.fromJson(walletData['wallet']);
          if (walletData['transactions'] != null) {
            _transactions = (walletData['transactions'] as List)
                .map((t) => WalletTransaction.fromJson(t))
                .toList();
          }
        }
        
        if (payoutData['Result'] == 'true' && payoutData['payouts'] != null) {
          _payouts = (payoutData['payouts'] as List)
              .map((p) => CompanyPayout.fromJson(p))
              .toList();
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load data",
        backgroundColor: Colors.red,
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _requestPayout() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid amount",
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_wallet == null || amount > _wallet!.availableBalance) {
      Fluttertoast.showToast(
        msg: "Insufficient balance",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isRequesting = true);

    try {
      final result = await _apiService.requestPayout(widget.companyId, amount);
      if (result['Result'] == 'true') {
        Fluttertoast.showToast(
          msg: "Payout request submitted",
          backgroundColor: Colors.green,
        );
        _amountController.clear();
        Navigator.pop(context);
        _loadData();
      } else {
        Fluttertoast.showToast(
          msg: result['ResponseMsg'] ?? "Failed to request payout",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error requesting payout",
        backgroundColor: Colors.red,
      );
    }

    setState(() => _isRequesting = false);
  }

  void _showPayoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: notifire.getbgcolor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Request Payout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: notifire.getdarkscolor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Available: ₦${_wallet?.availableBalance.toStringAsFixed(0) ?? '0'}",
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: notifire.getdarkscolor),
              decoration: InputDecoration(
                labelText: "Amount (₦)",
                labelStyle: TextStyle(color: greyColor),
                prefixIcon: Icon(Icons.attach_money, color: Darkblue),
                filled: true,
                fillColor: notifire.getbgcolor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [5000, 10000, 20000, 50000].map((amount) {
                return ActionChip(
                  label: Text("₦$amount"),
                  onPressed: () {
                    _amountController.text = amount.toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRequesting ? null : _requestPayout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Darkblue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isRequesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Request Payout", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: Darkblue,
        title: const Text("Earnings & Payouts"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Transactions"),
            Tab(text: "Payouts"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWalletCard(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionsList(),
                      _buildPayoutsList(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPayoutDialog,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
        label: const Text("Withdraw", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Balance",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₦${_wallet?.availableBalance.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWalletStat(
                  "Total Earnings",
                  "₦${_wallet?.totalEarnings.toStringAsFixed(0) ?? '0'}",
                  Icons.trending_up,
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white30),
              Expanded(
                child: _buildWalletStat(
                  "Withdrawn",
                  "₦${_wallet?.totalWithdrawn.toStringAsFixed(0) ?? '0'}",
                  Icons.payments,
                ),
              ),
              Container(height: 40, width: 1, color: Colors.white30),
              Expanded(
                child: _buildWalletStat(
                  "Pending",
                  "₦${_wallet?.pendingAmount.toStringAsFixed(0) ?? '0'}",
                  Icons.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: greyColor),
            const SizedBox(height: 16),
            Text("No transactions yet", style: TextStyle(color: greyColor)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final txn = _transactions[index];
          final isCredit = txn.type == 'credit';
          
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isCredit ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: notifire.getdarkscolor,
                        ),
                      ),
                      Text(
                        txn.date,
                        style: TextStyle(fontSize: 12, color: greyColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isCredit ? '+' : '-'}₦${txn.amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayoutsList() {
    if (_payouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments, size: 64, color: greyColor),
            const SizedBox(height: 16),
            Text("No payout requests yet", style: TextStyle(color: greyColor)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payouts.length,
        itemBuilder: (context, index) {
          final payout = _payouts[index];
          
          Color statusColor;
          switch (payout.status) {
            case 'Completed':
              statusColor = Colors.green;
              break;
            case 'Pending':
              statusColor = Colors.orange;
              break;
            case 'Rejected':
              statusColor = Colors.red;
              break;
            default:
              statusColor = greyColor;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notifire.getbgcolor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: greyColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₦${payout.amount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: notifire.getdarkscolor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        payout.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: greyColor),
                    const SizedBox(width: 4),
                    Text(
                      "Requested: ${payout.requestedDate}",
                      style: TextStyle(color: greyColor, fontSize: 12),
                    ),
                  ],
                ),
                if (payout.processedDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: greyColor),
                      const SizedBox(width: 4),
                      Text(
                        "Processed: ${payout.processedDate}",
                        style: TextStyle(color: greyColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
                if (payout.remarks != null && payout.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    payout.remarks!,
                    style: TextStyle(
                      color: notifire.getdarkscolor,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
