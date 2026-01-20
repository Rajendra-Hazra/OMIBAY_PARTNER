import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';

// Custom formatter for PAN number (ABCDE1234F)
class PanNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert to uppercase
    final text = LocalizationHelper.convertBengaliToEnglish(
      newValue.text,
    ).toUpperCase();
    if (text.length > 10) {
      return oldValue;
    }

    // Validate PAN format: 5 letters + 4 digits + 1 letter
    for (int i = 0; i < text.length; i++) {
      if (i < 5) {
        // First 5 characters must be letters
        if (!RegExp(r'[A-Z]').hasMatch(text[i])) {
          return oldValue;
        }
      } else if (i < 9) {
        // Next 4 characters must be digits
        if (!RegExp(r'[0-9]').hasMatch(text[i])) {
          return oldValue;
        }
      } else {
        // Last character must be letter
        if (!RegExp(r'[A-Z]').hasMatch(text[i])) {
          return oldValue;
        }
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class PanVerificationScreen extends StatefulWidget {
  const PanVerificationScreen({super.key});

  @override
  State<PanVerificationScreen> createState() => _PanVerificationScreenState();
}

class _PanVerificationScreenState extends State<PanVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _frontPath;
  String? _backPath;
  bool _isLoading = false;
  bool _hideHelp = false;
  bool _isVerified = false;

  // Form controllers
  final TextEditingController _panController = TextEditingController();
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
    _panController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isVerified = prefs.getString('status_pan') == 'verified';
        _panController.text = prefs.getString('pan_number') ?? '';
        _nameController.text = prefs.getString('pan_name') ?? '';
        _dobController.text = prefs.getString('pan_dob') ?? '';
        _frontPath = prefs.getString('pan_front_path');
        _backPath = prefs.getString('pan_back_path');
      });
    } catch (e) {
      debugPrint('Error loading PAN data: $e');
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pan_number', _panController.text);
      await prefs.setString('pan_name', _nameController.text);
      await prefs.setString('pan_dob', _dobController.text);
      if (_frontPath != null) {
        await prefs.setString('pan_front_path', _frontPath!);
      }
      if (_backPath != null) {
        await prefs.setString('pan_back_path', _backPath!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.panDetailsSaved),
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

  bool get _isFormValid {
    return _panController.text.length == 10 &&
        _nameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _frontPath != null &&
        _backPath != null;
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
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
          }
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

    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
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
            child: Icon(
              icon,
              color: AppColors.primaryOrangeStart,
              size: iconSize,
            ),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
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
              _buildHelpOption(
                // ignore: deprecated_member_use
                icon: MdiIcons.whatsapp,
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
                color: const Color(0xFF25D366),
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
                  Navigator.pop(context);
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

  void _showSampleImage() {
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
                        AppLocalizations.of(context)!.samplePanCard,
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
                  AppLocalizations.of(context)!.panShouldLookLikeThis,
                  style: TextStyle(
                    fontSize: bodyFontSize,
                    color: Colors.grey[600],
                  ),
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
                      'images/sample-pan-card.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        final errorIconSize = (screenWidth * 0.107).clamp(
                          40.0,
                          50.0,
                        );
                        final errorFontSize = (screenWidth * 0.032).clamp(
                          11.0,
                          14.0,
                        );
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

  void _showImagePreview(String path) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.043).clamp(16.0, 20.0);
    final titleFontSize = (screenWidth * 0.048).clamp(17.0, 20.0);
    final iconSize = (screenWidth * 0.064).clamp(24.0, 28.0);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      AppLocalizations.of(context)!.panCardPreview,
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: kIsWeb
                  ? Image.network(path, fit: BoxFit.contain)
                  : Image.file(File(path), fit: BoxFit.contain),
            ),
          ],
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(12.0, 20.0);
    final titleFontSize = (screenWidth * 0.05).clamp(16.0, 20.0);
    final subtitleFontSize = (screenWidth * 0.035).clamp(11.0, 14.0);
    final bodyFontSize = (screenWidth * 0.04).clamp(13.0, 16.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final borderRadius = (screenWidth * 0.04).clamp(12.0, 20.0);
    final cardPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final spacing = (screenWidth * 0.04).clamp(12.0, 20.0);

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
              // Header
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
                        size: iconSize * 0.9,
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.panCardVerification,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_isVerified) ...[
                            SizedBox(width: spacing * 0.4),
                            Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!_hideHelp)
                      InkWell(
                        onTap: _showHelpOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.6,
                            vertical: verticalPadding * 0.5,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              SizedBox(width: spacing * 0.3),
                              Text(
                                AppLocalizations.of(context)!.help,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
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
                      // Section 1: Enter PAN Details
                      _buildPanDetailsSection(
                        context,
                        screenWidth,
                        cardPadding,
                        spacing,
                        titleFontSize,
                        subtitleFontSize,
                        bodyFontSize,
                        iconSize,
                        borderRadius,
                      ),
                      SizedBox(height: spacing),

                      // Section 2: Upload Documents
                      _buildUploadDocumentsSection(
                        context,
                        screenWidth,
                        cardPadding,
                        spacing,
                        titleFontSize,
                        subtitleFontSize,
                        bodyFontSize,
                        iconSize,
                        borderRadius,
                      ),
                      SizedBox(height: spacing * 1.2),

                      // Continue Button
                      if (!_isVerified)
                        SizedBox(
                          width: double.infinity,
                          height: (screenHeight * 0.06).clamp(56.0, 64.0),
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isLoading
                                ? _saveData
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrangeStart,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius * 0.75,
                                ),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: iconSize,
                                    width: iconSize,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.saveAndContinue,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
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

  // Section 1: Enter PAN Details
  Widget _buildPanDetailsSection(
    BuildContext context,
    double screenWidth,
    double cardPadding,
    double spacing,
    double titleFontSize,
    double subtitleFontSize,
    double bodyFontSize,
    double iconSize,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth > 600 ? 600 : double.infinity,
      ),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
                padding: EdgeInsets.all(cardPadding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(borderRadius * 0.625),
                ),
                child: Icon(
                  Icons.credit_card,
                  color: AppColors.primaryOrangeStart,
                  size: iconSize * 1.1,
                ),
              ),
              SizedBox(width: spacing * 0.6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enterPanDetails,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing * 0.1),
                    Text(
                      AppLocalizations.of(context)!.fillPanInfo,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // PAN Number Field
          _buildTextField(
            context: context,
            label: AppLocalizations.of(context)!.panNumber,
            hint: 'ABCDE1234F',
            controller: _panController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              EnglishDigitFormatter(),
              PanNumberFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            prefixIcon: Icons.badge_outlined,
            bodyFontSize: bodyFontSize,
            subtitleFontSize: subtitleFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
          SizedBox(height: spacing * 0.8),

          // Name as per PAN
          _buildTextField(
            context: context,
            label: AppLocalizations.of(context)!.fullNameAsPerPan,
            hint: AppLocalizations.of(context)!.enterNameAsOnPan,
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            prefixIcon: Icons.person_outline,
            bodyFontSize: bodyFontSize,
            subtitleFontSize: subtitleFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
          SizedBox(height: spacing * 0.8),

          // Date of Birth
          _buildDateField(
            context: context,
            label: AppLocalizations.of(context)!.dateOfBirth,
            hint: 'DD/MM/YYYY',
            controller: _dobController,
            onTap: _selectDate,
            bodyFontSize: bodyFontSize,
            subtitleFontSize: subtitleFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
        ],
      ),
    );
  }

  // Section 2: Upload Documents
  Widget _buildUploadDocumentsSection(
    BuildContext context,
    double screenWidth,
    double cardPadding,
    double spacing,
    double titleFontSize,
    double subtitleFontSize,
    double bodyFontSize,
    double iconSize,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth > 600 ? 600 : double.infinity,
      ),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
                padding: EdgeInsets.all(cardPadding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(borderRadius * 0.625),
                ),
                child: Icon(
                  Icons.upload_file,
                  color: AppColors.primaryOrangeStart,
                  size: iconSize * 1.1,
                ),
              ),
              SizedBox(width: spacing * 0.6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.uploadPanCard,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: spacing * 0.1),
                    Text(
                      AppLocalizations.of(context)!.uploadClearPhotos,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showSampleImage,
                icon: Icon(Icons.visibility_outlined, size: iconSize * 0.8),
                label: Text(
                  AppLocalizations.of(context)!.sample,
                  style: TextStyle(
                    fontSize: subtitleFontSize * 0.92,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryOrangeStart,
                  padding: EdgeInsets.symmetric(horizontal: spacing * 0.4),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),

          // Front Side Upload
          _buildUploadCard(
            context: context,
            title: AppLocalizations.of(context)!.frontSide,
            imagePath: _frontPath,
            onTap: () => _pickImage(true),
            screenWidth: screenWidth,
            bodyFontSize: bodyFontSize,
            subtitleFontSize: subtitleFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
          SizedBox(height: spacing * 0.6),

          // Back Side Upload
          _buildUploadCard(
            context: context,
            title: AppLocalizations.of(context)!.backSide,
            imagePath: _backPath,
            onTap: () => _pickImage(false),
            screenWidth: screenWidth,
            bodyFontSize: bodyFontSize,
            subtitleFontSize: subtitleFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required double bodyFontSize,
    required double subtitleFontSize,
    required double iconSize,
    required double borderRadius,
    required double spacing,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: bodyFontSize,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing * 0.4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          onChanged: (_) => setState(() {}),
          enabled: !_isVerified,
          style: TextStyle(fontSize: bodyFontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: subtitleFontSize,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[500], size: iconSize)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing * 0.8,
              vertical: spacing * 0.7,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
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

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    required double bodyFontSize,
    required double subtitleFontSize,
    required double iconSize,
    required double borderRadius,
    required double spacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: bodyFontSize,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing * 0.4),
        GestureDetector(
          onTap: _isVerified ? null : onTap,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: bodyFontSize),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: subtitleFontSize,
                ),
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[500],
                  size: iconSize,
                ),
                suffixIcon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[500],
                  size: iconSize * 1.2,
                ),
                filled: true,
                fillColor: _isVerified ? Colors.grey[100] : Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: spacing * 0.8,
                  vertical: spacing * 0.7,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                  borderSide: const BorderSide(
                    color: AppColors.primaryOrangeStart,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required BuildContext context,
    required String title,
    String? imagePath,
    required VoidCallback onTap,
    required double screenWidth,
    required double bodyFontSize,
    required double subtitleFontSize,
    required double iconSize,
    required double borderRadius,
    required double spacing,
  }) {
    final imageHeight = screenWidth < 360
        ? 120.0
        : (screenWidth < 600 ? 140.0 : 160.0);

    return GestureDetector(
      onTap: _isVerified ? () => _showImagePreview(imagePath!) : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(spacing * 0.8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(borderRadius * 0.75),
          border: Border.all(
            color: imagePath != null
                ? AppColors.successGreen
                : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (imagePath != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius * 0.625),
                    child: kIsWeb
                        ? Image.network(
                            imagePath,
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(imagePath),
                            height: imageHeight,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Preview button
                  Positioned(
                    top: spacing * 0.4,
                    right: spacing * 0.4,
                    child: GestureDetector(
                      onTap: () => _showImagePreview(imagePath),
                      child: Container(
                        padding: EdgeInsets.all(spacing * 0.4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(spacing * 0.4),
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 0.6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: iconSize,
                  ),
                  SizedBox(width: spacing * 0.4),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.uploadedWithTitle(title),
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: subtitleFontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: spacing * 0.6),
                  TextButton(
                    onPressed: () => _showImagePreview(imagePath),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(screenWidth * 0.12, spacing * 1.5),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.view,
                      style: TextStyle(
                        color: AppColors.primaryOrangeStart,
                        fontWeight: FontWeight.w600,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ),
                  if (!_isVerified) ...[
                    SizedBox(width: spacing * 0.4),
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(screenWidth * 0.12, spacing * 1.5),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.change,
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Icon(
                Icons.add_a_photo_outlined,
                size: iconSize * 2.4,
                color: Colors.grey[400],
              ),
              SizedBox(height: spacing * 0.6),
              Text(
                '${AppLocalizations.of(context)!.uploadText} $title',
                style: TextStyle(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing * 0.2),
              Text(
                AppLocalizations.of(context)!.tapToCaptureOrSelect,
                style: TextStyle(
                  fontSize: subtitleFontSize,
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
}
