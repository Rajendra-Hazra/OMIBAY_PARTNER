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
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          '${AppLocalizations.of(context)!.appVersion} 1.0.0',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx < children.length - 1) {
            return Column(
              children: [
                child,
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap:
          onTap ??
          () {
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
    );
  }

  void _showAppearanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.appearances),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.lightMode),
                value: true,
                // ignore: deprecated_member_use
                groupValue: true,
                // ignore: deprecated_member_use
                onChanged: (val) {},
                activeColor: AppColors.primaryOrangeStart,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}
