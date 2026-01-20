import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/bounce_button.dart';
import '../../core/app_colors.dart';
import '../../services/wallet_service.dart';
import '../../models/wallet_transaction.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

class ActiveJobScreen extends StatefulWidget {
  const ActiveJobScreen({super.key});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  int _seconds = 0;
  Timer? _timer;
  double _earnedAmount = 0.0;
  String _paymentType = 'Online';
  Map<String, dynamic> _jobData = {};

  @override
  void initState() {
    super.initState();
    _loadJobData();
    _startTimer();
  }

  Future<void> _loadJobData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _jobData = {
        'id': LocalizationHelper.convertBengaliToEnglish(
          prefs.getString('active_job_id') ?? '#JOB123',
        ),
        'service': LocalizationHelper.getLocalizedServiceName(
          context,
          prefs.getString('active_job_service_key') ??
              prefs.getString('active_job_service'),
        ),
        'serviceKey': prefs.getString('active_job_service_key'),
        'customer': LocalizationHelper.getLocalizedCustomerName(
          context,
          prefs.getString('active_job_customer'),
        ),
        'price': LocalizationHelper.convertBengaliToEnglish(
          prefs.getString('active_job_price') ?? '0',
        ),
        'tip': LocalizationHelper.convertBengaliToEnglish(
          prefs.getString('active_job_tip') ?? '0',
        ),
        'paymentType': LocalizationHelper.getLocalizedPaymentType(
          context,
          prefs.getString('active_job_payment_type'),
        ),
      };
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadJobData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    final time =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return LocalizationHelper.convertBengaliToEnglish(time);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, paddingScale, titleFontSize, bodyFontSize),
            _buildTimerCard(paddingScale, bodyFontSize, smallFontSize),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20 * paddingScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfo(
                      paddingScale,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    SizedBox(height: 24 * paddingScale),
                    _buildChecklist(paddingScale, bodyFontSize),
                    SizedBox(height: 24 * paddingScale),
                    _buildPhotoUploadSection(paddingScale, bodyFontSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomAction(paddingScale, bodyFontSize),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double paddingScale,
    double titleFontSize,
    double bodyFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (10 * paddingScale),
        left: 10 * paddingScale,
        right: 10 * paddingScale,
        bottom: 15 * paddingScale,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 10 * paddingScale),
          Expanded(
            child: Text(
              l10n.activeJob,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _showHelpOptions(
              context,
              paddingScale,
              titleFontSize,
              bodyFontSize,
            ),
            icon: Icon(
              Icons.help_outline,
              color: Colors.white,
              size: (24 * paddingScale).clamp(20.0, 28.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24 * paddingScale),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Text(
            l10n.totalDuration,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: smallFontSize,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * paddingScale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatTime(_seconds),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: (48 * paddingScale).clamp(36.0, 60.0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12 * paddingScale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * paddingScale,
              vertical: 4 * paddingScale,
            ),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: (8 * paddingScale).clamp(6.0, 10.0),
                  color: AppColors.successGreen,
                ),
                SizedBox(width: 8 * paddingScale),
                Text(
                  l10n.jobInProgress,
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final String serviceName = LocalizationHelper.getLocalizedServiceName(
      context,
      _jobData['serviceKey'] ?? _jobData['service'],
    );

    return Container(
      padding: EdgeInsets.all(16 * paddingScale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24 * paddingScale,
            backgroundColor: Colors.grey[200],
            backgroundImage: const NetworkImage(
              'https://via.placeholder.com/100',
            ),
          ),
          SizedBox(width: 12 * paddingScale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobData['customer'] ?? l10n.customer,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  serviceName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: smallFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.phone,
              color: AppColors.successGreen,
              size: (24 * paddingScale).clamp(20.0, 28.0),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primaryOrangeStart,
              size: (24 * paddingScale).clamp(20.0, 28.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist(double paddingScale, double bodyFontSize) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.serviceChecklist,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: bodyFontSize),
        ),
        SizedBox(height: 16 * paddingScale),
        _buildCheckItem('Cleaning all rooms', true, paddingScale, bodyFontSize),
        _buildCheckItem(
          'Kitchen deep cleaning',
          true,
          paddingScale,
          bodyFontSize,
        ),
        _buildCheckItem(
          'Bathroom sanitization',
          false,
          paddingScale,
          bodyFontSize,
        ),
        _buildCheckItem('Balcony & Windows', false, paddingScale, bodyFontSize),
      ],
    );
  }

  Widget _buildCheckItem(
    String label,
    bool completed,
    double paddingScale,
    double bodyFontSize,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * paddingScale),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? AppColors.successGreen : AppColors.textSecondary,
            size: (20 * paddingScale).clamp(18.0, 24.0),
          ),
          SizedBox(width: 12 * paddingScale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bodyFontSize,
                color: completed
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection(double paddingScale, double bodyFontSize) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.afterServicePhotos,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: bodyFontSize),
        ),
        SizedBox(height: 16 * paddingScale),
        Row(
          children: [
            _buildUploadBox(paddingScale),
            SizedBox(width: 12 * paddingScale),
            _buildUploadBox(paddingScale),
            SizedBox(width: 12 * paddingScale),
            _buildUploadBox(paddingScale, isPlaceholder: true),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadBox(double paddingScale, {bool isPlaceholder = false}) {
    final boxSize = (80 * paddingScale).clamp(70.0, 100.0);
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isPlaceholder
          ? Icon(
              Icons.add_a_photo,
              color: AppColors.textSecondary,
              size: (24 * paddingScale).clamp(20.0, 32.0),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://via.placeholder.com/80',
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _buildBottomAction(double paddingScale, double bodyFontSize) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20 * paddingScale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BounceButton(
        onPressed: () async {
          _timer?.cancel();
          await _handleJobCompletion();
          _showCompletionModal(paddingScale, bodyFontSize);
        },
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            minimumSize: Size(
              double.infinity,
              (50 * paddingScale).clamp(45.0, 60.0),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.markAsCompleted,
            style: TextStyle(
              fontSize: bodyFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleJobCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    // Get job details from SharedPreferences
    final String priceStr = prefs.getString('active_job_price') ?? '0';
    final double totalJobPrice =
        double.tryParse(priceStr.replaceAll(',', '')) ?? 0.0;
    final String tipStr = prefs.getString('active_job_tip') ?? '0';
    final double tipAmount = double.tryParse(tipStr) ?? 0.0;
    final String jobId =
        prefs.getString('active_job_id') ?? '#OK${_seconds.toString()}';
    final String serviceName =
        prefs.getString('active_job_service') ?? l10n.service;
    final String customerName =
        prefs.getString('active_job_customer') ?? l10n.customer;

    // Get payment type and normalize to ONLINE/COD
    final String rawPaymentType =
        prefs.getString('active_job_payment_type') ?? 'Online';
    _paymentType =
        rawPaymentType.toUpperCase() == 'CASH' ||
            rawPaymentType.toLowerCase() == 'cash'
        ? 'COD'
        : 'ONLINE';

    // Use WalletService to process job completion
    // This handles all calculations, wallet updates, and transaction recording
    final WalletTransaction transaction =
        await WalletService.processJobCompletion(
          jobId: jobId,
          totalJobPrice: totalJobPrice,
          tipAmount: tipAmount,
          paymentMode: _paymentType,
          customerName: customerName,
          serviceName: serviceName,
        );

    // Set earned amount for display in completion modal
    _earnedAmount = transaction.partnerNetEarning;

    // Clear active job data
    await WalletService.clearActiveJob();

    // Notify other screens
    AppColors.jobUpdateNotifier.value++;
  }

  void _showHelpOptions(
    BuildContext context,
    double paddingScale,
    double titleFontSize,
    double bodyFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20 * paddingScale,
            24 * paddingScale,
            20 * paddingScale,
            (MediaQuery.of(context).padding.bottom + 24) * paddingScale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 24 * paddingScale),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.howCanWeHelp,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24 * paddingScale),
              Row(
                children: [
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.chat_outlined,
                      label: l10n.chatNow,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/support');
                      },
                    ),
                  ),
                  SizedBox(width: 16 * paddingScale),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.phone_outlined,
                      label: l10n.callNow,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
                      onTap: () async {
                        Navigator.pop(context);
                        final Uri url = Uri.parse('tel:+918016867006');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.couldNotLaunchDialer)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double paddingScale,
    required double bodyFontSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24 * paddingScale),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryOrangeStart,
              size: (32 * paddingScale).clamp(28.0, 40.0),
            ),
            SizedBox(height: 12 * paddingScale),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: bodyFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionModal(double paddingScale, double bodyFontSize) {
    final l10n = AppLocalizations.of(context)!;
    final bool isOnlinePayment = _paymentType == 'ONLINE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24 * paddingScale,
            32 * paddingScale,
            24 * paddingScale,
            (MediaQuery.of(context).padding.bottom + 24) * paddingScale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: (64 * paddingScale).clamp(56.0, 80.0),
                color: AppColors.successGreen,
              ),
              SizedBox(height: 16 * paddingScale),
              Text(
                l10n.jobCompleted,
                style: TextStyle(
                  fontSize: bodyFontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8 * paddingScale),
              Text(
                l10n.earnedFromJob(
                  LocalizationHelper.convertBengaliToEnglish(
                    _earnedAmount.toStringAsFixed(2),
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: bodyFontSize,
                ),
              ),
              SizedBox(height: 16 * paddingScale),
              // Payment type indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * paddingScale,
                  vertical: 10 * paddingScale,
                ),
                decoration: BoxDecoration(
                  color: isOnlinePayment
                      ? AppColors.successGreen.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnlinePayment
                        ? AppColors.successGreen.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnlinePayment
                          ? Icons.account_balance_wallet
                          : Icons.money,
                      size: (16 * paddingScale).clamp(14.0, 18.0),
                      color: isOnlinePayment
                          ? AppColors.successGreen
                          : Colors.orange,
                    ),
                    SizedBox(width: 8 * paddingScale),
                    Flexible(
                      child: Text(
                        isOnlinePayment
                            ? l10n.amountCreditedToWallet
                            : l10n.cashCollectedFeeDeducted,
                        style: TextStyle(
                          color: isOnlinePayment
                              ? AppColors.successGreen
                              : Colors.orange,
                          fontSize: bodyFontSize - 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24 * paddingScale),
              // Customer Rating Section
              Container(
                padding: EdgeInsets.all(16 * paddingScale),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.customerRating,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * paddingScale),
                    Text(
                      l10n.ratingGivenByCustomer,
                      style: TextStyle(
                        fontSize: bodyFontSize - 3,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32 * paddingScale),
              ElevatedButton(
                onPressed: () async {
                  // Notify other screens
                  AppColors.jobUpdateNotifier.value++;
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrangeStart,
                  minimumSize: Size(
                    double.infinity,
                    (50 * paddingScale).clamp(45.0, 60.0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.backToHome,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
