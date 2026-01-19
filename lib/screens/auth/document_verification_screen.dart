import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  // Document upload states
  String? _selectedLocation;
  String? _idProofFrontPath;
  String? _idProofBackPath;
  String? _panFrontPath;
  String? _panBackPath;
  String? _dlFrontPath;
  String? _dlBackPath;
  String? _workExperience;
  String? _profilePhotoPath;

  // Verification states
  bool _isAadharVerified = false;
  bool _isPanVerified = false;
  bool _isDlVerified = false;
  bool _isWorkVerified = false;
  bool _isPermissionGranted = false;

  // Form fields
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Name
      final savedName = prefs.getString('profile_name');
      if (savedName != null && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }

      // Load Location
      final savedLocation = prefs.getString('location_city');

      setState(() {
        if (savedLocation != null) {
          _selectedLocation = savedLocation;
        }
        // Aadhar
        _idProofFrontPath = prefs.getString('aadhar_front_path');
        _idProofBackPath = prefs.getString('aadhar_back_path');

        // PAN
        _panFrontPath = prefs.getString('pan_front_path');
        _panBackPath = prefs.getString('pan_back_path');

        // DL
        _dlFrontPath = prefs.getString('dl_front_path');
        _dlBackPath = prefs.getString('dl_back_path');

        // Statuses
        _isAadharVerified = prefs.getString('status_aadhar') == 'verified';
        _isPanVerified = prefs.getString('status_pan') == 'verified';
        _isDlVerified = prefs.getString('status_dl') == 'verified';
        _isWorkVerified = prefs.getString('status_work') == 'verified';

        // Work
        _workExperience = prefs.getString('work_experience');
        final savedServices = prefs.getStringList('profile_services');
        if (savedServices != null && savedServices.isNotEmpty) {
          // If we have services, we consider it partially complete for UI status
          _workExperience = "exists";
        }

        // Profile
        _profilePhotoPath = prefs.getString('profile_photo_path');

        _checkVerificationStatus();
      });
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  Future<void> _checkVerificationStatus() async {
    // Mock verification check for static operation
    // For now, we stay on this screen to allow user to see the verification process
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
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
            child: Text(AppLocalizations.of(context)!.cancel),
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
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
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
              const Divider(height: 1, indent: 80),
              _buildHelpOption(
                icon: Icons.logout_rounded,
                title: AppLocalizations.of(context)!.logout,
                subtitle: AppLocalizations.of(context)!.signOutOfYourAccount,
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _showLogoutConfirmation();
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: title == AppLocalizations.of(context)!.logout
              ? Colors.red
              : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  bool _isAadharComplete() {
    return _idProofFrontPath != null && _idProofBackPath != null;
  }

  bool _isPanComplete() {
    return _panFrontPath != null && _panBackPath != null;
  }

  bool _isDLComplete() {
    return _dlFrontPath != null && _dlBackPath != null;
  }

  bool _isWorkComplete() {
    return _workExperience != null;
  }

  bool _isProfileComplete() {
    return _profilePhotoPath != null && _nameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 24,
                  right: 24,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // OmiBay Partner text
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Help button
                    InkWell(
                      onTap: _showHelpOptions,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Signup Status Info
              InkWell(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/location-selection',
                    arguments: {'hideHelp': false},
                  );
                  if (result != null && result is String) {
                    setState(() {
                      _selectedLocation = result;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.signingUpTo,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _selectedLocation ??
                              AppLocalizations.of(context)!.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _nameController.text.isEmpty
                              ? AppLocalizations.of(context)!.partner
                              : _nameController.text.split(' ').first,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Welcome Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${AppLocalizations.of(context)!.welcome} ${_nameController.text.isEmpty ? AppLocalizations.of(context)!.partner : _nameController.text.split(' ').first}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.heresWhatYouNeedToDo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      _buildDocumentSection(
                        sectionId: 'profile',
                        title: AppLocalizations.of(context)!.profile,
                        icon: Icons.person_outline,
                        isComplete: _isProfileComplete(),
                        isLocked: false,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/edit-profile',
                            arguments: {'hideHelp': false},
                          );
                          if (result == true) {
                            // Reload the saved name from SharedPreferences
                            await _loadSavedData();
                            setState(() {
                              _profilePhotoPath = "uploaded";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Aadhar Card Section
                      _buildDocumentSection(
                        sectionId: 'aadhar',
                        title: AppLocalizations.of(context)!.aadharCard,
                        icon: Icons.badge_outlined,
                        isComplete: _isAadharVerified,
                        isPending: _isAadharComplete() && !_isAadharVerified,
                        isLocked: !_isProfileComplete(),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/aadhar-verification',
                            arguments: {'hideHelp': false},
                          );
                          if (result == true) {
                            await _loadSavedData();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // PAN Card Section
                      _buildDocumentSection(
                        sectionId: 'pan',
                        title: AppLocalizations.of(context)!.panCardOptional,
                        icon: Icons.credit_card_outlined,
                        isComplete: _isPanVerified,
                        isPending: _isPanComplete() && !_isPanVerified,
                        isLocked: !_isAadharComplete(),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/pan-verification',
                            arguments: {'hideHelp': false},
                          );
                          if (result == true) {
                            await _loadSavedData();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Driving License Section
                      _buildDocumentSection(
                        sectionId: 'dl',
                        title: AppLocalizations.of(
                          context,
                        )!.drivingLicenseOptional,
                        icon: Icons.directions_car_outlined,
                        isComplete: _isDlVerified,
                        isPending: _isDLComplete() && !_isDlVerified,
                        isLocked: !_isAadharComplete(),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/dl-verification',
                            arguments: {'hideHelp': false},
                          );
                          if (result == true) {
                            await _loadSavedData();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Work Verification Section
                      _buildDocumentSection(
                        sectionId: 'work',
                        title: AppLocalizations.of(context)!.workVerification,
                        icon: Icons.work_outline,
                        isComplete: _isWorkVerified,
                        isPending: _isWorkComplete() && !_isWorkVerified,
                        isLocked: !_isAadharComplete(),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/work-verification',
                          );
                          if (result == true) {
                            await _loadSavedData();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // Permission Section
                      _buildDocumentSection(
                        sectionId: 'permission',
                        title: AppLocalizations.of(context)!.permission,
                        icon: Icons.security_outlined,
                        isComplete: _isPermissionGranted,
                        isLocked: !_isWorkComplete(),
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/permissions',
                            arguments: {'hideHelp': false},
                          );
                          if (result == true) {
                            setState(() {
                              _isPermissionGranted = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      // Skip for now (Dev Mode)
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            if (prefs.getString('partner_access_date') ==
                                null) {
                              await prefs.setString(
                                'partner_access_date',
                                DateTime.now().toIso8601String(),
                              );
                            }
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: Text(
                            AppLocalizations.of(context)!.skipForNowDevMode,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildDocumentSection({
    required String sectionId,
    required String title,
    required IconData icon,
    required bool isComplete,
    required bool isLocked,
    bool isPending = false,
    required VoidCallback onTap,
  }) {
    return AbsorbPointer(
      absorbing: isLocked,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isComplete
                  ? AppColors.successGreen
                  : (isPending ? AppColors.warningYellow : Colors.grey[300]!),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.successGreen.withValues(alpha: 0.1)
                          : (isPending
                                ? AppColors.warningYellow.withValues(alpha: 0.1)
                                : (isLocked
                                      ? Colors.grey[100]
                                      : AppColors.primaryOrangeStart.withValues(
                                          alpha: 0.1,
                                        ))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isComplete
                          ? AppColors.successGreen
                          : (isPending
                                ? AppColors.warningYellow
                                : (isLocked
                                      ? Colors.grey[400]
                                      : AppColors.primaryOrangeStart)),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isLocked
                                    ? Colors.grey[400]
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (isComplete) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: AppColors.successGreen,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        if (isPending && !isComplete)
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.pendingForVerification,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warningYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Right side icon (Lock or Chevron)
                  Icon(
                    isLocked ? Icons.lock_outline : Icons.chevron_right,
                    color: isLocked
                        ? Colors.grey[300]
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
