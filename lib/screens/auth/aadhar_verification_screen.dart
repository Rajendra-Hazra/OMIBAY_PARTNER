import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

// Custom formatter for Aadhar number (XXXX XXXX XXXX)
class AadharNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = LocalizationHelper.convertBengaliToEnglish(
      newValue.text,
    ).replaceAll(' ', '');
    if (text.length > 12) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1 && i < 11) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class AadharVerificationScreen extends StatefulWidget {
  const AadharVerificationScreen({super.key});

  @override
  State<AadharVerificationScreen> createState() =>
      _AadharVerificationScreenState();
}

class _AadharVerificationScreenState extends State<AadharVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _frontPath;
  String? _backPath;
  bool _isLoading = false;
  bool _hideHelp = false;
  bool _isVerified = false;

  // Form controllers
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('hideHelp')) {
      setState(() {
        _hideHelp = args['hideHelp'] as bool;
      });
    }
  }

  @override
  void dispose() {
    _aadharController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isVerified = prefs.getString('status_aadhar') == 'verified';
        _aadharController.text = prefs.getString('aadhar_number') ?? '';
        _nameController.text = prefs.getString('aadhar_name') ?? '';
        _dobController.text = prefs.getString('aadhar_dob') ?? '';
        _frontPath = prefs.getString('aadhar_front_path');
        _backPath = prefs.getString('aadhar_back_path');
      });
    } catch (e) {
      debugPrint('Error loading Aadhar data: $e');
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aadhar_number', _aadharController.text);
      await prefs.setString('aadhar_name', _nameController.text);
      await prefs.setString('aadhar_dob', _dobController.text);
      if (_frontPath != null) {
        await prefs.setString('aadhar_front_path', _frontPath!);
      }
      if (_backPath != null) {
        await prefs.setString('aadhar_back_path', _backPath!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aadharDetailsSaved),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorSavingData} $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryOrangeStart,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  bool get _isFormValid {
    final aadharNumber = _aadharController.text.replaceAll(' ', '');
    return aadharNumber.length == 12 &&
        _nameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _frontPath != null &&
        _backPath != null;
  }

  Future<void> _pickImage(bool isFront) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.048).clamp(17.0, 20.0);
    final spacing = (screenWidth * 0.064).clamp(24.0, 28.0);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.symmetric(vertical: spacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFront
                  ? AppLocalizations.of(context)!.frontSidePhoto
                  : AppLocalizations.of(context)!.backSidePhoto,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: AppLocalizations.of(context)!.camera,
                  onTap: () {
                    Navigator.pop(context);
                    _handlePermissionAndPickImage(isFront, ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: AppLocalizations.of(context)!.gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _handlePermissionAndPickImage(isFront, ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: spacing * 0.67),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePermissionAndPickImage(
    bool isFront,
    ImageSource source,
  ) async {
    if (source == ImageSource.camera) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.requestingCameraAccess),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.cameraPermissionRequired,
                  ),
                ),
              );
            }
            return;
          }
        }
      }
    } else if (source == ImageSource.gallery) {
      if (!kIsWeb) {
        // For gallery/photos access on mobile
        PermissionStatus status;
        if (Platform.isAndroid) {
          // Check SDK version for Android 13+ (SDK 33)
          // Note: permission_handler's Permission.photos handles this internally usually
          // but explicitly checking Permission.photos for Android 13+ and storage for older
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }

          // If photos permission is not available (older android), fallback to storage
          if (status.isRestricted || status.isLimited) {
            status = await Permission.storage.status;
            if (status.isDenied) {
              status = await Permission.storage.request();
            }
          }
        } else {
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
        }

        if (!status.isGranted && !status.isLimited) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.galleryPermissionRequired,
                ),
              ),
            );
          }
          return;
        }
      }
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (isFront) {
            _frontPath = image.path;
          } else {
            _backPath = image.path;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.errorPickingImage} ${e.toString()}',
          ),
        ),
      );
    } finally {
      // Done picking
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.085).clamp(32.0, 40.0);
    final fontSize = (screenWidth * 0.037).clamp(13.0, 16.0);
    final padding = (screenWidth * 0.043).clamp(16.0, 20.0);
    
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryOrangeStart, size: iconSize),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final buttonPadding = (screenWidth * 0.05).clamp(20.0, 24.0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.logout,
          style: TextStyle(fontSize: (fontSize * 1.15).clamp(16.0, 19.0)),
        ),
        content: Text(
          AppLocalizations.of(context)!.logoutConfirmation,
          style: TextStyle(fontSize: fontSize),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
                vertical: buttonPadding * 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              // Clear login status
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_logged_in', false);
              await prefs.remove('login_method');

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: buttonPadding,
                vertical: buttonPadding * 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.logout,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpOptions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.064).clamp(24.0, 28.0);
    final titleFontSize = (screenWidth * 0.048).clamp(17.0, 20.0);
    
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
          padding: EdgeInsets.symmetric(vertical: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
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
                      icon: Icon(
                        Icons.close,
                        size: (screenWidth * 0.06).clamp(20.0, 24.0),
                      ),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: EdgeInsets.all(screenWidth * 0.021),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.043),
              const Divider(height: 1),
              SizedBox(height: screenWidth * 0.021),
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

  void _showSampleImage(String type) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = (screenWidth * 0.043).clamp(16.0, 20.0);
    final titleFontSize = (screenWidth * 0.048).clamp(17.0, 20.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(12.0, 15.0);
    final iconSize = (screenWidth * 0.064).clamp(24.0, 28.0);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
            maxHeight: screenHeight * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.sampleAadharCard,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: iconSize),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Text(
                  AppLocalizations.of(context)!.aadharShouldLookLikeThis,
                  style: TextStyle(fontSize: bodyFontSize, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: screenWidth * 0.032),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'images/A_sample_of_Aadhaar_card.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading sample image: $error');
                        final errorIconSize = (screenWidth * 0.107).clamp(40.0, 50.0);
                        final errorFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
                        return Container(
                          height: (screenHeight * 0.19).clamp(140.0, 180.0),
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: errorIconSize,
                                color: Colors.grey,
                              ),
                              SizedBox(height: screenWidth * 0.021),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.couldNotLoadSample,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: errorFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
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

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.064).clamp(24.0, 28.0);
    final verticalPadding = (screenWidth * 0.021).clamp(8.0, 12.0);
    final iconPadding = (screenWidth * 0.032).clamp(12.0, 16.0);
    final iconSize = (screenWidth * 0.064).clamp(24.0, 28.0);
    final titleFontSize = (screenWidth * 0.043).clamp(15.0, 18.0);
    final subtitleFontSize = (screenWidth * 0.035).clamp(12.0, 15.0);
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      leading: Container(
        padding: EdgeInsets.all(iconPadding),
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
          color: title == AppLocalizations.of(context)!.logout
              ? Colors.red
              : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: subtitleFontSize, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final horizontalPadding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final sectionPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final headingFontSize = (screenWidth * 0.045).clamp(16.0, 20.0);
    final labelFontSize = (screenWidth * 0.035).clamp(13.0, 15.0);
    final buttonHeight = (screenHeight * 0.06).clamp(56.0, 64.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final iconSize = (screenWidth * 0.055).clamp(20.0, 24.0);

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
          child: Column(
            children: [
              // Styled Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding * 0.5,
                  vertical: 16,
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
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: (screenWidth * 0.05).clamp(18.0, 22.0),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.aadharCardVerification,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: (screenWidth * 0.045).clamp(
                                  16.0,
                                  20.0,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_isVerified) ...[
                            SizedBox(width: screenWidth * 0.02),
                            Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: (screenWidth * 0.05).clamp(18.0, 22.0),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Help button
                    if (!_hideHelp)
                      InkWell(
                        onTap: _showHelpOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: (screenWidth * 0.05).clamp(18.0, 22.0),
                                color: Colors.white,
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Text(
                                AppLocalizations.of(context)!.help,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.04).clamp(
                                    14.0,
                                    18.0,
                                  ),
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Enter Aadhar Details
                      _buildAadharDetailsSection(
                        sectionPadding: sectionPadding,
                        headingFontSize: headingFontSize,
                        labelFontSize: labelFontSize,
                        iconSize: iconSize,
                      ),
                      const SizedBox(height: 24),
                      // Section 2: Upload Aadhar Card
                      _buildUploadSection(
                        sectionPadding: sectionPadding,
                        headingFontSize: headingFontSize,
                        labelFontSize: labelFontSize,
                        iconSize: iconSize,
                      ),
                      const SizedBox(height: 32),
                      // Submit Button
                      if (!_isVerified)
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isLoading
                                ? _saveData
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrangeStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.submitAndContinue,
                                    style: TextStyle(
                                      fontSize: buttonFontSize.clamp(
                                        14.0,
                                        17.0,
                                      ),
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

  Widget _buildUploadCard({
    required String title,
    String? imagePath,
    required VoidCallback onTap,
    required double labelFontSize,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardPadding = (screenWidth * 0.04).clamp(16.0, 20.0);
    final imageHeight = (screenHeight * 0.18).clamp(140.0, 200.0);
    final iconSize = (screenWidth * 0.12).clamp(48.0, 64.0);
    final uploadFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);

    return GestureDetector(
      onTap: _isVerified ? () => _showImagePreview(imagePath!, title) : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: imagePath != null
                ? AppColors.successGreen
                : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (imagePath != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            imagePath,
                            height: imageHeight.clamp(140.0, 160.0),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(imagePath),
                            height: imageHeight.clamp(140.0, 160.0),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Preview button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showImagePreview(imagePath, title),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.uploaded,
                    style: TextStyle(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: labelFontSize.clamp(12.0, 14.0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => _showImagePreview(imagePath, title),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.view,
                      style: TextStyle(
                        color: AppColors.primaryOrangeStart,
                        fontWeight: FontWeight.w600,
                        fontSize: labelFontSize.clamp(12.0, 14.0),
                      ),
                    ),
                  ),
                  if (!_isVerified) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.change,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: labelFontSize.clamp(12.0, 14.0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Icon(
                Icons.add_a_photo_outlined,
                size: iconSize.clamp(44.0, 52.0),
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.uploadText,
                style: TextStyle(
                  fontSize: uploadFontSize.clamp(14.0, 17.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.tapToCaptureOrSelect,
                style: TextStyle(
                  fontSize: labelFontSize.clamp(12.0, 14.0),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imagePath, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.043).clamp(16.0, 20.0);
    final titleFontSize = (screenWidth * 0.043).clamp(15.0, 18.0);
    final iconSize = (screenWidth * 0.064).clamp(24.0, 28.0);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${AppLocalizations.of(context)!.preview} $title',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: iconSize),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    child: kIsWeb
                        ? Image.network(
                            imagePath,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(imagePath),
                            width: double.infinity,
                            fit: BoxFit.contain,
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

  // Section 1: Aadhar Details
  Widget _buildAadharDetailsSection({
    required double sectionPadding,
    required double headingFontSize,
    required double labelFontSize,
    required double iconSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sectionPadding.clamp(18.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconSize * 0.45),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  color: Colors.blue,
                  size: iconSize.clamp(20.0, 24.0),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.enterAadharDetails,
                  style: TextStyle(
                    fontSize: headingFontSize.clamp(16.0, 20.0),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Aadhar Number
          _buildTextField(
            label: AppLocalizations.of(context)!.aadharNumber,
            controller: _aadharController,
            hintText: AppLocalizations.of(context)!.aadharHint,
            keyboardType: TextInputType.number,
            readOnly: _isVerified,
            inputFormatters: [
              EnglishDigitFormatter(),
              FilteringTextInputFormatter.digitsOnly,
              AadharNumberFormatter(),
            ],
            maxLength: 14, // 12 digits + 2 spaces
            prefixIcon: Icons.credit_card,
            labelFontSize: labelFontSize,
          ),
          const SizedBox(height: 16),
          // Full Name as per Aadhar
          _buildTextField(
            label: AppLocalizations.of(context)!.fullNameAsPerAadhar,
            controller: _nameController,
            hintText: AppLocalizations.of(context)!.enterYourFullName,
            keyboardType: TextInputType.name,
            readOnly: _isVerified,
            textCapitalization: TextCapitalization.words,
            prefixIcon: Icons.person_outline,
            labelFontSize: labelFontSize,
          ),
          const SizedBox(height: 16),
          // Date of Birth
          _buildTextField(
            label: AppLocalizations.of(context)!.dateOfBirth,
            controller: _dobController,
            hintText: AppLocalizations.of(context)!.dobHint,
            readOnly: true,
            onTap: _isVerified ? null : _selectDate,
            prefixIcon: Icons.calendar_today,
            suffixIcon: Icons.arrow_drop_down,
            labelFontSize: labelFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? prefixIcon,
    IconData? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required double labelFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: labelFontSize.clamp(13.0, 15.0),
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            counterText: '',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[500], size: 20)
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey[500])
                : null,
            filled: true,
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryOrangeStart,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section 2: Upload Aadhar Card
  Widget _buildUploadSection({
    required double sectionPadding,
    required double headingFontSize,
    required double labelFontSize,
    required double iconSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sectionPadding.clamp(18.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconSize * 0.45),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.upload_file,
                  color: AppColors.primaryOrangeStart,
                  size: iconSize.clamp(20.0, 24.0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.uploadAadharCard,
                      style: TextStyle(
                        fontSize: headingFontSize.clamp(16.0, 20.0),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.uploadClearPhotos,
                      style: TextStyle(
                        fontSize: labelFontSize.clamp(12.0, 14.0),
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showSampleImage('Front'),
                icon: Icon(
                  Icons.visibility_outlined,
                  size: (iconSize * 0.7).clamp(14.0, 18.0),
                ),
                label: Text(
                  AppLocalizations.of(context)!.sample,
                  style: TextStyle(
                    fontSize: labelFontSize.clamp(11.0, 13.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryOrangeStart,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Front Side Upload
          _buildUploadCard(
            title: AppLocalizations.of(context)!.frontSide,
            imagePath: _frontPath,
            onTap: () => _pickImage(true),
            labelFontSize: labelFontSize,
          ),
          const SizedBox(height: 12),
          // Back Side Upload
          _buildUploadCard(
            title: AppLocalizations.of(context)!.backSide,
            imagePath: _backPath,
            onTap: () => _pickImage(false),
            labelFontSize: labelFontSize,
          ),
        ],
      ),
    );
  }
}
