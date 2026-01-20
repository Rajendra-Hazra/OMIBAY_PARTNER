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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigate back to Home tab (index 0)
        Navigator.pushReplacementNamed(context, '/home');
      },
      child: Scaffold(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
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
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          ),
          _buildStatDivider(),
          _buildStatItem(
            context,
            _completedJobs.toString(),
            l10n.jobsDone,
            Icons.check_circle_rounded,
            AppColors.successGreen,
          ),
          _buildStatDivider(),
          _buildStatItem(
            context,
            _tenureDisplay.isNotEmpty ? _tenureDisplay : l10n.notAvailable,
            l10n.workWithUs,
            Icons.timer_rounded,
            Colors.blue,
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
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
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
          Text(
            AppLocalizations.of(context)!.myAccount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrangeStart,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      backgroundImage: _photoUrl.startsWith('http')
                          ? NetworkImage(_photoUrl)
                          : FileImage(File(_photoUrl)) as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified_rounded,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${l10n.partnerId} ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _partnerId.isNotEmpty
                                  ? _partnerId
                                  : l10n.notAvailable,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _phone.isNotEmpty ? _phone : l10n.notAvailable,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
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
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
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
            padding: const EdgeInsets.symmetric(vertical: 15),
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
