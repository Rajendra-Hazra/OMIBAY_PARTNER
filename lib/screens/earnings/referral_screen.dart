import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';
import '../../l10n/app_localizations.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = 'APNA500';
  int _totalReferrals = 0;
  double _totalReferralEarnings = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode =
          prefs.getString('profile_referral_code') ??
          prefs.getString('profile_id') ??
          'APNA500';
      final savedCount = prefs.getInt('total_referrals') ?? 0;
      final savedEarnings = prefs.getDouble('total_referral_earnings') ?? 0.0;

      if (mounted) {
        setState(() {
          _referralCode = savedCode;
          _totalReferrals = savedCount;
          _totalReferralEarnings = savedEarnings;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading referral data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
    final borderRadius = (screenWidth * 0.06).clamp(16.0, 24.0);
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
        child: Column(
          children: [
            // Custom Header
            _buildHeader(context, titleFontSize, borderRadius, hPadding),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeroSection(
                      borderRadius,
                      titleFontSize,
                      bodyFontSize,
                    ),
                    Padding(
                      padding: EdgeInsets.all(hPadding),
                      child: Column(
                        children: [
                          _buildCodeContainer(
                            context,
                            borderRadius,
                            bodyFontSize,
                            smallFontSize,
                          ),
                          SizedBox(height: 24 * paddingScale),
                          _buildHowItWorks(bodyFontSize, smallFontSize),
                          SizedBox(height: 24 * paddingScale),
                          _buildStatsSection(
                            borderRadius,
                            bodyFontSize,
                            smallFontSize,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: _buildBottomAction(
          context,
          buttonHeight,
          bodyFontSize,
          smallFontSize,
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
        left: horizontalPadding * 0.5,
        right: horizontalPadding,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.referAndEarn,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    double borderRadius,
    double titleFontSize,
    double bodyFontSize,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people,
              color: Colors.white,
              size: titleFontSize * 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.referHeroTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.referHeroSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: bodyFontSize * 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeContainer(
    BuildContext context,
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.yourReferralCode,
            style: TextStyle(
              fontSize: smallFontSize * 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _referralCode,
                    style: TextStyle(
                      fontSize: bodyFontSize * 2,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: AppColors.primaryOrangeStart,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.codeCopied),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy,
                  color: AppColors.textSecondary,
                  size: bodyFontSize * 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(double titleFontSize, double bodyFontSize) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.howItWorks,
          style: TextStyle(
            fontSize: titleFontSize * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildStepItem(
          1,
          l10n.step1Title,
          l10n.step1Desc,
          titleFontSize,
          bodyFontSize,
        ),
        _buildStepItem(
          2,
          l10n.step2Title,
          l10n.step2Desc,
          titleFontSize,
          bodyFontSize,
        ),
        _buildStepItem(
          3,
          l10n.step3Title,
          l10n.step3Desc,
          titleFontSize,
          bodyFontSize,
        ),
      ],
    );
  }

  Widget _buildStepItem(
    int num,
    String title,
    String desc,
    double titleFontSize,
    double bodyFontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: titleFontSize * 1.5,
            height: titleFontSize * 1.5,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primaryOrangeStart,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$num',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFontSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: bodyFontSize * 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildStatBox(
          LocalizationHelper.convertBengaliToEnglish('$_totalReferrals'),
          l10n.totalReferrals,
          borderRadius,
          bodyFontSize,
          smallFontSize,
        ),
        const SizedBox(width: 16),
        _buildStatBox(
          LocalizationHelper.convertBengaliToEnglish(
            '₹${_totalReferralEarnings.toStringAsFixed(0)}',
          ),
          l10n.totalEarned,
          borderRadius,
          bodyFontSize,
          smallFontSize,
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String val,
    String label,
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius * 0.6),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                val,
                style: TextStyle(
                  fontSize: bodyFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: smallFontSize,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    double buttonHeight,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () {
                // ignore: deprecated_member_use
                Share.share(
                  AppLocalizations.of(
                    context,
                  )!.referralShareMessage(_referralCode),
                );
              },
              icon: Icon(Icons.share, size: bodyFontSize * 1.25),
              label: Text(
                AppLocalizations.of(context)!.shareCode,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showTermsPopup(context, bodyFontSize),
            child: Text(
              AppLocalizations.of(context)!.termsOfService,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: smallFontSize,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsPopup(BuildContext context, double fontSize) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.referralTermsTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize * 1.2,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTermPoint(l10n.referralTermsPoint1, fontSize),
                _buildTermPoint(l10n.referralTermsPoint2, fontSize),
                _buildTermPoint(l10n.referralTermsPoint3, fontSize),
                _buildTermPoint(l10n.referralTermsPoint4, fontSize),
                _buildTermPoint(l10n.referralTermsPoint5, fontSize),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.close,
                style: TextStyle(
                  color: AppColors.primaryOrangeStart,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermPoint(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
              style: TextStyle(fontSize: fontSize * 0.85, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
