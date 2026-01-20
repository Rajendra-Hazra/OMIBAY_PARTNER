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
      _currentLanguage = savedLanguage == 'bn'
          ? AppLocalizations.of(context)!.bengali
          : AppLocalizations.of(context)!.english;
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.preferences,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.language,
                          AppLocalizations.of(context)!.appLanguage,
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
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.palette_outlined,
                          AppLocalizations.of(context)!.appearances,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.light,
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            _showAppearanceDialog(context);
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.notifications_active_outlined,
                          AppLocalizations.of(context)!.pushNotifications,
                          trailing: Switch.adaptive(
                            value: _pushNotifications,
                            onChanged: _toggleNotifications,
                            activeTrackColor: AppColors.primaryOrangeStart,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.accountSafety,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.pause_circle_outline,
                          AppLocalizations.of(context)!.deactivateAccount,
                          route: '/deactivate-account',
                          iconColor: Colors.orange,
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.delete_forever_outlined,
                          AppLocalizations.of(context)!.deleteAccount,
                          route: '/delete-account',
                          iconColor: Colors.red,
                          textColor: Colors.red,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        AppLocalizations.of(context)!.legalDocuments,
                      ),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          context,
                          Icons.article_outlined,
                          AppLocalizations.of(context)!.termsAndConditions,
                          route: '/terms',
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.privacy_tip_outlined,
                          AppLocalizations.of(context)!.privacyPolicy,
                          route: '/privacy',
                        ),
                        _buildSettingsTile(
                          context,
                          Icons.block_outlined,
                          AppLocalizations.of(context)!.suspensionPolicy,
                          route: '/suspension-policy',
                        ),
                      ]),
                      const SizedBox(height: 48),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildHeader(BuildContext context) {
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
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
              AppLocalizations.of(context)!.settings,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
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
    String title, {
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
        onTap: onTap ??
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
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
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
                          AppColors.primaryOrangeStart.withValues(alpha: 0.15),
                          AppColors.primaryOrangeEnd.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_outlined,
                      color: AppColors.primaryOrangeStart,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.appearances,
                      style: const TextStyle(
                        fontSize: 20,
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
                      const Icon(
                        Icons.light_mode,
                        color: AppColors.primaryOrangeStart,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.lightMode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  value: true,
                  groupValue: true,
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
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrangeStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
