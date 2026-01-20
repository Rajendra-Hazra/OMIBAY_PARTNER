import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinput/pinput.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';

class DeactivateAccountScreen extends StatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  State<DeactivateAccountScreen> createState() =>
      _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState extends State<DeactivateAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isConfirming = false;
  String? _selectedReason;

  List<String> get _deactivationReasons => [
    AppLocalizations.of(context)!.reasonBreak,
    AppLocalizations.of(context)!.reasonNotifications,
    AppLocalizations.of(context)!.reasonOpportunities,
    AppLocalizations.of(context)!.reasonTechnical,
    AppLocalizations.of(context)!.reasonPrivacy,
    AppLocalizations.of(context)!.reasonOther,
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleDeactivate() async {
    setState(() => _isConfirming = true);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('login_method');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.accountDeactivatedSuccess,
          ),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final vPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final buttonHeight = (screenHeight * 0.06).clamp(50.0, 60.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, titleFontSize, iconSize),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: vPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16 * paddingScale),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: iconSize,
                          ),
                          SizedBox(width: 12 * paddingScale),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.deactivationWarning,
                              style: TextStyle(
                                fontSize: smallFontSize,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * paddingScale),
                    Text(
                      AppLocalizations.of(context)!.whyDeactivating,
                      style: TextStyle(
                        fontSize: bodyFontSize + 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12 * paddingScale),
                    Column(
                      children: _deactivationReasons.map((reason) {
                        return RadioListTile<String>(
                          title: Text(
                            reason,
                            style: TextStyle(fontSize: bodyFontSize),
                          ),
                          value: reason,
                          // ignore: deprecated_member_use
                          groupValue: _selectedReason,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          activeColor: Colors.orange,
                          dense: true,
                        );
                      }).toList(),
                    ),
                    if (_selectedReason ==
                        AppLocalizations.of(context)!.reasonOther)
                      Padding(
                        padding: EdgeInsets.only(top: 12 * paddingScale),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          style: TextStyle(fontSize: bodyFontSize),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.pleaseTellMore,
                            hintStyle: TextStyle(fontSize: smallFontSize),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    SizedBox(height: 32 * paddingScale),
                    Text(
                      AppLocalizations.of(context)!.whatHappensDeactivate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize,
                      ),
                    ),
                    SizedBox(height: 12 * paddingScale),
                    _buildBulletPoint(
                      AppLocalizations.of(context)!.deactivatePoint1,
                      bodyFontSize,
                    ),
                    _buildBulletPoint(
                      AppLocalizations.of(context)!.deactivatePoint2,
                      bodyFontSize,
                    ),
                    _buildBulletPoint(
                      AppLocalizations.of(context)!.deactivatePoint3,
                      bodyFontSize,
                    ),
                    _buildBulletPoint(
                      AppLocalizations.of(context)!.deactivatePoint4,
                      bodyFontSize,
                    ),
                    SizedBox(height: 48 * paddingScale),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isConfirming
                            ? null
                            : () => _showConfirmationDialog(
                                bodyFontSize,
                                smallFontSize,
                                paddingScale,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isConfirming
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(
                                  context,
                                )!.deactivateMyAccount,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize + 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 20,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.deactivateAccount,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    double bodyFontSize,
    double smallFontSize,
    double paddingScale,
  ) {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectReason),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.confirmDeactivation,
          style: TextStyle(
            fontSize: bodyFontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.areYouSureDeactivate,
          style: TextStyle(fontSize: bodyFontSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontSize: bodyFontSize, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showOtpDialog(bodyFontSize, smallFontSize, paddingScale);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(
                fontSize: bodyFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog(
    double bodyFontSize,
    double smallFontSize,
    double paddingScale,
  ) {
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.verifyDeactivation,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: bodyFontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.enterOtpDeactivate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: smallFontSize,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24 * paddingScale),
              Pinput(
                length: 6,
                controller: _otpController,
                inputFormatters: [EnglishDigitFormatter()],
                defaultPinTheme: PinTheme(
                  width: 40 * paddingScale,
                  height: 45 * paddingScale,
                  textStyle: TextStyle(
                    fontSize: 18 * paddingScale,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20 * paddingScale),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.otpResent),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.resendOtp,
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: smallFontSize,
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
              style: TextStyle(fontSize: bodyFontSize, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_otpController.text == '123456') {
                Navigator.pop(context);
                _handleDeactivate();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.invalidOtpDemo),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.verifyAndDeactivate,
              style: TextStyle(fontSize: bodyFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
