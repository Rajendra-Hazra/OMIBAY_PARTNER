import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = false;
  String _currentLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
    _loadCurrentLanguage();
    // Listen for language changes
    LocaleNotifier.instance.addListener(_loadCurrentLanguage);
  }

  @override
  void dispose() {
    LocaleNotifier.instance.removeListener(_loadCurrentLanguage);
    super.dispose();
  }

  Future<void> _loadCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'en';
    setState(() {
      // Show language name in its native script
      _currentLanguage = savedLanguage == 'bn' ? 'বাংলা' : 'English';
    });
  }

  Future<void> _loadNotificationStatus() async {
    final status = await Permission.notification.status;
    setState(() {
      _pushNotifications = status.isGranted;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      setState(() {
        _pushNotifications = status.isGranted;
      });
      if (!status.isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseEnableNotificationPermission,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _pushNotifications = false;
      });
      // Note: You can't actually "un-grant" a permission programmatically in Android/iOS.
      // We just update the local UI state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(16.0, 24.0);
    final titleFontSize = (screenWidth * 0.06).clamp(20.0, 26.0);
    final bodyFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, titleFontSize, iconSize),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.preferences,
                        smallFontSize,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.language,
                          AppLocalizations.of(context)!.appLanguage,
                          bodyFontSize,
                          iconSize,
                          route: '/language',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentLanguage,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: smallFontSize + 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: iconSize * 0.7,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.palette_outlined,
                          AppLocalizations.of(context)!.appearances,
                          bodyFontSize,
                          iconSize,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.light,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: smallFontSize + 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: iconSize * 0.7,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            _showAppearanceDialog(
                              context,
                              bodyFontSize,
                              iconSize,
                            );
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.notifications_active_outlined,
                          AppLocalizations.of(context)!.pushNotifications,
                          bodyFontSize,
                          iconSize,
                          trailing: Transform.scale(
                            scale: (screenWidth / 400).clamp(0.8, 1.0),
                            child: Switch.adaptive(
                              value: _pushNotifications,
                              onChanged: _toggleNotifications,
                              activeTrackColor: AppColors.primaryOrangeStart,
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: verticalPadding),
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.accountSafety,
                        smallFontSize,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.pause_circle_outline,
                          AppLocalizations.of(context)!.deactivateAccount,
                          bodyFontSize,
                          iconSize,
                          route: '/deactivate-account',
                          iconColor: Colors.orange,
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.delete_forever_outlined,
                          AppLocalizations.of(context)!.deleteAccount,
                          bodyFontSize,
                          iconSize,
                          route: '/delete-account',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                        ),
                      ]),
                      SizedBox(height: verticalPadding),
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.legalDocuments,
                        smallFontSize,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.article_outlined,
                          AppLocalizations.of(context)!.termsAndConditions,
                          bodyFontSize,
                          iconSize,
                          route: '/terms',
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.privacy_tip_outlined,
                          AppLocalizations.of(context)!.privacyPolicy,
                          bodyFontSize,
                          iconSize,
                          route: '/privacy',
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.block_outlined,
                          AppLocalizations.of(context)!.suspensionPolicy,
                          bodyFontSize,
                          iconSize,
                          route: '/suspension-policy',
                        ),
                      ]),
                      SizedBox(height: verticalPadding * 2),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.appVersion} 1.0.0',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: smallFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: verticalPadding),
                    ],
                  ),
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
        right: 16,
        bottom: 16,
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: iconSize * 0.7,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.settings,
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

  Widget _buildSectionHeader(String title, double smallFontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx < children.length - 1) {
            return Column(
              children: [
                child,
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
              ],
            );
          }
          return child;
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    double bodyFontSize,
    double iconSize, {
    String? route,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? AppColors.primaryOrangeStart;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (route != null) {
                Navigator.pushNamed(context, route);
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      effectiveIconColor.withValues(alpha: 0.15),
                      effectiveIconColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: iconSize * 0.8,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceDialog(
    BuildContext context,
    double bodyFontSize,
    double iconSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryOrangeStart.withValues(
                              alpha: 0.15,
                            ),
                            AppColors.primaryOrangeEnd.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: AppColors.primaryOrangeStart,
                        size: iconSize * 0.8,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.appearances,
                        style: TextStyle(
                          fontSize: bodyFontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: RadioListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: AppColors.primaryOrangeStart,
                          size: iconSize * 0.7,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.lightMode,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: bodyFontSize,
                          ),
                        ),
                      ],
                    ),
                    value: true,
                    // ignore: deprecated_member_use
                    groupValue: true,
                    // ignore: deprecated_member_use
                    onChanged: (val) {},
                    activeColor: AppColors.primaryOrangeStart,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.height * 0.06).clamp(
                    48.0,
                    56.0,
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrangeStart,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.close,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
