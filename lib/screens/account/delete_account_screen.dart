import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinput/pinput.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _understandCheck = false;
  bool _isDeleting = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear EVERYTHING for real deletion

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeletedSuccess),
          backgroundColor: Colors.red,
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
    final hPadding = 24.0 * paddingScale;
    final vPadding = 24.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final buttonHeight = (screenHeight * 0.06).clamp(55.0, 65.0);

    return Scaffold(
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
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.red.shade700,
                            size: iconSize,
                          ),
                          SizedBox(width: 12 * paddingScale),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.deleteAccountCaution,
                              style: TextStyle(
                                fontSize: smallFontSize,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32 * paddingScale),
                    Center(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: (screenWidth * 0.2).clamp(60.0, 100.0),
                      ),
                    ),
                    SizedBox(height: 24 * paddingScale),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.sorryToSeeYouGo,
                        style: TextStyle(
                          fontSize: bodyFontSize + 4,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 32 * paddingScale),
                    Text(
                      AppLocalizations.of(context)!.deletingPermanent,
                      style: TextStyle(
                        fontSize: bodyFontSize + 1,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 16 * paddingScale),
                    _buildWarningItem(
                      AppLocalizations.of(context)!.deletePoint1,
                      bodyFontSize,
                      iconSize,
                    ),
                    _buildWarningItem(
                      AppLocalizations.of(context)!.deletePoint2,
                      bodyFontSize,
                      iconSize,
                    ),
                    _buildWarningItem(
                      AppLocalizations.of(context)!.deletePoint3,
                      bodyFontSize,
                      iconSize,
                    ),
                    _buildWarningItem(
                      AppLocalizations.of(context)!.deletePoint4,
                      bodyFontSize,
                      iconSize,
                    ),
                    SizedBox(height: 40 * paddingScale),
                    Container(
                      padding: EdgeInsets.all(12 * paddingScale),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: paddingScale.clamp(0.8, 1.0),
                            child: Checkbox(
                              value: _understandCheck,
                              activeColor: Colors.red,
                              onChanged: (val) => setState(
                                () => _understandCheck = val ?? false,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.understandIrreversible,
                              style: TextStyle(
                                fontSize: smallFontSize,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48 * paddingScale),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: (_understandCheck && !_isDeleting)
                            ? () => _showConfirmDialog(
                                bodyFontSize,
                                smallFontSize,
                                paddingScale,
                              )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrangeStart,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryOrangeStart
                              .withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isDeleting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                AppLocalizations.of(context)!.deletePermanently,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize + 1,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16 * paddingScale),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.changedMyMind,
                          style: TextStyle(fontSize: bodyFontSize),
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
              AppLocalizations.of(context)!.deleteAccount,
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

  Widget _buildWarningItem(String text, double fontSize, double iconSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel, color: Colors.red, size: iconSize * 0.9),
          const SizedBox(width: 12),
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

  void _showConfirmDialog(
    double bodyFontSize,
    double smallFontSize,
    double paddingScale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.finalWarning,
          style: TextStyle(
            fontSize: bodyFontSize + 2,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.finalWarningContent,
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showOtpDialog(bodyFontSize, smallFontSize, paddingScale);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              AppLocalizations.of(context)!.yes,
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
          AppLocalizations.of(context)!.verifyPermanentDeletion,
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
                AppLocalizations.of(context)!.enterOtpDeletePermanent,
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
                  style: TextStyle(color: Colors.red, fontSize: smallFontSize),
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
                _handleDelete();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.invalidOtpDemo),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.deletePermanently,
              style: TextStyle(fontSize: bodyFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
