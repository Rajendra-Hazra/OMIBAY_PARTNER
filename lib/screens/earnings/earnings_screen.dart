import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

import 'package:intl/intl.dart';
import '../../services/wallet_service.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  double _walletBalance = 0.0;
  double _totalEarnings = 0.0;
  double _totalTips = 0.0;
  int _totalJobsDone = 0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  bool _bankAccountAdded = false;
  bool _upiIdAdded = false;
  int? _selectedBarIndex;
  String _selectedMonth = '';
  final TextEditingController _amountController = TextEditingController();

  Map<String, List<double>> _monthlyData = {};

  @override
  void initState() {
    super.initState();
    // Initialize with a default, will be updated in didChangeDependencies
    _selectedMonth = 'Jan 2026';
    // Listen for updates
    AppColors.jobUpdateNotifier.addListener(_loadData);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_monthlyData.isEmpty) {
      _selectedMonth = '${l10n.monthJan} 2026';
      _monthlyData = {
        '${l10n.monthAug} 2025': List.filled(31, 0.0),
        '${l10n.monthSep} 2025': List.filled(30, 0.0),
        '${l10n.monthOct} 2025': List.filled(31, 0.0),
        '${l10n.monthNov} 2025': List.filled(30, 0.0),
        '${l10n.monthDec} 2025': List.filled(31, 0.0),
        '${l10n.monthJan} 2026': List.filled(31, 0.0),
      };
    }
    _loadData();
  }

  @override
  void dispose() {
    AppColors.jobUpdateNotifier.removeListener(_loadData);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // We'll calculate these from the list to ensure manual transactions don't affect them
    double calculatedEarnings = 0.0;
    double calculatedTips = 0.0;
    int calculatedJobs = 0;

    final double balance = prefs.getDouble('wallet_balance') ?? 0.0;

    // Check for saved payment methods by reading the JSON arrays
    final String bankJson = prefs.getString('saved_bank_accounts') ?? '[]';
    final String upiJson = prefs.getString('saved_upi_ids') ?? '[]';

    final bool bankAdded = (jsonDecode(bankJson) as List).isNotEmpty;
    final bool upiAdded = (jsonDecode(upiJson) as List).isNotEmpty;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    // Load completed jobs for transaction history
    final List<String> completedList =
        prefs.getStringList('completed_jobs_list') ?? [];

    // Reset monthly data before populating
    _monthlyData.forEach((key, value) => value.fillRange(0, value.length, 0.0));

    final List<Map<String, dynamic>> transactionData = completedList.map((
      item,
    ) {
      final data = jsonDecode(item) as Map<String, dynamic>;
      final title = data['title']?.toString() ?? '';
      final bool isJob = title.startsWith('Job:') || title.startsWith('কাজ:');

      // Update stats and monthly data ONLY for actual jobs, exclude manual withdrawals/payments
      if (isJob) {
        final double earnings =
            double.tryParse(data['partnerEarning']?.toString() ?? '0') ?? 0.0;
        final double tips =
            double.tryParse(data['tipAmount']?.toString() ?? '0') ?? 0.0;

        calculatedEarnings += earnings;
        calculatedTips += tips;
        calculatedJobs++;

        if (data['date'] != null) {
          try {
            final date = DateTime.parse(data['date']);
            final String monthKey = _getLocalizedMonthYear(date);
            if (_monthlyData.containsKey(monthKey)) {
              final dayIndex = date.day - 1;
              if (dayIndex >= 0 && dayIndex < _monthlyData[monthKey]!.length) {
                _monthlyData[monthKey]![dayIndex] += earnings;
              }
            }
          } catch (_) {}
        }
      }

      String timeDisplay = l10n.justNow;
      if (data['date'] != null) {
        try {
          final date = DateTime.parse(data['date']);
          final locale = Localizations.localeOf(context).toString();
          timeDisplay = LocalizationHelper.convertBengaliToEnglish(
            DateFormat('dd MMM, hh:mm a', locale).format(date),
          );
        } catch (_) {}
      }

      return {
        ...data,
        'title':
            data['title'] ??
            l10n.jobWithService(data['service'] ?? l10n.unknown),
        'subtitle': data['subtitle'] ?? data['customer'] ?? l10n.unknown,
        'amount':
            data['amount'] ?? '+${l10n.currencySymbol}${data['price'] ?? '0'}',
        'isCredit': data['isCredit'] ?? (data['type'] == 'Credit'),
        'time': timeDisplay,
        'paymentMode':
            data['paymentMode'] ??
            (data['isCredit'] == true ? l10n.online : l10n.cash),
        'isJob': isJob,
      };
    }).toList();

    if (mounted) {
      setState(() {
        _totalEarnings = calculatedEarnings;
        _totalTips = calculatedTips;
        _totalJobsDone = calculatedJobs;
        _walletBalance = balance;
        _bankAccountAdded = bankAdded;
        _upiIdAdded = upiAdded;
        _transactions = transactionData;
        _isLoading = false;
      });
    }
  }

  String _getLocalizedMonthYear(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    String monthName;
    switch (date.month) {
      case 1:
        monthName = l10n.monthJan;
        break;
      case 2:
        monthName = l10n.monthFeb;
        break;
      case 3:
        monthName = l10n.monthMar;
        break;
      case 4:
        monthName = l10n.monthApr;
        break;
      case 5:
        monthName = l10n.monthMay;
        break;
      case 6:
        monthName = l10n.monthJun;
        break;
      case 7:
        monthName = l10n.monthJul;
        break;
      case 8:
        monthName = l10n.monthAug;
        break;
      case 9:
        monthName = l10n.monthSep;
        break;
      case 10:
        monthName = l10n.monthOct;
        break;
      case 11:
        monthName = l10n.monthNov;
        break;
      case 12:
        monthName = l10n.monthDec;
        break;
      default:
        monthName = '';
    }
    return '$monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrangeStart),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryOrangeStart,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                _buildWalletHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(l10n.earnings),
                      _buildPerformanceGrid(),
                      const SizedBox(height: 24),
                      _buildMonthlyEarningsChart(),
                      const SizedBox(height: 24),
                      _buildSectionTitle(l10n.incentivesAndOffers),
                      _buildBonusCard(),
                      const SizedBox(height: 16),
                      _buildReferCard(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildSectionTitle(l10n.transactionHistory),
                          const Spacer(),
                          if (_transactions.isNotEmpty) ...[
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/withdrawal-history',
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.viewAll,
                              ),
                            ),
                          ],
                        ],
                      ),
                      _buildTransactionList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.earnings,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWalletHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.availableBalance,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_walletBalance.toStringAsFixed(2))}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (_walletBalance < 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPayNowDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(l10n.payNow),
              ),
            )
          else if (_walletBalance > 0)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context, 'Bank'),
                    icon: const Icon(Icons.account_balance, size: 18),
                    label: Text(AppLocalizations.of(context)!.bankTransfer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context, 'UPI'),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: Text(AppLocalizations.of(context)!.upiWithdraw),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrangeStart,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context)!;
    final String localizedMethod = method == 'Bank'
        ? l10n.bankTransfer
        : l10n.upiWithdraw;

    // Validation for Bank/UPI details
    if (method == 'Bank' && !_bankAccountAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addBankAccountDetails),
          action: SnackBarAction(
            label: l10n.add,
            onPressed: () => Navigator.pushNamed(
              context,
              '/payment-setup',
            ).then((_) => _loadData()),
          ),
        ),
      );
      return;
    }
    if (method == 'UPI' && !_upiIdAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addUpiId),
          action: SnackBarAction(
            label: l10n.add,
            onPressed: () => Navigator.pushNamed(
              context,
              '/payment-setup',
            ).then((_) => _loadData()),
          ),
        ),
      );
      return;
    }

    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.withdrawVia(localizedMethod)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.enterAmountToWithdraw),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [EnglishDigitFormatter()],
                decoration: InputDecoration(
                  prefixText: '${l10n.currencySymbol} ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.availableBalanceWithAmount(
                  LocalizationHelper.convertBengaliToEnglish(
                    _walletBalance.toStringAsFixed(2),
                  ),
                ),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final double amount =
                  double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0 || amount > _walletBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidAmountOrInsufficientBalance),
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Record Withdrawal Transaction
              await WalletService.recordManualTransaction(
                title: l10n.withdrawalWithMethod(localizedMethod),
                titleKey: 'withdrawalWithMethod',
                methodKey: method == 'Bank' ? 'bankTransfer' : 'upiWithdraw',
                amount: amount,
                isCredit: false,
                subtitle: l10n.transferToPersonalAccount,
                subtitleKey: 'transferToPersonalAccount',
                paymentMode: 'ONLINE',
                customerName: l10n.personalAccount,
                serviceName: l10n.withdrawal,
              );

              // Update local state
              _loadData();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.withdrawalProcessed)),
                );
              }
            },
            child: Text(l10n.withdraw),
          ),
        ],
      ),
    );
  }

  void _showPayNowDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _amountController.clear();
    // Default to paying the due amount if balance is negative
    if (_walletBalance < 0) {
      _amountController.text = LocalizationHelper.convertBengaliToEnglish(
        (_walletBalance * -1).toStringAsFixed(2),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.payNow),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.enterAmountToAddOrPay),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [EnglishDigitFormatter()],
                decoration: InputDecoration(
                  prefixText: '${l10n.currencySymbol} ',
                  hintText: '0.00',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.quickAmounts,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ActionChip(
                    label: Text('${l10n.currencySymbol}${l10n.quickAmount1}'),
                    onPressed: () {
                      _amountController.text = l10n.quickAmount1;
                    },
                  ),
                  ActionChip(
                    label: Text('${l10n.currencySymbol}${l10n.quickAmount2}'),
                    onPressed: () {
                      _amountController.text = l10n.quickAmount2;
                    },
                  ),
                  ActionChip(
                    label: Text('${l10n.currencySymbol}${l10n.quickAmount3}'),
                    onPressed: () {
                      _amountController.text = l10n.quickAmount3;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final double amount =
                  double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.invalidAmount)));
                return;
              }

              Navigator.pop(context);

              // Record Payment Transaction (Partner pays OmiBay)
              // This is a CREDIT to the wallet (increases balance)
              await WalletService.recordManualTransaction(
                title: l10n.dueAmountPaid,
                titleKey: 'dueAmountPaid',
                amount: amount,
                isCredit: true,
                subtitle: l10n.paymentForPlatformFees,
                subtitleKey: 'paymentForPlatformFees',
              );

              // Update local state
              _loadData();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.paymentProcessedSuccessfully)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeStart,
            ),
            child: Text(l10n.proceedToPay),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetric(
            l10n.earnings,
            '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_totalEarnings.toStringAsFixed(0))}',
            Colors.green,
          ),
          _buildDivider(),
          _buildMetric(
            l10n.tips,
            '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_totalTips.toStringAsFixed(0))}',
            Colors.orange,
          ),
          _buildDivider(),
          _buildMetric(
            l10n.orders,
            LocalizationHelper.convertBengaliToEnglish(_totalJobsDone),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyEarningsChart() {
    final l10n = AppLocalizations.of(context)!;
    final List<double> dailyEarnings = _monthlyData[_selectedMonth] ?? [];

    double totalMonthlyEarnings = dailyEarnings.isEmpty
        ? 0
        : dailyEarnings.reduce((a, b) => a + b);
    double maxEarnings =
        dailyEarnings.isEmpty || dailyEarnings.every((e) => e == 0)
        ? 1
        : dailyEarnings.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkNavyStart,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavyStart.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBarIndex == null
                        ? LocalizationHelper.convertBengaliToEnglish(
                            '${l10n.currencySymbol}${totalMonthlyEarnings.toStringAsFixed(0)}',
                          )
                        : LocalizationHelper.convertBengaliToEnglish(
                            '${l10n.currencySymbol}${dailyEarnings[_selectedBarIndex!].toStringAsFixed(0)}',
                          ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedBarIndex == null
                        ? l10n.totalForMonth(_selectedMonth)
                        : l10n.earningsForMonthAndDay(
                            _selectedMonth.split(' ')[0],
                            (_selectedBarIndex! + 1).toString(),
                          ),
                    style: const TextStyle(
                      color: AppColors.primaryOrangeStart,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (month) {
                  setState(() {
                    _selectedMonth = month;
                    _selectedBarIndex = null;
                  });
                },
                itemBuilder: (context) {
                  return _monthlyData.keys.map((month) {
                    return PopupMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedMonth,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(dailyEarnings.length, (index) {
                final amount = dailyEarnings[index];
                double heightFactor = amount / maxEarnings;
                bool isSelected = _selectedBarIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBarIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Tooltip(
                        message: LocalizationHelper.convertBengaliToEnglish(
                          '${l10n.dayLabel((index + 1).toString())}: ${l10n.currencySymbol}${amount.toStringAsFixed(0)}',
                        ),
                        child: Container(
                          height: (150 * heightFactor).clamp(4.0, 150.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isSelected
                                    ? Colors.white
                                    : AppColors.primaryOrangeStart,
                                isSelected
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.primaryOrangeStart.withValues(
                                        alpha: 0.3,
                                      ),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 ${_selectedMonth.split(' ')[0]}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                '15 ${_selectedMonth.split(' ')[0]}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                '${dailyEarnings.length} ${_selectedMonth.split(' ')[0]}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: AppColors.border);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBonusCard() {
    final l10n = AppLocalizations.of(context)!;
    double progress = (_totalJobsDone / 15).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyBonusChallenge,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n.weeklyBonusSubtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgStart,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryOrangeStart,
              ),
              minHeight: 8,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.jobsDoneWithProgress(
                    LocalizationHelper.convertBengaliToEnglish(_totalJobsDone),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  l10n.potentialEarnings(
                    LocalizationHelper.convertBengaliToEnglish(
                      (progress * 500).toStringAsFixed(0),
                    ),
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferCard() {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.referAndEarnWithAmount('200'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.referSubtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/referral');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  minimumSize: const Size(80, 36),
                ),
                child: Text(l10n.invite),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final l10n = AppLocalizations.of(context)!;
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactionsYet,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (_, index) {
        final tx = _transactions[index];
        final bool isCredit = tx['isCredit'] ?? false;
        final String paymentMode = tx['paymentMode'] ?? 'ONLINE';
        final bool isJob = tx['isJob'] ?? false;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              // Green tick for credits (completed work), red minus for debits
              isCredit
                  ? Icons.check_circle_rounded
                  : Icons.remove_circle_rounded,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            LocalizationHelper.getTransactionTitle(context, tx),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationHelper.getTransactionSubtitle(context, tx),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(tx['time'] ?? ''),
              if (isJob) ...[
                const SizedBox(height: 2),
                // Payment method badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: paymentMode == 'ONLINE' || paymentMode == 'Online'
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    paymentMode == 'ONLINE' || paymentMode == 'Online'
                        ? l10n.onlinePayment
                        : l10n.cash,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: paymentMode == 'ONLINE' || paymentMode == 'Online'
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['amount'] ?? '₹0.00',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              if (isJob)
                Text(
                  isCredit ? l10n.processed : l10n.deducted,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/transaction-details',
              arguments: {
                'id': tx['id'],
                'jobId': tx['jobId'],
                'title': LocalizationHelper.getTransactionTitle(context, tx),
                'subtitle': LocalizationHelper.getTransactionSubtitle(
                  context,
                  tx,
                ),
                'amount': tx['amount'],
                'time': tx['time'],
                'isCredit': tx['isCredit'],
                'jobPrice': tx['jobPrice'],
                'tipAmount': tx['tipAmount'],
                'serviceAmount': tx['serviceAmount'],
                'feeAmount': tx['feeAmount'],
                'partnerEarning': tx['partnerEarning'],
                'paymentMode': tx['paymentMode'],
              },
            );
          },
        );
      },
    );
  }
}
