import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';
import '../../l10n/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _displayName = '';
  String _photoUrl = '';
  String _partnerId = '';
  String _phone = '';
  double _rating = 0.0;
  int _completedJobs = 0;
  String _tenureDisplay = '';

  @override
  void initState() {
    super.initState();
    // Initial assignment will be done in didChangeDependencies since we need context for l10n
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_displayName.isEmpty) _displayName = l10n.partner;
    if (_photoUrl.isEmpty) _photoUrl = l10n.placeholderPhotoUrl;
    _loadProfileData();
  }

  @override
  void dispose() {
    AppColors.profileUpdateNotifier.removeListener(_loadProfileData);
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final savedName = prefs.getString('profile_name');
      final savedPhotoPath =
          prefs.getString('profile_photo_path') ??
          prefs.getString('profile_local_photo');
      final savedPhone = prefs.getString('profile_phone');
      final savedId =
          prefs.getString('profile_referral_code') ??
          prefs.getString('profile_id') ??
          '';

      final savedRating = prefs.getString('profile_rating');
      final completedJobsList =
          prefs.getStringList('completed_jobs_list') ?? [];
      final accessDateStr = prefs.getString('partner_access_date');
      String tenure = l10n.notAvailable;
      if (accessDateStr != null) {
        final accessDate = DateTime.parse(accessDateStr);
        final now = DateTime.now();
        int years = now.year - accessDate.year;
        int months = now.month - accessDate.month;
        if (now.day < accessDate.day) months--;
        if (months < 0) {
          years--;
          months += 12;
        }

        if (years > 0) {
          tenure = '$years Yr';
        } else if (months > 0) {
          tenure = '$months Mo';
        } else {
          tenure = l10n.newLabel;
        }
      }

      setState(() {
        if (savedName != null && savedName.isNotEmpty) {
          _displayName = LocalizationHelper.getLocalizedCustomerName(
            context,
            savedName,
          );
        } else {
          _displayName = l10n.partner;
        }
        if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
          _photoUrl = savedPhotoPath;
        } else {
          _photoUrl = l10n.placeholderPhotoUrl;
        }
        if (savedPhone != null && savedPhone.isNotEmpty) {
          _phone = savedPhone.startsWith(l10n.indiaCountryCode)
              ? savedPhone
              : '${l10n.indiaCountryCode} $savedPhone';
        } else {
          _phone = '';
        }
        _partnerId = savedId;

        if (savedRating != null) {
          _rating = double.tryParse(savedRating) ?? 0.0;
        }
        _completedJobs = completedJobsList.length;
        _tenureDisplay = tenure;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 20),
                      _buildStatsSection(context),
                      const SizedBox(height: 20),
                      _buildQuickActionGrid(context),
                      const SizedBox(height: 24),
                      _buildAccountSettingsSection(context),
                      const SizedBox(height: 24),
                      Text(
                        '${AppLocalizations.of(context)!.version} ${AppLocalizations.of(context)!.appVersionValue}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
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

  Widget _buildStatsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final verticalPadding =
        MediaQuery.of(context).size.height * 0.025; // 2.5% of screen height
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    final iconPadding = screenWidth * 0.01; // 1% of screen width
    final iconSize = screenWidth * 0.035; // 3.5% of screen width
    final valueFontSize = screenWidth * 0.045; // 4.5% of screen width
    final labelFontSize = screenWidth * 0.028; // 2.8% of screen width

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding.clamp(16.0, 24.0),
        horizontal: horizontalPadding.clamp(12.0, 20.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            _rating > 0 ? _rating.toString() : l10n.notAvailable,
            l10n.rating,
            Icons.star_rounded,
            Colors.amber,
            iconPadding: iconPadding,
            iconSize: iconSize,
            valueFontSize: valueFontSize,
            labelFontSize: labelFontSize,
          ),
          _buildStatDivider(),
          _buildStatItem(
            context,
            _completedJobs.toString(),
            l10n.jobsDone,
            Icons.check_circle_rounded,
            AppColors.successGreen,
            iconPadding: iconPadding,
            iconSize: iconSize,
            valueFontSize: valueFontSize,
            labelFontSize: labelFontSize,
          ),
          _buildStatDivider(),
          _buildStatItem(
            context,
            _tenureDisplay.isNotEmpty ? _tenureDisplay : l10n.notAvailable,
            l10n.workWithUs,
            Icons.timer_rounded,
            Colors.blue,
            iconPadding: iconPadding,
            iconSize: iconSize,
            valueFontSize: valueFontSize,
            labelFontSize: labelFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color, {
    required double iconPadding,
    required double iconSize,
    required double valueFontSize,
    required double labelFontSize,
  }) {
    return Flexible(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding.clamp(3.0, 5.0)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize.clamp(13.0, 16.0),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize.clamp(16.0, 20.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize.clamp(10.0, 12.0),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(20.0, 28.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 25,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4DFF7A00),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.myAccount,
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.06).clamp(22.0, 26.0),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final padding = (screenWidth * 0.06).clamp(20.0, 28.0);
    final avatarRadius = (screenWidth * 0.11).clamp(38.0, 48.0);
    final avatarBorderWidth = (screenWidth * 0.008).clamp(2.5, 4.0);
    final nameSpacing = (screenWidth * 0.05).clamp(16.0, 24.0);
    final nameFontSize = (screenWidth * 0.055).clamp(20.0, 24.0);
    final iconSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final detailsFontSize = (screenWidth * 0.033).clamp(12.0, 14.0);
    final decorCircleSize = (screenHeight * 0.15).clamp(100.0, 140.0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavyStart.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: decorCircleSize.clamp(100.0, 140.0),
                height: decorCircleSize.clamp(100.0, 140.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(avatarBorderWidth),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrangeStart,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      backgroundImage: _photoUrl.startsWith('http')
                          ? NetworkImage(_photoUrl)
                          : FileImage(File(_photoUrl)) as ImageProvider,
                    ),
                  ),
                  SizedBox(width: nameSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _displayName,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified_rounded,
                              color: Colors.blue,
                              size: (iconSize * 1.4).clamp(18.0, 22.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              color: Colors.white70,
                              size: iconSize,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.partnerId} ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: detailsFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _partnerId.isNotEmpty
                                    ? _partnerId
                                    : l10n.notAvailable,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: detailsFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android_rounded,
                              color: Colors.white70,
                              size: iconSize,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _phone.isNotEmpty ? _phone : l10n.notAvailable,
                                style: TextStyle(
                                  fontSize: detailsFontSize,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                context,
                Icons.account_balance_wallet_rounded,
                AppLocalizations.of(context)!.paymentMethod,
                const Color(0xFF6366F1),
                () => Navigator.pushNamed(context, '/payment-setup'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionItem(
                context,
                Icons.description_rounded,
                AppLocalizations.of(context)!.myDocuments,
                const Color(0xFFEC4899),
                () => Navigator.pushNamed(
                  context,
                  '/documents',
                  arguments: {'hideHelp': true},
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                context,
                Icons.build_circle_rounded,
                AppLocalizations.of(context)!.myServices,
                const Color(0xFFF59E0B),
                () => Navigator.pushNamed(
                  context,
                  '/edit-services',
                  arguments: {'hideHelp': true},
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionItem(
                context,
                Icons.help_center_rounded,
                AppLocalizations.of(context)!.helpCenter,
                const Color(0xFF10B981),
                () => Navigator.pushNamed(context, '/support'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.accountAndSettings,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                context,
                Icons.person_outline_rounded,
                AppLocalizations.of(context)!.editProfile,
                '',
                Colors.blue,
                route: '/edit-profile',
              ),
              _buildSettingsDivider(),
              _buildSettingsTile(
                context,
                Icons.location_on_outlined,
                AppLocalizations.of(context)!.manageLocation,
                '',
                Colors.orange,
                route: '/location-selection',
              ),
              _buildSettingsDivider(),
              _buildSettingsTile(
                context,
                Icons.security_rounded,
                AppLocalizations.of(context)!.managePermission,
                '',
                Colors.purple,
                route: '/permissions',
              ),
              _buildSettingsDivider(),
              _buildSettingsTile(
                context,
                Icons.share_rounded,
                AppLocalizations.of(context)!.referAndEarn,
                '',
                Colors.pink,
                route: '/referral',
              ),
              _buildSettingsDivider(),
              _buildSettingsTile(
                context,
                Icons.settings_outlined,
                AppLocalizations.of(context)!.settings,
                '',
                Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String trailingText,
    Color color, {
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText.isNotEmpty)
            Text(
              trailingText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
        ],
      ),
      onTap:
          onTap ??
          () {
            if (route != null) {
              Navigator.pushNamed(
                context,
                route,
                arguments: {'hideHelp': true},
              );
            }
          },
    );
  }

  Widget _buildLogoutButton() {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = (screenHeight * 0.065).clamp(56.0, 64.0);

    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorRedAlt.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () async {
            // Show confirmation
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(AppLocalizations.of(context)!.logoutConfirmation),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRedAlt,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.logout),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              // Clear login status
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              // Optionally clear other session data but keep profile for return
              await prefs.remove('login_method');

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            }
          },
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
          label: Text(
            AppLocalizations.of(context)!.logout,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorRedAlt,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
