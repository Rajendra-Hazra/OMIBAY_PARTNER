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
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.helpAndSupport,
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
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Leading Thumbnail or Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.bgStart,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child:
                    isUploaded && paths != null && paths.any((p) => p != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                    : Icon(icon, color: AppColors.primaryOrangeStart, size: 24),
              ),
              const SizedBox(width: 16),
              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isVerified
                              ? Icons.check_circle
                              : (isUploaded
                                    ? Icons.access_time
                                    : Icons.error_outline),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
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
                    fontSize: 12,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 20,
        bottom: 20,
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.myDocuments,
              style: const TextStyle(
                fontSize: 18,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.help,
                        style: const TextStyle(
                          fontSize: 16,
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
