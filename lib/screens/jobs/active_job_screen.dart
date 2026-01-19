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
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTimerCard(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerInfo(),
                    const SizedBox(height: 24),
                    _buildChecklist(),
                    const SizedBox(height: 24),
                    _buildPhotoUploadSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomAction()),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        bottom: 15,
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.activeJob,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _showHelpOptions(context),
            icon: const Icon(Icons.help_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Text(
            l10n.totalDuration,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.successGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.jobInProgress,
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 12,
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

  Widget _buildCustomerInfo() {
    final l10n = AppLocalizations.of(context)!;
    final String serviceName = LocalizationHelper.getLocalizedServiceName(
      context,
      _jobData['serviceKey'] ?? _jobData['service'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://via.placeholder.com/100'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobData['customer'] ?? l10n.customer,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  serviceName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: AppColors.successGreen),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primaryOrangeStart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.serviceChecklist,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildCheckItem('Cleaning all rooms', true),
        _buildCheckItem('Kitchen deep cleaning', true),
        _buildCheckItem('Bathroom sanitization', false),
        _buildCheckItem('Balcony & Windows', false),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? AppColors.successGreen : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              decoration: completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.afterServicePhotos,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildUploadBox(),
            const SizedBox(width: 12),
            _buildUploadBox(),
            const SizedBox(width: 12),
            _buildUploadBox(isPlaceholder: true),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadBox({bool isPlaceholder = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isPlaceholder
          ? const Icon(Icons.add_a_photo, color: AppColors.textSecondary)
          : Image.network('https://via.placeholder.com/80', fit: BoxFit.cover),
    );
  }

  Widget _buildBottomAction() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
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
          _showCompletionModal();
        },
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(l10n.markAsCompleted),
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

  void _showHelpOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.howCanWeHelp,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.chat_outlined,
                      label: l10n.chatNow,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/support');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.phone_outlined,
                      label: l10n.callNow,
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryOrangeStart, size: 30),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionModal() {
    final l10n = AppLocalizations.of(context)!;
    final bool isOnlinePayment = _paymentType == 'ONLINE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.jobCompleted,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.earnedFromJob(
                      LocalizationHelper.convertBengaliToEnglish(
                        _earnedAmount.toStringAsFixed(2),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  // Payment type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
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
                          size: 16,
                          color: isOnlinePayment
                              ? AppColors.successGreen
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnlinePayment
                              ? l10n.amountCreditedToWallet
                              : l10n.cashCollectedFeeDeducted,
                          style: TextStyle(
                            color: isOnlinePayment
                                ? AppColors.successGreen
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Customer Rating Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.customerRating,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.ratingGivenByCustomer,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Notify other screens
                      AppColors.jobUpdateNotifier.value++;
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: Text(l10n.backToHome),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
