import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/bounce_button.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/wallet_service.dart';
import '../../core/localization_helper.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const JobDetailsScreen({super.key, this.jobData});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  int _currentStep =
      -1; // -1: Accept, 0: On the way, 1: Arrived, 2: Started, 3: Complete
  bool _isPaused = false;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      _loadCurrentStep();
      _isLoaded = true;
    }
  }

  Future<void> _loadCurrentStep() async {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = widget.jobData ?? args;
    if (data == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = _getJobKey(data);
    final int savedStep = prefs.getInt(key) ?? -1;

    if (mounted) {
      setState(() {
        _currentStep = savedStep;
      });
    }
  }

  Future<void> _saveCurrentStep(int step) async {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = widget.jobData ?? args;
    if (data == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = _getJobKey(data);
    await prefs.setInt(key, step);
  }

  String _getJobKey(Map<String, dynamic> data) {
    // Unique key based on customer and service to persist state per job
    final String customer = data['customerName'] ?? 'unknown';
    final String service = data['service'] ?? 'unknown';
    return 'job_step_${customer}_$service';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic>? rawData = widget.jobData ?? args;

    if (rawData == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.noResultsFoundFor('')),
        ),
      );
    }

    // Helper to get localized service name
    String getServiceName() {
      return LocalizationHelper.getLocalizedServiceName(
        context,
        rawData['serviceKey'] ?? rawData['service'],
      );
    }

    // Helper to get localized time type
    String getTimeType() {
      return LocalizationHelper.getLocalizedTimeType(context, rawData);
    }

    // Helper to get localized ETA
    String getEta() {
      return LocalizationHelper.getLocalizedEta(context, rawData);
    }

    // Helper to get localized payment type
    String getPaymentType() {
      return LocalizationHelper.getLocalizedPaymentType(
        context,
        rawData['paymentTypeKey'] ?? rawData['paymentType'],
      );
    }

    final effectiveJobData = {
      ...rawData,
      'service': getServiceName(),
      'timeType': getTimeType(),
      'eta': getEta(),
      'paymentType': getPaymentType(),
      'customerName': LocalizationHelper.getLocalizedCustomerName(
        context,
        rawData['customerName'] ?? rawData['customer'],
      ),
      'location': LocalizationHelper.getLocalizedLocation(
        context,
        rawData['location'],
      ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScheduleSection(effectiveJobData),
                    _buildCombinedDetails(effectiveJobData),
                    _buildServiceTimeline(),
                    if (_currentStep == 3) _buildReviewSection(),
                    _buildSyncActionButton(effectiveJobData),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActionButton(Map<String, dynamic>? effectiveJobData) {
    if (_currentStep == 3) return const SizedBox.shrink();

    if (_currentStep == 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _buildBaseActionButton(
                label: _isPaused
                    ? AppLocalizations.of(context)!.resumeWork
                    : AppLocalizations.of(context)!.pauseWork,
                color: _isPaused
                    ? AppColors.successGreen
                    : Colors.grey.shade700,
                onPressed: () {
                  if (_isPaused) {
                    setState(() {
                      _isPaused = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.workResumed,
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } else {
                    _showPauseWorkPopup(context);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBaseActionButton(
                label: AppLocalizations.of(context)!.markComplete,
                color: AppColors.primaryOrangeStart,
                onPressed: () {
                  _showCompletionPopup(context, effectiveJobData);
                },
              ),
            ),
          ],
        ),
      );
    }

    String label = AppLocalizations.of(context)!.startJourney;
    if (_currentStep == 0) label = AppLocalizations.of(context)!.arrived;
    if (_currentStep == 1) label = AppLocalizations.of(context)!.startWork;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      child: _buildBaseActionButton(
        label: label,
        color: AppColors.primaryOrangeStart,
        onPressed: () {
          if (_currentStep == 1) {
            _showOtpVerificationPopup(context);
          } else {
            final nextStep = _currentStep < 3 ? _currentStep + 1 : _currentStep;
            setState(() {
              _currentStep = nextStep;
            });
            _saveCurrentStep(nextStep);
          }
        },
      ),
    );
  }

  Widget _buildBaseActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: BounceButton(
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionPopup(BuildContext context, Map<String, dynamic>? data) {
    final String price = data?['price'] ?? '1,499';
    String? pickedPhoto;
    String? pickedVideo;
    String? selectedPaymentMethod;
    double videoUploadProgress = 0.0;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.completeJobQuestion,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.completeJobConfirmation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.receiveMoney,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${LocalizationHelper.convertBengaliToEnglish(price)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryOrangeStart,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // COMPLETION PROOF SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrangeStart,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.completionProof,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaUploadButton(
                                  icon: Icons.add_a_photo_outlined,
                                  label: AppLocalizations.of(context)!.addPhoto,
                                  color: pickedPhoto != null
                                      ? Colors.green
                                      : null,
                                  previewPath: pickedPhoto,
                                  onPreviewTap: () => _showFullScreenPreview(
                                    context,
                                    pickedPhoto!,
                                  ),
                                  onCancelTap: () {
                                    setPopupState(() {
                                      pickedPhoto = null;
                                    });
                                  },
                                  onTap: () {
                                    _showMediaSourceOptions(
                                      context,
                                      title: 'Add Completion Photo',
                                      onImagePicked: (path) {
                                        setPopupState(() {
                                          pickedPhoto = path;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMediaUploadButton(
                                  icon: Icons.videocam_outlined,
                                  label: AppLocalizations.of(context)!.addVideo,
                                  subLabel: pickedVideo != null
                                      ? null
                                      : AppLocalizations.of(context)!.min10Sec,
                                  color: pickedVideo != null
                                      ? Colors.green
                                      : null,
                                  previewPath: pickedVideo,
                                  isVideo: true,
                                  onPreviewTap: () => _showFullScreenPreview(
                                    context,
                                    pickedVideo!,
                                    isVideo: true,
                                  ),
                                  onCancelTap: () {
                                    setPopupState(() {
                                      pickedVideo = null;
                                      videoUploadProgress = 0.0;
                                      isUploading = false;
                                    });
                                  },
                                  uploadProgress: videoUploadProgress,
                                  onTap: isUploading
                                      ? () {}
                                      : () {
                                          _showMediaSourceOptions(
                                            context,
                                            title: 'Add Completion Video',
                                            isVideo: true,
                                            onImagePicked: (path) {
                                              setPopupState(() {
                                                isUploading = true;
                                                videoUploadProgress = 0.01;
                                              });

                                              // Simulate upload progress
                                              Timer.periodic(
                                                const Duration(
                                                  milliseconds: 100,
                                                ),
                                                (timer) {
                                                  setPopupState(() {
                                                    videoUploadProgress += 0.05;
                                                    if (videoUploadProgress >=
                                                        1.0) {
                                                      videoUploadProgress = 1.0;
                                                      pickedVideo = path;
                                                      isUploading = false;
                                                      timer.cancel();
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // PAYMENT METHOD SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrangeStart,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.paymentMethod.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (data?['paymentStatus'] == 'Prepaid' ||
                              data?['paymentType'] == 'Prepaid')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.prepaid,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMediaUploadButton(
                                    icon: Icons.payments_outlined,
                                    label: AppLocalizations.of(context)!.cash,
                                    color: selectedPaymentMethod == 'Cash'
                                        ? Colors.green
                                        : null,
                                    onTap: () {
                                      setPopupState(() {
                                        selectedPaymentMethod = 'Cash';
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMediaUploadButton(
                                    icon: Icons.qr_code_scanner_rounded,
                                    label: AppLocalizations.of(context)!.showQr,
                                    color: selectedPaymentMethod == 'QR'
                                        ? Colors.green
                                        : null,
                                    onTap: () {
                                      setPopupState(() {
                                        selectedPaymentMethod = 'QR';
                                      });
                                      _showQrCodePopup(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              (isUploading ||
                                  pickedPhoto == null ||
                                  pickedVideo == null ||
                                  (data?['paymentStatus'] != 'Prepaid' &&
                                      data?['paymentType'] != 'Prepaid' &&
                                      selectedPaymentMethod == null))
                              ? null
                              : () async {
                                  final l10n = AppLocalizations.of(context)!;
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentStep = 3;
                                  });
                                  await _saveCurrentStep(3);

                                  // Get job details
                                  final String priceStr = data?['price'] ?? '0';
                                  final double totalJobPrice =
                                      double.tryParse(
                                        priceStr.replaceAll(',', ''),
                                      ) ??
                                      0.0;
                                  final String tipStr = data?['tip'] ?? '0';
                                  final double tipAmount =
                                      double.tryParse(tipStr) ?? 0.0;
                                  final String jobId =
                                      data?['id'] ??
                                      '#OK${Random().nextInt(999999).toString()}';
                                  final String serviceName =
                                      data?['service'] ?? l10n.service;
                                  final String customerName =
                                      data?['customerName'] ??
                                      data?['customer'] ??
                                      l10n.customer;
                                  final String location =
                                      data?['location'] ?? l10n.location;
                                  final String timeType =
                                      data?['timeType'] ?? l10n.instant;

                                  // Determine payment mode
                                  // Prepaid or QR = ONLINE, Cash = COD
                                  String paymentMode;
                                  if (data?['paymentStatus'] == 'Prepaid' ||
                                      data?['paymentType'] == 'Prepaid' ||
                                      selectedPaymentMethod == 'QR') {
                                    paymentMode = 'ONLINE';
                                  } else {
                                    paymentMode = 'COD';
                                  }

                                  // Use WalletService to process job completion
                                  // This handles all calculations, wallet updates, and transaction recording
                                  await WalletService.processJobCompletion(
                                    jobId: jobId,
                                    totalJobPrice: totalJobPrice,
                                    tipAmount: tipAmount,
                                    paymentMode: paymentMode,
                                    customerName: customerName,
                                    serviceName: serviceName,
                                    serviceKey: data?['serviceKey'],
                                    location: location,
                                    timeType: timeType,
                                  );
                                  // Remove from active jobs list (multi-job support)
                                  if (jobId.isNotEmpty) {
                                    await WalletService.removeActiveJob(jobId);
                                  }
                                  // Also clear legacy single-job keys for backward compatibility
                                  await WalletService.clearActiveJob();

                                  // Increment trigger to notify listeners (e.g. Job list update)
                                  AppColors.jobUpdateNotifier.value++;

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.jobMarkedAsCompleted,
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // Navigate back to the jobs list screen
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeStart,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(AppLocalizations.of(context)!.confirm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQrCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.primaryOrangeStart,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.scanToPay,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.scanToPayInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=omibay_partner_payment',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrangeStart,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.totalAmountToPay,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Text(
                '₹1,499',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaSourceOptions(
    BuildContext context, {
    required String title,
    required Function(String) onImagePicked,
    bool isVideo = false,
  }) {
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
                title,
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
                      icon: isVideo ? Icons.videocam : Icons.camera_alt,
                      label: AppLocalizations.of(context)!.camera,
                      onTap: () async {
                        Navigator.pop(context);
                        final ImagePicker picker = ImagePicker();
                        final XFile? media = isVideo
                            ? await picker.pickVideo(source: ImageSource.camera)
                            : await picker.pickImage(
                                source: ImageSource.camera,
                              );
                        if (media != null) {
                          onImagePicked(media.path);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context)!.files,
                      onTap: () async {
                        Navigator.pop(context);
                        final ImagePicker picker = ImagePicker();
                        final XFile? media = isVideo
                            ? await picker.pickVideo(
                                source: ImageSource.gallery,
                              )
                            : await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                        if (media != null) {
                          onImagePicked(media.path);
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

  Widget _buildMediaUploadButton({
    required IconData icon,
    required String label,
    String? subLabel,
    Color? color,
    String? previewPath,
    bool isVideo = false,
    double? uploadProgress,
    required VoidCallback onTap,
    VoidCallback? onPreviewTap,
    VoidCallback? onCancelTap,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color != null
                        ? color.withValues(alpha: 0.5)
                        : const Color(0xFFF1F5F9),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: color?.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    if (previewPath != null && !isVideo)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                previewPath,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(previewPath),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                      )
                    else
                      Icon(
                        icon,
                        color: color ?? AppColors.primaryOrangeStart,
                        size: 28,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: color ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subLabel != null)
                      Text(
                        subLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    if (uploadProgress != null &&
                        uploadProgress > 0 &&
                        uploadProgress < 1.0)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: uploadProgress,
                                backgroundColor: Colors.grey.shade200,
                                color: AppColors.primaryOrangeStart,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(uploadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrangeStart,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (previewPath != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onCancelTap,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (previewPath != null)
          TextButton.icon(
            onPressed: onPreviewTap,
            icon: const Icon(Icons.visibility_outlined, size: 14),
            label: Text(
              AppLocalizations.of(context)!.preview,
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryOrangeStart,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  void _showFullScreenPreview(
    BuildContext context,
    String path, {
    bool isVideo = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: isVideo
              ? _VideoPlayerWidget(path: path)
              : kIsWeb
              ? Image.network(path)
              : Image.file(File(path)),
        ),
      ),
    );
  }

  void _showPauseWorkPopup(BuildContext context) {
    String? selectedReason;
    final List<String> reasons = [
      AppLocalizations.of(context)!.reasonNeedMaterials,
      AppLocalizations.of(context)!.reasonHealthEmergency,
      AppLocalizations.of(context)!.reasonCustomerRequested,
      AppLocalizations.of(context)!.reasonLunchBreak,
      AppLocalizations.of(context)!.reasonOther,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                AppLocalizations.of(context)!.pauseWorkTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pauseWorkReasonPrompt,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map(
                    (reason) => RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 14)),
                      value: reason,
                      // ignore: deprecated_member_use
                      groupValue: selectedReason,
                      activeColor: AppColors.primaryOrangeStart,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setDialogState(() {
                          selectedReason = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          setState(() {
                            _isPaused = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.workPaused,
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrangeStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.confirmPause),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOtpVerificationPopup(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryOrangeStart,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.verifyOtpTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.enterOtpInstruction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [EnglishDigitFormatter()],
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '0000',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrangeStart,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Mock verification - in real app, verify with backend/booking data
                if (otpController.text == '1234') {
                  Navigator.pop(context);
                  setState(() {
                    _currentStep = 2;
                  });
                  _saveCurrentStep(2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.workStartedSuccess,
                      ),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.invalidOtpTryAgain,
                      ),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.verifyAndStart),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33FF7A00),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.jobDetailsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (_currentStep != 3) _buildHelpButton(context),
        ],
      ),
    );
  }

  Widget _buildHelpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showHelpOptions(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryOrangeStart,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.help,
              style: const TextStyle(
                color: AppColors.primaryOrangeStart,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpOptions(BuildContext context) {
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
                AppLocalizations.of(context)!.howCanWeHelp,
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
                      label: AppLocalizations.of(context)!.chatNow,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/live-chat');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.phone_outlined,
                      label: AppLocalizations.of(context)!.callNow,
                      onTap: () async {
                        Navigator.pop(context);
                        final Uri url = Uri.parse('tel:+918016867006');
                        if (await canLaunchUrl(url)) {
                          if (!context.mounted) return;
                          await launchUrl(url);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.couldNotLaunchDialer,
                              ),
                            ),
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

  Widget _buildServiceTimeline() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkNavyStart,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavyStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep(
                Icons.local_shipping_rounded,
                AppLocalizations.of(context)!.onTheWay,
                _currentStep >= 0,
              ),
              _buildTimelineConnector(_currentStep >= 1),
              _buildTimelineStep(
                Icons.hail_rounded,
                AppLocalizations.of(context)!.arrived,
                _currentStep >= 1,
              ),
              _buildTimelineConnector(_currentStep >= 2),
              _buildTimelineStep(
                Icons.play_circle_filled_rounded,
                AppLocalizations.of(context)!.started,
                _currentStep >= 2,
              ),
              _buildTimelineConnector(_currentStep >= 3),
              _buildTimelineStep(
                Icons.check_circle_rounded,
                AppLocalizations.of(context)!.complete,
                _currentStep >= 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryOrangeStart
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isDone) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isDone
          ? AppColors.primaryOrangeStart
          : Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.customerReview,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < 5 ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 24,
                );
              }),
              const SizedBox(width: 8),
              const Text(
                '5.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.excellentServiceMock,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(Map<String, dynamic>? data) {
    final String timeInfo =
        data?['timeType'] ?? 'Scheduled for 12 Jan, 10:00 AM';
    final bool isScheduled = timeInfo.contains(':');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isScheduled ? Colors.blue : Colors.green).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isScheduled ? Icons.calendar_today : Icons.bolt,
                  color: isScheduled ? Colors.blue : Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.serviceSchedule,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeInfo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeStart.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryOrangeStart,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.reachLocationEarly,
                    style: const TextStyle(
                      color: AppColors.primaryOrangeStart,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedDetails(Map<String, dynamic>? data) {
    final l10n = AppLocalizations.of(context)!;
    final String serviceName = data?['service'] ?? l10n.service;
    final String customerName =
        (data?['customerName'] != null && data?['customerName'] != 'null')
        ? data!['customerName']
        : (data?['customer'] != null && data?['customer'] != 'null')
        ? data!['customer']
        : l10n.mockCustomerName;
    final String price = LocalizationHelper.convertBengaliToEnglish(
      data?['price'] ?? '1,499',
    );
    final String location = data?['location'] ?? l10n.mockFullAddress;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.customerDetailsAndSpecification,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Job Name and Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹$price',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryOrangeStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.serviceLocation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://via.placeholder.com/400x200?text=Location+Map',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue[900],
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Colors.blue[900],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_currentStep != 3)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final String encodedLocation = Uri.encodeComponent(
                          location,
                        );
                        final Uri googleMapsUrl = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$encodedLocation',
                        );
                        if (await canLaunchUrl(googleMapsUrl)) {
                          await launchUrl(
                            googleMapsUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.directions_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.navigate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri telUrl = Uri.parse('tel:+918016867006');
                        if (await canLaunchUrl(telUrl)) {
                          await launchUrl(telUrl);
                        }
                      },
                      icon: const Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        AppLocalizations.of(context)!.callNow,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
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
}

class _VideoPlayerWidget extends StatefulWidget {
  final String path;
  const _VideoPlayerWidget({required this.path});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path));
    } else {
      _controller = VideoPlayerController.file(File(widget.path));
    }

    _controller
        .initialize()
        .then((_) {
          setState(() {});
          _controller.play();
          _controller.setLooping(true);
        })
        .catchError((error) {
          setState(() {
            _isError = true;
          });
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Text(
        'Error loading video',
        style: TextStyle(color: Colors.white),
      );
    }

    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator(
        color: AppColors.primaryOrangeStart,
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
