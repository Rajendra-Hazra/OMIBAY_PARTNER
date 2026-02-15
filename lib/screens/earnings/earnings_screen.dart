import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

import 'package:intl/intl.dart';
import '../../services/wallet_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../repositories/earnings_repository.dart';
import '../../models/earnings_stats.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../repositories/wallet_repository.dart';
import '../../models/wallet_transaction.dart';

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
  Map<String, List<double>> _monthlyData = {};
  WeeklyBonus? _weeklyBonus;
  ReferralOffer? _referralOffer;
  String _selectedMonth = '';
  final TextEditingController _amountController = TextEditingController();

  // Repository instance
  late final EarningsRepository _earningsRepository;
  late final WalletRepository _walletRepository;
  late Razorpay _razorpay;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize Repository
    // Note: Ideally ApiClient should be provided via DI or Provider
    _earningsRepository = EarningsRepository(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _walletRepository = WalletRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _initializeRazorpay();

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
      // Initialize with empty, will be populated by API graph data
      _monthlyData = {};
    }
    _loadData();
  }

  @override
  void dispose() {
    AppColors.jobUpdateNotifier.removeListener(_loadData);
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);
    try {
      if (response.paymentId != null && response.signature != null) {
        await _walletRepository.verifyRecharge(
          response.orderId!,
          response.paymentId!,
          response.signature!,
        );
        _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Wallet updated.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
    setState(() => _isProcessing = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Fetch Stats
      final stats = await _earningsRepository.getEarningsStats();

      // 2. Fetch Graph Data
      final now = DateTime.now();
      final graphData = await _earningsRepository.getEarningsGraph(
        month: now.month,
        year: now.year,
      );

      // 3. Fetch History
      final transactions = await _walletRepository.getTransactions();

      // 4. Fetch Payment Methods
      final paymentMethods = await _walletRepository.getBankAccounts();
      bool bankAdded = false;
      bool upiAdded = false;
      for (var pm in paymentMethods) {
        if (pm['bankName'] == 'UPI' ||
            (pm['upiId'] != null && pm['upiId'].toString().isNotEmpty)) {
          upiAdded = true;
        } else {
          bankAdded = true;
        }
      }

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      // Process Graph Data into _monthlyData
      // Backend returns list of {date, day, amount}
      // We need to map it to the requested format for the chart widget
      // Current chart widget expects map key "Month Year" -> List<double>

      final String currentMonthKey = _getLocalizedMonthYear(now);
      final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final List<double> dailyEarnings = List.filled(daysInMonth, 0.0);

      for (var point in graphData) {
        final int day = point['day'] as int;
        final double amount = (point['amount'] as num).toDouble();
        if (day >= 1 && day <= daysInMonth) {
          dailyEarnings[day - 1] = amount;
        }
      }
      _monthlyData[currentMonthKey] = dailyEarnings;
      _selectedMonth = currentMonthKey;

      // Process History
      final List<Map<String, dynamic>> transactionData = transactions.map((
        txn,
      ) {
        return {
          'title': txn.description.isNotEmpty ? txn.description : l10n.unknown,
          'subtitle': txn.paymentMode,
          'amount': txn.formattedAmount,
          'isCredit': txn.isCredit,
          'time': LocalizationHelper.convertBengaliToEnglish(
            DateFormat(
              'dd MMM, hh:mm a',
              Localizations.localeOf(context).toString(),
            ).format(txn.createdAt),
          ),
          'paymentMode': txn.paymentMode,
          'isJob': txn.isJob,
        };
      }).toList();

      setState(() {
        _totalEarnings = stats.totalEarnings;
        _totalTips = stats.totalTips;
        _totalJobsDone = stats.totalEarnings > 0
            ? stats.todayJobs
            : 0; // Wait, totalJobsDone should be total lifetime jobs? The API returns "todayJobs" and "totalCompletedServices" (in partner entity).
        // My DTO: todayJobs. Partner Entity: totalCompletedServices.
        // The API returns todayJobs.
        // The UI variable is `_totalJobsDone`.
        // Let's check `PartnerEarningsStatsDTO` again.
        // It has `todayJobs`. It does NOT have `totalJobs`.
        // However, `Partner` entity has `totalCompletedServices`.
        // I should have included `totalJobs` in the DTO?
        // Let's re-read DTO.
        // `totalEarnings`, `walletBalance`, `totalTips`, `todayEarnings`, `todayJobs`.
        // It seems I missed `totalCompletedServices` in the DTO or the UI calls it today jobs?
        // _totalJobsDone usually implies lifetime.
        // I'll update the DTO and Service to include totalJobs if needed, or just map what I have.
        // For now, I'll map `todayJobs` if that's what was intended, OR I'll update the backend to include `totalJobs`.
        // The detailed plan said: "Returns totalEarnings... totalTips... todayEarnings, todayJobs".
        // The UI `_totalJobsDone` was calculated from "completed_jobs_list" which is history. So it was likely lifetime.
        // I should update the backend to return total jobs.
        // BUT, I can't update backend easily now without restart issues (maybe).
        // Let's assume `_totalJobsDone` is OK to start with 0 or `todayJobs` for now, or check if I can quick-fix backend.
        // Actually, I can fix backend. I'm in EXECUTION.
        // Ideally, I should add `totalJobs` to DTO.
        // Implementation plan said: "Returns data ... total jobs completed".
        // My DTO has `todayJobs`. I missed `totalJobs`.
        // I'll fix the backend DTO and Service in a follow-up or right now.
        // It's better to fix it now.

        _totalJobsDone = stats.totalJobs;
        _weeklyBonus = stats.weeklyBonus;
        _referralOffer = stats.referralOffer;
        _walletBalance = stats.walletBalance;
        _bankAccountAdded = bankAdded;
        _upiIdAdded = upiAdded;
        _transactions = transactionData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading earnings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback to local? Or just show 0.
        });
      }
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
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
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
                        // _buildReferCard(borderRadius, bodyFontSize),
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
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrangeStart,
                ),
              ),
            ),
        ],
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
                    _showAddMoneyDialog(context, borderRadius, bodyFontSize),
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
                      onPressed: () => _showAddMoneyDialog(
                        context,
                        borderRadius,
                        bodyFontSize,
                      ),
                      icon: Icon(Icons.add_card, size: bodyFontSize * 1.1),
                      label: Text(
                        'Add Money',
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
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: buttonHeight * 0.8,
                    child: ElevatedButton.icon(
                      onPressed: () => _showWithdrawSelectionDialog(
                        context,
                        borderRadius,
                        bodyFontSize,
                      ),
                      icon: Icon(
                        Icons.account_balance_wallet,
                        size: bodyFontSize * 1.1,
                      ),
                      label: Text(
                        l10n.withdraw,
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

  void _showWithdrawSelectionDialog(
    BuildContext context,
    double borderRadius,
    double fontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
        ),
        title: Text(
          l10n.withdraw,
          style: TextStyle(
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.account_balance,
                color: AppColors.primaryOrangeStart,
              ),
              title: Text(l10n.bankTransfer),
              onTap: () {
                Navigator.pop(context);
                _showWithdrawDialog(context, 'Bank', borderRadius, fontSize);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.qr_code,
                color: AppColors.primaryOrangeStart,
              ),
              title: Text(l10n.upiWithdraw),
              onTap: () {
                Navigator.pop(context);
                _showWithdrawDialog(context, 'UPI', borderRadius, fontSize);
              },
            ),
          ],
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

  void _showAddMoneyDialog(
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
          'Add Money', // Hardcoded fallback for now
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

              // ---------------------------------------------------------
              // REAL PAYMENT IMPLEMENTATION
              // ---------------------------------------------------------
              setState(() => _isProcessing = true);
              final messenger = ScaffoldMessenger.of(context);

              try {
                // 1. Create Order on Backend
                final orderData = await _walletRepository.createRechargeOrder(
                  amount,
                );

                // 2. Get User Info for Prefill
                final prefs = await SharedPreferences.getInstance();
                // Partner data might be different, but Razorpay needs contact/email
                final userPhone = prefs.getString('user_phone') ?? '';
                final userEmail = prefs.getString('user_email') ?? '';

                // 3. Open Razorpay
                final options = {
                  'key': orderData['key'],
                  'amount': orderData['amount'],
                  'name': 'OmiBay Partner',
                  'order_id': orderData['orderId'],
                  'description': 'Wallet Recharge',
                  'timeout': 300,
                  'prefill': {'contact': userPhone, 'email': userEmail},
                };

                _razorpay.open(options);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to initiate payment: $e')),
                );
                setState(() => _isProcessing = false);
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

    // Always show card, use default values if API returns null
    final bonus =
        _weeklyBonus ??
        WeeklyBonus(
          title: 'Weekly Bonus',
          subtitle: 'Complete jobs to earn bonus',
          targetJobs: 15,
          completedJobs: 0,
          rewardAmount: 200.0,
          isCompleted: false,
          endsIn: 'This week',
        );

    double progress = (bonus.completedJobs / bonus.targetJobs).clamp(0.0, 1.0);
    bool isComplete = bonus.isCompleted;

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
                            bonus.title.toUpperCase(), // Use title from backend
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: fontSize,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            bonus.subtitle, // Use subtitle from backend
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSize * 0.75,
                            ),
                          ),
                          Text(
                            bonus.endsIn.isNotEmpty
                                ? 'Ends in ${bonus.endsIn}'
                                : '',
                            style: TextStyle(
                              color: AppColors.primaryOrangeStart,
                              fontWeight: FontWeight.bold,
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
                          bonus.completedJobs,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.85,
                      ),
                    ),
                    Text(
                      'Goal: ${LocalizationHelper.convertBengaliToEnglish(bonus.targetJobs)}',
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
                        '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(bonus.rewardAmount.toInt().toString())}',
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

  /*
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
                      _referralOffer != null
                          ? '${_referralOffer!.title} ${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(_referralOffer!.amount.toInt().toString())}'
                          : l10n.referAndEarnWithAmount('200'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _referralOffer?.subtitle ?? l10n.referSubtitle,
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
                child: Text(_referralOffer?.actionText ?? l10n.invite),
              ),
            ],
          ),
        ),
      ),
    );
  }
  */

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
