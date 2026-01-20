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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);

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
            _buildHeader(context, paddingScale, titleFontSize, bodyFontSize),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScheduleSection(
                      effectiveJobData,
                      paddingScale,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    _buildCombinedDetails(
                      effectiveJobData,
                      paddingScale,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    _buildServiceTimeline(
                      paddingScale,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    if (_currentStep == 3)
                      _buildReviewSection(
                        paddingScale,
                        bodyFontSize,
                        smallFontSize,
                      ),
                    _buildSyncActionButton(
                      effectiveJobData,
                      screenWidth,
                      screenHeight,
                      paddingScale,
                      bodyFontSize,
                    ),
                    SizedBox(height: 100 * paddingScale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActionButton(
    Map<String, dynamic>? effectiveJobData,
    double screenWidth,
    double screenHeight,
    double paddingScale,
    double bodyFontSize,
  ) {
    if (_currentStep == 3) return const SizedBox.shrink();

    final buttonPadding = screenWidth * 0.04; // 4% of screen width
    final buttonHeight = screenHeight * 0.065; // 6.5% of screen height

    if (_currentStep == 2) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: buttonPadding,
          vertical: 8 * paddingScale,
        ),
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
                screenWidth: screenWidth,
                screenHeight: screenHeight,
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
                    _showPauseWorkPopup(context, paddingScale, bodyFontSize);
                  }
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildBaseActionButton(
                label: AppLocalizations.of(context)!.markComplete,
                color: AppColors.primaryOrangeStart,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onPressed: () {
                  _showCompletionPopup(
                    context,
                    effectiveJobData,
                    paddingScale,
                    bodyFontSize,
                  );
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
      margin: EdgeInsets.symmetric(
        horizontal: buttonPadding,
        vertical: 8 * paddingScale,
      ),
      height: buttonHeight.clamp(50.0, 60.0),
      child: _buildBaseActionButton(
        label: label,
        color: AppColors.primaryOrangeStart,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        onPressed: () {
          if (_currentStep == 1) {
            _showOtpVerificationPopup(context, paddingScale, bodyFontSize);
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
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onPressed,
  }) {
    final buttonHeight = screenHeight * 0.065; // 6.5% of screen height
    final fontSize = screenWidth * 0.04; // 4% of screen width

    return SizedBox(
      height: buttonHeight.clamp(50.0, 60.0),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize.clamp(14.0, 17.0),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionPopup(
    BuildContext context,
    Map<String, dynamic>? data,
    double paddingScale,
    double bodyFontSize,
  ) {
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
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(16 * paddingScale),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: (64 * paddingScale).clamp(48.0, 80.0),
                        ),
                      ),
                      SizedBox(height: 24 * paddingScale),
                      Text(
                        AppLocalizations.of(context)!.completeJobQuestion,
                        style: TextStyle(
                          fontSize: bodyFontSize + 6,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12 * paddingScale),
                      Text(
                        AppLocalizations.of(context)!.completeJobConfirmation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: bodyFontSize - 2,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24 * paddingScale),
                      Container(
                        padding: EdgeInsets.all(16 * paddingScale),
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: bodyFontSize,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${LocalizationHelper.convertBengaliToEnglish(price)}',
                                style: TextStyle(
                                  fontSize: bodyFontSize + 4,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryOrangeStart,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * paddingScale),
                      // COMPLETION PROOF SECTION
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20 * paddingScale),
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
                                SizedBox(width: 8 * paddingScale),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.completionProof.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: bodyFontSize - 4,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * paddingScale),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMediaUploadButton(
                                    icon: Icons.add_a_photo_outlined,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.addPhoto,
                                    paddingScale: paddingScale,
                                    bodyFontSize: bodyFontSize,
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
                                        paddingScale: paddingScale,
                                        bodyFontSize: bodyFontSize,
                                        onImagePicked: (path) {
                                          setPopupState(() {
                                            pickedPhoto = path;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 12 * paddingScale),
                                Expanded(
                                  child: _buildMediaUploadButton(
                                    icon: Icons.videocam_outlined,
                                    label: AppLocalizations.of(
                                      context,
                                    )!.addVideo,
                                    paddingScale: paddingScale,
                                    bodyFontSize: bodyFontSize,
                                    subLabel: pickedVideo != null
                                        ? null
                                        : AppLocalizations.of(
                                            context,
                                          )!.min10Sec,
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
                                              paddingScale: paddingScale,
                                              bodyFontSize: bodyFontSize,
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
                                                      videoUploadProgress +=
                                                          0.05;
                                                      if (videoUploadProgress >=
                                                          1.0) {
                                                        videoUploadProgress =
                                                            1.0;
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
                      SizedBox(height: 24 * paddingScale),
                      // PAYMENT METHOD SECTION
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20 * paddingScale),
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
                                SizedBox(width: 8 * paddingScale),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.paymentMethod.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: bodyFontSize - 4,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * paddingScale),
                            if (data?['paymentStatus'] == 'Prepaid' ||
                                data?['paymentType'] == 'Prepaid')
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12 * paddingScale,
                                  horizontal: 16 * paddingScale,
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
                                      paddingScale: paddingScale,
                                      bodyFontSize: bodyFontSize,
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
                                  SizedBox(width: 12 * paddingScale),
                                  Expanded(
                                    child: _buildMediaUploadButton(
                                      icon: Icons.qr_code_scanner_rounded,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.showQr,
                                      paddingScale: paddingScale,
                                      bodyFontSize: bodyFontSize,
                                      color: selectedPaymentMethod == 'QR'
                                          ? Colors.green
                                          : null,
                                      onTap: () {
                                        setPopupState(() {
                                          selectedPaymentMethod = 'QR';
                                        });
                                        _showQrCodePopup(
                                          context,
                                          paddingScale,
                                          bodyFontSize,
                                        );
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
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 8 * paddingScale,
                    left: 8 * paddingScale,
                    right: 8 * paddingScale,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: bodyFontSize - 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * paddingScale),
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
                                  String paymentMode;
                                  if (data?['paymentStatus'] == 'Prepaid' ||
                                      data?['paymentType'] == 'Prepaid' ||
                                      selectedPaymentMethod == 'QR') {
                                    paymentMode = 'ONLINE';
                                  } else {
                                    paymentMode = 'COD';
                                  }

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
                                  if (jobId.isNotEmpty) {
                                    await WalletService.removeActiveJob(jobId);
                                  }
                                  await WalletService.clearActiveJob();

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
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeStart,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 12 * paddingScale,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.confirm,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: bodyFontSize,
                            ),
                          ),
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

  void _showQrCodePopup(
    BuildContext context,
    double paddingScale,
    double bodyFontSize,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.primaryOrangeStart,
              size: (24 * paddingScale).clamp(20.0, 30.0),
            ),
            SizedBox(width: 12 * paddingScale),
            Text(
              AppLocalizations.of(context)!.scanToPay,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: bodyFontSize + 2,
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.scanToPayInstructions,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: bodyFontSize - 2,
                  ),
                ),
                SizedBox(height: 24 * paddingScale),
                Container(
                  padding: EdgeInsets.all(16 * paddingScale),
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
                      height: (200 * paddingScale).clamp(150.0, 250.0),
                      width: (200 * paddingScale).clamp(150.0, 250.0),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: (200 * paddingScale).clamp(150.0, 250.0),
                          width: (200 * paddingScale).clamp(150.0, 250.0),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryOrangeStart,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24 * paddingScale),
                Text(
                  AppLocalizations.of(context)!.totalAmountToPay,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: bodyFontSize - 3,
                  ),
                ),
                Text(
                  '₹1,499',
                  style: TextStyle(
                    fontSize: bodyFontSize + 8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
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
                padding: EdgeInsets.symmetric(vertical: 12 * paddingScale),
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaSourceOptions(
    BuildContext context, {
    required String title,
    required double paddingScale,
    required double bodyFontSize,
    required Function(String) onImagePicked,
    bool isVideo = false,
  }) {
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
                title,
                style: TextStyle(
                  fontSize: bodyFontSize + 2,
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
                      icon: isVideo ? Icons.videocam : Icons.camera_alt,
                      label: AppLocalizations.of(context)!.camera,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
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
                  SizedBox(width: 16 * paddingScale),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.photo_library,
                      label: AppLocalizations.of(context)!.files,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
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
    required double paddingScale,
    required double bodyFontSize,
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
                padding: EdgeInsets.symmetric(vertical: 16 * paddingScale),
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
                                height: 40 * paddingScale,
                                width: 40 * paddingScale,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(previewPath),
                                height: 40 * paddingScale,
                                width: 40 * paddingScale,
                                fit: BoxFit.cover,
                              ),
                      )
                    else
                      Icon(
                        icon,
                        color: color ?? AppColors.primaryOrangeStart,
                        size: (28 * paddingScale).clamp(24.0, 36.0),
                      ),
                    SizedBox(height: 8 * paddingScale),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: bodyFontSize - 2,
                        fontWeight: FontWeight.bold,
                        color: color ?? AppColors.textPrimary,
                      ),
                    ),
                    if (subLabel != null)
                      Text(
                        subLabel,
                        style: TextStyle(
                          fontSize: bodyFontSize - 5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    if (uploadProgress != null &&
                        uploadProgress > 0 &&
                        uploadProgress < 1.0)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * paddingScale,
                          left: 16 * paddingScale,
                          right: 16 * paddingScale,
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
                            SizedBox(height: 4 * paddingScale),
                            Text(
                              '${(uploadProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: bodyFontSize - 5,
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
            icon: Icon(
              Icons.visibility_outlined,
              size: (14 * paddingScale).clamp(12.0, 18.0),
            ),
            label: Text(
              AppLocalizations.of(context)!.preview,
              style: TextStyle(fontSize: bodyFontSize - 3),
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

  void _showPauseWorkPopup(
    BuildContext context,
    double paddingScale,
    double bodyFontSize,
  ) {
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize + 2,
                ),
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.pauseWorkReasonPrompt,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: bodyFontSize - 2,
                        ),
                      ),
                      SizedBox(height: 16 * paddingScale),
                      ...reasons.map(
                        (reason) => RadioListTile<String>(
                          title: Text(
                            reason,
                            style: TextStyle(fontSize: bodyFontSize - 2),
                          ),
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: bodyFontSize - 1,
                    ),
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
                  child: Text(
                    AppLocalizations.of(context)!.confirmPause,
                    style: TextStyle(fontSize: bodyFontSize - 1),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOtpVerificationPopup(
    BuildContext context,
    double paddingScale,
    double bodyFontSize,
  ) {
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
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryOrangeStart,
                size: (48 * paddingScale).clamp(40.0, 56.0),
              ),
              SizedBox(height: 16 * paddingScale),
              Text(
                AppLocalizations.of(context)!.verifyOtpTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize + 2,
                ),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: bodyFontSize - 2,
                  ),
                ),
                SizedBox(height: 24 * paddingScale),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [EnglishDigitFormatter()],
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (24 * paddingScale).clamp(20.0, 32.0),
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: bodyFontSize - 1,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
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
              child: Text(
                AppLocalizations.of(context)!.verifyAndStart,
                style: TextStyle(fontSize: bodyFontSize - 1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double paddingScale,
    double titleFontSize,
    double bodyFontSize,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (10 * paddingScale),
        left: 10 * paddingScale,
        right: 20 * paddingScale,
        bottom: 20 * paddingScale,
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
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: (20 * paddingScale).clamp(18.0, 24.0),
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.jobDetailsTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (_currentStep != 3)
            _buildHelpButton(context, paddingScale, bodyFontSize),
        ],
      ),
    );
  }

  Widget _buildHelpButton(
    BuildContext context,
    double paddingScale,
    double bodyFontSize,
  ) {
    return GestureDetector(
      onTap: () {
        _showHelpOptions(context, paddingScale, bodyFontSize);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * paddingScale,
          vertical: 8 * paddingScale,
        ),
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
            Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryOrangeStart,
              size: (18 * paddingScale).clamp(16.0, 22.0),
            ),
            SizedBox(width: 6 * paddingScale),
            Text(
              AppLocalizations.of(context)!.help,
              style: TextStyle(
                color: AppColors.primaryOrangeStart,
                fontWeight: FontWeight.bold,
                fontSize: bodyFontSize - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpOptions(
    BuildContext context,
    double paddingScale,
    double bodyFontSize,
  ) {
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
                AppLocalizations.of(context)!.howCanWeHelp,
                style: TextStyle(
                  fontSize: bodyFontSize + 4,
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
                      label: AppLocalizations.of(context)!.chatNow,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/live-chat');
                      },
                    ),
                  ),
                  SizedBox(width: 16 * paddingScale),
                  Expanded(
                    child: _buildHelpOption(
                      context,
                      icon: Icons.phone_outlined,
                      label: AppLocalizations.of(context)!.callNow,
                      paddingScale: paddingScale,
                      bodyFontSize: bodyFontSize,
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

  Widget _buildServiceTimeline(
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.04; // 4% of screen width
    final verticalPadding =
        MediaQuery.of(context).size.height * 0.025; // 2.5% of screen height

    return Container(
      margin: EdgeInsets.fromLTRB(horizontalMargin, 20, horizontalMargin, 16),
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.05; // 5% of screen width
    final fontSize = screenWidth * 0.024; // 2.4% of screen width

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(iconSize * 0.5),
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
              size: iconSize.clamp(18.0, 22.0),
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
              fontSize: fontSize.clamp(9.0, 11.0),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isDone) {
    final screenWidth = MediaQuery.of(context).size.width;
    final connectorWidth = screenWidth * 0.04; // 4% of screen width

    return Container(
      width: connectorWidth.clamp(16.0, 24.0),
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isDone
          ? AppColors.primaryOrangeStart
          : Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildReviewSection(
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.04; // 4% of screen width
    final padding = screenWidth * 0.05; // 5% of screen width

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 12),
      padding: EdgeInsets.all(padding),
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

  Widget _buildScheduleSection(
    Map<String, dynamic>? data,
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final String timeInfo =
        data?['timeType'] ?? 'Scheduled for 12 Jan, 10:00 AM';
    final bool isScheduled = timeInfo.contains(':');

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin = screenWidth * 0.04; // 4% of screen width
    final padding = screenWidth * 0.05; // 5% of screen width
    final iconSize = screenWidth * 0.06; // 6% of screen width
    final titleFontSize = screenWidth * 0.045; // 4.5% of screen width

    return Container(
      margin: EdgeInsets.all(horizontalMargin),
      padding: EdgeInsets.all(padding),
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
                padding: EdgeInsets.all(iconSize * 0.4),
                decoration: BoxDecoration(
                  color: (isScheduled ? Colors.blue : Colors.green).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isScheduled ? Icons.calendar_today : Icons.bolt,
                  color: isScheduled ? Colors.blue : Colors.green,
                  size: iconSize.clamp(20.0, 26.0),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
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
                      style: TextStyle(
                        fontSize: titleFontSize.clamp(16.0, 20.0),
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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 12,
            ),
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

  Widget _buildCombinedDetails(
    Map<String, dynamic>? data,
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalMargin = screenWidth * 0.04; // 4% of screen width
    final padding = screenWidth * 0.05; // 5% of screen width
    final serviceFontSize = screenWidth * 0.045; // 4.5% of screen width
    final priceFontSize = screenWidth * 0.05; // 5% of screen width
    final mapHeight = screenHeight * 0.18; // 18% of screen height
    final buttonHeight = screenHeight * 0.06; // 6% of screen height

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 12),
      padding: EdgeInsets.all(padding),
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
                      style: TextStyle(
                        fontSize: serviceFontSize.clamp(16.0, 20.0),
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
                style: TextStyle(
                  fontSize: priceFontSize.clamp(18.0, 22.0),
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
                  height: mapHeight.clamp(140.0, 180.0),
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
                    height: buttonHeight.clamp(48.0, 56.0),
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
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Container(
                    height: buttonHeight.clamp(48.0, 56.0),
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
