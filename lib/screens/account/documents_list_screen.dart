import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({super.key});

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  bool _hideHelp = false;
  bool _isLoading = true;

  // Document states
  String? _aadharFront;
  String? _aadharBack;
  String? _panFront;
  String? _panBack;
  String? _dlFront;
  String? _dlBack;

  // Verification statuses (Mocking for now)
  bool _isAadharVerified = false;
  bool _isPanVerified = false;
  bool _isDlVerified = false;

  @override
  void initState() {
    super.initState();
    _loadDocumentStatus();
  }

  Future<void> _loadDocumentStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _aadharFront = prefs.getString('aadhar_front_path');
        _aadharBack = prefs.getString('aadhar_back_path');
        _panFront = prefs.getString('pan_front_path');
        _panBack = prefs.getString('pan_back_path');
        _dlFront = prefs.getString('dl_front_path');
        _dlBack = prefs.getString('dl_back_path');

        // Check verification status
        _isAadharVerified = prefs.getString('status_aadhar') == 'verified';
        _isPanVerified = prefs.getString('status_pan') == 'verified';
        _isDlVerified = prefs.getString('status_dl') == 'verified';

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading document status: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('hideHelp')) {
      _hideHelp = args['hideHelp'] as bool;
    }
  }

  void _showHelpOptions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 24.0 * paddingScale;
    final vPadding = 24.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final iconSize = (screenWidth * 0.06).clamp(20.0, 26.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(vertical: vPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.helpAndSupport,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
                color: const Color(0xFF25D366), // WhatsApp Green
                titleFontSize: bodyFontSize,
                iconSize: iconSize,
                horizontalPadding: hPadding,
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
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.couldNotLaunchWhatsApp,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildHelpOption(
                icon: Icons.help_outline_rounded,
                title: AppLocalizations.of(context)!.accountIssueAndFaq,
                subtitle: AppLocalizations.of(
                  context,
                )!.commonQuestionsAndAccountHelp,
                color: Colors.orange,
                titleFontSize: bodyFontSize,
                iconSize: iconSize,
                horizontalPadding: hPadding,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/account-faq');
                },
              ),
              const SizedBox(height: 16),
            ],
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
    required double titleFontSize,
    required double iconSize,
    required double horizontalPadding,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: titleFontSize * 0.8,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final vPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final borderRadius = (screenWidth * 0.04).clamp(12.0, 16.0);
    final cardPadding = 16.0 * paddingScale;
    final spacing = 16.0 * paddingScale;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(
                context,
                hPadding,
                vPadding,
                titleFontSize,
                bodyFontSize,
                iconSize,
                borderRadius,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(hPadding),
                        children: [
                          _buildSyncDocItem(
                            title: AppLocalizations.of(context)!.aadharCard,
                            icon: Icons.badge,
                            isUploaded:
                                _aadharFront != null || _aadharBack != null,
                            isFullyUploaded:
                                _aadharFront != null && _aadharBack != null,
                            isVerified: _isAadharVerified,
                            route: '/aadhar-verification',
                            paths: [_aadharFront, _aadharBack],
                            bodyFontSize: bodyFontSize,
                            iconSize: iconSize,
                            cardPadding: cardPadding,
                            borderRadius: borderRadius,
                            spacing: spacing,
                          ),
                          _buildSyncDocItem(
                            title: AppLocalizations.of(
                              context,
                            )!.panCardOptional,
                            icon: Icons.credit_card,
                            isUploaded: _panFront != null || _panBack != null,
                            isFullyUploaded:
                                _panFront != null && _panBack != null,
                            isVerified: _isPanVerified,
                            route: '/pan-verification',
                            paths: [_panFront, _panBack],
                            bodyFontSize: bodyFontSize,
                            iconSize: iconSize,
                            cardPadding: cardPadding,
                            borderRadius: borderRadius,
                            spacing: spacing,
                          ),
                          _buildSyncDocItem(
                            title: AppLocalizations.of(
                              context,
                            )!.drivingLicenseOptional,
                            icon: Icons.directions_car,
                            isUploaded: _dlFront != null || _dlBack != null,
                            isFullyUploaded:
                                _dlFront != null && _dlBack != null,
                            isVerified: _isDlVerified,
                            route: '/dl-verification',
                            paths: [_dlFront, _dlBack],
                            bodyFontSize: bodyFontSize,
                            iconSize: iconSize,
                            cardPadding: cardPadding,
                            borderRadius: borderRadius,
                            spacing: spacing,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncDocItem({
    required String title,
    required IconData icon,
    required bool isUploaded, // This should mean "has any upload"
    required bool isFullyUploaded, // This should mean "has both sides"
    required bool isVerified,
    required String route,
    required double bodyFontSize,
    required double iconSize,
    required double cardPadding,
    required double borderRadius,
    required double spacing,
    List<String?>? paths,
  }) {
    final statusColor = isVerified
        ? Colors.green
        : (isFullyUploaded
              ? Colors.orange
              : (isUploaded ? Colors.orange : Colors.red));

    String statusText = AppLocalizations.of(context)!.notUploaded;
    if (isVerified) {
      statusText = AppLocalizations.of(context)!.verified;
    } else if (isFullyUploaded) {
      statusText = AppLocalizations.of(context)!.underReview;
    } else if (isUploaded) {
      statusText = AppLocalizations.of(context)!.partialUpload;
    }

    return Card(
      margin: EdgeInsets.only(bottom: spacing),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: isUploaded ? Colors.transparent : Colors.grey[200]!,
          width: 1,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            route,
            arguments: {'hideHelp': true},
          );
          if (result == true) {
            _loadDocumentStatus();
          }
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: cardPadding,
            vertical: cardPadding * 0.75,
          ),
          child: Row(
            children: [
              // Leading Thumbnail or Icon
              Container(
                width: iconSize * 2.5,
                height: iconSize * 2.5,
                decoration: BoxDecoration(
                  color: AppColors.bgStart,
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child:
                    isUploaded && paths != null && paths.any((p) => p != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          borderRadius * 0.75,
                        ),
                        child: kIsWeb
                            ? Image.network(
                                paths.firstWhere((p) => p != null)!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(paths.firstWhere((p) => p != null)!),
                                fit: BoxFit.cover,
                              ),
                      )
                    : Icon(
                        icon,
                        color: AppColors.primaryOrangeStart,
                        size: iconSize * 1.2,
                      ),
              ),
              SizedBox(width: spacing),
              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing * 0.25),
                    Row(
                      children: [
                        Icon(
                          isVerified
                              ? Icons.check_circle
                              : (isUploaded
                                    ? Icons.access_time
                                    : Icons.error_outline),
                          size: iconSize * 0.65,
                          color: statusColor,
                        ),
                        SizedBox(width: spacing * 0.4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: bodyFontSize * 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Button or Icon
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing * 0.8,
                  vertical: spacing * 0.4,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(borderRadius * 0.5),
                ),
                child: Text(
                  isVerified
                      ? AppLocalizations.of(context)!.view
                      : (isUploaded
                            ? AppLocalizations.of(context)!.complete
                            : AppLocalizations.of(context)!.uploadText),
                  style: TextStyle(
                    color: isVerified
                        ? Colors.green
                        : AppColors.primaryOrangeStart,
                    fontSize: bodyFontSize * 0.8,
                    fontWeight: FontWeight.bold,
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
    double horizontalPadding,
    double verticalPadding,
    double titleFontSize,
    double bodyFontSize,
    double iconSize,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding * 0.5,
        right: horizontalPadding,
        bottom: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius * 1.5),
          bottomRight: Radius.circular(borderRadius * 1.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.9),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.myDocuments,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!_hideHelp)
            Flexible(
              child: InkWell(
                onTap: _showHelpOptions,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding * 0.6,
                    vertical: verticalPadding * 0.5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: iconSize,
                        color: Colors.white,
                      ),
                      SizedBox(width: horizontalPadding * 0.3),
                      Text(
                        AppLocalizations.of(context)!.help,
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
