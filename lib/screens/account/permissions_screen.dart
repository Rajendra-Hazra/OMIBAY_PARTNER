import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> _statuses = {};
  bool _hideHelp = false;

  final List<Permission> _permissions = [
    Permission.locationAlways,
    Permission.ignoreBatteryOptimizations,
    Permission.systemAlertWindow,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('hideHelp')) {
      _hideHelp = args['hideHelp'] as bool;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    if (!kIsWeb) {
      for (var permission in _permissions) {
        // Special handling for battery optimization to ensure real-time accuracy
        if (permission == Permission.ignoreBatteryOptimizations) {
          final isOptimized = await permission.isGranted;
          statuses[permission] = isOptimized
              ? PermissionStatus.granted
              : PermissionStatus.denied;
        } else {
          statuses[permission] = await permission.status;
        }
      }
    } else {
      // On Web, initialize with denied as these permissions aren't supported
      for (var permission in _permissions) {
        statuses[permission] = PermissionStatus.denied;
      }
    }

    if (mounted) {
      setState(() {
        _statuses = statuses;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final l10n = AppLocalizations.of(context)!;
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.webPermissionsNote)));
      return;
    }

    final status = await permission.request();
    setState(() {
      _statuses[permission] = status;
    });

    if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  void _showLogoutConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showHelpOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.helpAndSupport,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Options
                _buildHelpOption(
                  // ignore: deprecated_member_use
                  icon: MdiIcons.whatsapp,
                  title: l10n.chatWithSupport,
                  subtitle: l10n.whatsAppSupport,
                  color: const Color(0xFF25D366), // WhatsApp Green
                  onTap: () async {
                    Navigator.pop(context);
                    const String phoneNumber = "918016867006";
                    final Uri whatsappUri = Uri.parse(
                      "https://wa.me/$phoneNumber",
                    );
                    if (!await launchUrl(
                      whatsappUri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.couldNotLaunchWhatsApp)),
                      );
                    }
                  },
                ),
                _buildHelpOption(
                  icon: Icons.help_outline_rounded,
                  title: l10n.accountIssueAndFaq,
                  subtitle: l10n.commonQuestionsAndAccountHelp,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/account-faq');
                  },
                ),
                const Divider(height: 1, indent: 80),
                _buildHelpOption(
                  icon: Icons.logout_rounded,
                  title: l10n.logout,
                  subtitle: l10n.signOutOfYourAccount,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    _showLogoutConfirmation();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: title == 'Logout' ? Colors.red : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  void _showSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Text(l10n.permissionRequiredNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.06).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(16.0, 24.0);
    final headingFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final titleFontSize = (screenWidth * 0.055).clamp(20.0, 24.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);
    final buttonHeight = (screenHeight * 0.065).clamp(56.0, 64.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Styled Header
              _buildHeader(context, headingFontSize, bodyFontSize, iconSize),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.managePermissions,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.permissionsNote,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: bodyFontSize,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPermissionTile(
                              Permission.locationAlways,
                              Icons.location_on_outlined,
                              l10n.backgroundLocation,
                              l10n.backgroundLocationDesc,
                              bodyFontSize,
                              smallFontSize,
                              iconSize,
                              screenWidth,
                            ),
                            _buildPermissionTile(
                              Permission.ignoreBatteryOptimizations,
                              Icons.battery_saver_outlined,
                              l10n.batteryOptimization,
                              l10n.batteryOptimizationDesc,
                              bodyFontSize,
                              smallFontSize,
                              iconSize,
                              screenWidth,
                            ),
                            _buildPermissionTile(
                              Permission.systemAlertWindow,
                              Icons.layers_outlined,
                              l10n.displayOverApps,
                              l10n.displayOverAppsDesc,
                              bodyFontSize,
                              smallFontSize,
                              iconSize,
                              screenWidth,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalPadding * 0.5),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeStart,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.done,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headingFontSize,
    double bodyFontSize,
    double iconSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.7),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              l10n.permissions,
              style: TextStyle(
                fontSize: headingFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Help button
          if (!_hideHelp)
            InkWell(
              onTap: _showHelpOptions,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: iconSize * 0.7,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.help,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    Permission permission,
    IconData icon,
    String title,
    String description,
    double bodyFontSize,
    double smallFontSize,
    double iconSize,
    double screenWidth,
  ) {
    final status = _statuses[permission] ?? PermissionStatus.denied;
    final isGranted = status.isGranted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgStart,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryOrangeStart,
              size: iconSize * 0.8,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: bodyFontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Transform.scale(
                      scale: (screenWidth / 400).clamp(0.8, 1.0),
                      child: Switch(
                        value: isGranted,
                        onChanged: (val) {
                          if (!isGranted) {
                            _requestPermission(permission);
                          }
                        },
                        activeThumbColor: AppColors.primaryOrangeStart,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: smallFontSize + 1,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
