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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final sectionTitleSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final balanceFontSize = (screenWidth * 0.09).clamp(30.0, 40.0);
    final iconSize = (screenWidth * 0.055).clamp(18.0, 24.0);
    final borderRadius = (screenWidth * 0.06).clamp(16.0, 28.0);
    final spacing = 24.0 * paddingScale;
    final chartHeight = (screenHeight * 0.2).clamp(120.0, 180.0);
    final buttonHeight = (screenHeight * 0.06).clamp(50.0, 60.0);

    if (_isLoading) {
      return Scaffold(
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
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, titleFontSize, borderRadius, hPadding),
                _buildWalletHeader(
                  context,
                  balanceFontSize,
                  borderRadius,
                  hPadding,
                  bodyFontSize,
                  buttonHeight,
                ),
                Padding(
                  padding: EdgeInsets.all(hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(l10n.earnings, sectionTitleSize),
                      _buildPerformanceGrid(bodyFontSize, borderRadius),
                      SizedBox(height: spacing),
                      _buildMonthlyEarningsChart(
                        chartHeight,
                        borderRadius,
                        bodyFontSize,
                      ),
                      SizedBox(height: spacing),
                      _buildSectionTitle(
                        l10n.incentivesAndOffers,
                        sectionTitleSize,
                      ),
                      _buildBonusCard(borderRadius, bodyFontSize),
                      SizedBox(height: 16 * paddingScale),
                      _buildReferCard(borderRadius, bodyFontSize),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSectionTitle(
                              l10n.transactionHistory,
                              sectionTitleSize,
                            ),
                          ),
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
                                style: TextStyle(fontSize: bodyFontSize),
                              ),
                            ),
                          ],
                        ],
                      ),
                      _buildTransactionList(
                        bodyFontSize,
                        borderRadius,
                        iconSize,
                      ),
                      SizedBox(height: 20 * paddingScale),
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

  Widget _buildHeader(
    BuildContext context,
    double fontSize,
    double borderRadius,
    double horizontalPadding,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.earnings,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletHeader(
    BuildContext context,
    double fontSize,
    double borderRadius,
    double horizontalPadding,
    double bodyFontSize,
    double buttonHeight,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(horizontalPadding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.availableBalance,
            style: TextStyle(color: Colors.white70, fontSize: bodyFontSize),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_walletBalance.toStringAsFixed(2))}',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: horizontalPadding * 1.5),
          if (_walletBalance < 0)
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: () =>
                    _showPayNowDialog(context, borderRadius, bodyFontSize),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius * 0.4),
                  ),
                ),
                child: Text(
                  l10n.payNow,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (_walletBalance > 0)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: buttonHeight * 0.8,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWithdrawDialog(
                        context,
                        'Bank',
                        borderRadius,
                        bodyFontSize,
                      ),
                      icon: Icon(
                        Icons.account_balance,
                        size: bodyFontSize * 1.1,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.bankTransfer,
                        style: TextStyle(fontSize: bodyFontSize * 0.85),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            borderRadius * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: buttonHeight * 0.8,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWithdrawDialog(
                        context,
                        'UPI',
                        borderRadius,
                        bodyFontSize,
                      ),
                      icon: Icon(Icons.qr_code, size: bodyFontSize * 1.1),
                      label: Text(
                        AppLocalizations.of(context)!.upiWithdraw,
                        style: TextStyle(fontSize: bodyFontSize * 0.85),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrangeStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            borderRadius * 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Shows a popup dialog when payment method is not set up
  void _showPaymentSetupRequiredDialog(
    BuildContext context,
    String message,
    double borderRadius,
    double fontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: fontSize * 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.paymentSetup,
                  style: TextStyle(
                    fontSize: fontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: fontSize,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.pleaseFillAllFields,
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/payment-setup');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primaryOrangeStart,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.add,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWithdrawDialog(
    BuildContext context,
    String method,
    double borderRadius,
    double fontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final String localizedMethod = method == 'Bank'
        ? l10n.bankTransfer
        : l10n.upiWithdraw;

    // Validation for Bank/UPI details - Show error popup with Add button
    if (method == 'Bank' && !_bankAccountAdded) {
      _showPaymentSetupRequiredDialog(
        context,
        l10n.noBankAccountFound,
        borderRadius,
        fontSize,
      );
      return;
    }
    if (method == 'UPI' && !_upiIdAdded) {
      _showPaymentSetupRequiredDialog(
        context,
        l10n.noUpiIdFound,
        borderRadius,
        fontSize,
      );
      return;
    }

    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
        ),
        title: Text(
          l10n.withdrawVia(localizedMethod),
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.enterAmountToWithdraw,
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [EnglishDigitFormatter()],
                style: TextStyle(fontSize: fontSize),
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: fontSize * 0.75,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: TextStyle(fontSize: fontSize)),
          ),
          ElevatedButton(
            onPressed: () async {
              final double amount =
                  double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0 || amount > _walletBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidAmountOrInsufficientBalance),
                    duration: const Duration(seconds: 2),
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
                  SnackBar(
                    content: Text(l10n.withdrawalProcessed),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(l10n.withdraw, style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }

  void _showPayNowDialog(
    BuildContext context,
    double borderRadius,
    double fontSize,
  ) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
        ),
        title: Text(
          l10n.payNow,
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.enterAmountToAddOrPay,
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [EnglishDigitFormatter()],
                style: TextStyle(fontSize: fontSize),
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
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: Text(
                      '${l10n.currencySymbol}${l10n.quickAmount1}',
                      style: TextStyle(fontSize: fontSize * 0.75),
                    ),
                    onPressed: () {
                      _amountController.text = l10n.quickAmount1;
                    },
                  ),
                  ActionChip(
                    label: Text(
                      '${l10n.currencySymbol}${l10n.quickAmount2}',
                      style: TextStyle(fontSize: fontSize * 0.75),
                    ),
                    onPressed: () {
                      _amountController.text = l10n.quickAmount2;
                    },
                  ),
                  ActionChip(
                    label: Text(
                      '${l10n.currencySymbol}${l10n.quickAmount3}',
                      style: TextStyle(fontSize: fontSize * 0.75),
                    ),
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
            child: Text(l10n.cancel, style: TextStyle(fontSize: fontSize)),
          ),
          ElevatedButton(
            onPressed: () async {
              final double amount =
                  double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.invalidAmount),
                    duration: const Duration(seconds: 2),
                  ),
                );
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
                  SnackBar(
                    content: Text(l10n.paymentProcessedSuccessfully),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeStart,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              l10n.proceedToPay,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid(double fontSize, double borderRadius) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildMetric(
              l10n.earnings,
              '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_totalEarnings.toStringAsFixed(0))}',
              Colors.green,
              fontSize,
              fontSize * 0.66,
            ),
          ),
          _buildDivider(fontSize * 1.5),
          Expanded(
            child: _buildMetric(
              l10n.tips,
              '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_totalTips.toStringAsFixed(0))}',
              Colors.orange,
              fontSize,
              fontSize * 0.66,
            ),
          ),
          _buildDivider(fontSize * 1.5),
          Expanded(
            child: _buildMetric(
              l10n.orders,
              LocalizationHelper.convertBengaliToEnglish(_totalJobsDone),
              Colors.blue,
              fontSize,
              fontSize * 0.66,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyEarningsChart(
    double height,
    double borderRadius,
    double fontSize,
  ) {
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
        borderRadius: BorderRadius.circular(borderRadius),
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedBarIndex == null
                          ? LocalizationHelper.convertBengaliToEnglish(
                              '${l10n.currencySymbol}${totalMonthlyEarnings.toStringAsFixed(0)}',
                            )
                          : LocalizationHelper.convertBengaliToEnglish(
                              '${l10n.currencySymbol}${dailyEarnings[_selectedBarIndex!].toStringAsFixed(0)}',
                            ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize * 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _selectedBarIndex == null
                        ? l10n.totalForMonth(_selectedMonth)
                        : l10n.earningsForMonthAndDay(
                            _selectedMonth.split(' ')[0],
                            (_selectedBarIndex! + 1).toString(),
                          ),
                    style: TextStyle(
                      color: AppColors.primaryOrangeStart,
                      fontSize: fontSize * 0.8,
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize * 0.8,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: fontSize * 1.2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: height,
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
                          height: (height * heightFactor).clamp(4.0, height),
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
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: fontSize * 0.7,
                ),
              ),
              Text(
                '15 ${_selectedMonth.split(' ')[0]}',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: fontSize * 0.7,
                ),
              ),
              Text(
                '${dailyEarnings.length} ${_selectedMonth.split(' ')[0]}',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: fontSize * 0.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    String label,
    String value,
    Color color,
    double fontSize,
    double labelSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: labelSize, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider(double height) {
    return Container(height: height, width: 1, color: AppColors.border);
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBonusCard(double borderRadius, double fontSize) {
    final l10n = AppLocalizations.of(context)!;
    double progress = (_totalJobsDone / 15).clamp(0.0, 1.0);
    bool isComplete = progress >= 1.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background elements
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars,
              size: 120,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeStart.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryOrangeStart.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryOrangeStart,
                        size: fontSize * 1.5,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.weeklyBonusChallenge.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: fontSize,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            l10n.weeklyBonusSubtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSize * 0.75,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: fontSize * 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.jobsDoneWithProgress(
                        LocalizationHelper.convertBengaliToEnglish(
                          _totalJobsDone,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.85,
                      ),
                    ),
                    Text(
                      l10n.jobsGoal,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: fontSize * 0.75,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            height: 12,
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryOrangeStart,
                                  Color(0xFFFFB800),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrangeStart
                                      .withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.redeem,
                        color: Colors.greenAccent,
                        size: fontSize * 1.25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n
                            .potentialEarnings('')
                            .replaceAll(l10n.currencySymbol, '')
                            .trim(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: fontSize * 0.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish((500).toStringAsFixed(0))}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferCard(double borderRadius, double fontSize) {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          ),
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.referSubtitle,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: fontSize * 0.75,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: TextStyle(fontSize: fontSize * 0.8),
                ),
                child: Text(l10n.invite),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    double fontSize,
    double borderRadius,
    double iconSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: iconSize * 2,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactionsYet,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
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
              size: iconSize,
            ),
          ),
          title: Text(
            LocalizationHelper.getTransactionTitle(context, tx),
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationHelper.getTransactionSubtitle(context, tx),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: fontSize * 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                tx['time'] ?? '',
                style: TextStyle(fontSize: fontSize * 0.75),
              ),
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
                      fontSize: fontSize * 0.7,
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
                  fontSize: fontSize,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              if (isJob)
                Text(
                  isCredit ? l10n.completed : l10n.deducted,
                  style: TextStyle(
                    fontSize: fontSize * 0.7,
                    color: Colors.grey.shade600,
                  ),
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
