import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:pinput/pinput.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/auth_response.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late final UserRepository _userRepository;
  late final AuthRepository _authRepository;
  final ImagePicker _picker = ImagePicker();
  String? _photoUrl;
  String? _localPhotoPath;
  bool _isLoading = false;

  String _loginMethod = 'phone';
  bool _isPhoneVerified = false;
  bool _hideHelp = false;
  String? _selectedBloodGroup;
  String? _partnerId;

  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _authRepository = AuthRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _loadSavedData();
    AppColors.profileUpdateNotifier.addListener(_loadSavedData);
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
    AppColors.profileUpdateNotifier.removeListener(_loadSavedData);
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // First try to load from backend
      UserData? userData;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token != null && token.isNotEmpty) {
        try {
          userData = await _userRepository.getUserProfile();
        } catch (e) {
          debugPrint('Error loading backend profile: $e');
        }
      }

      if (!mounted) return;

      // Load login method
      _loginMethod = prefs.getString('login_method') ?? 'phone';
      _isPhoneVerified = prefs.getBool('phone_verified') ?? false;

      setState(() {
        if (userData != null) {
          _nameController.text = userData.fullName ?? userData.name;
          _dobController.text = userData.dateOfBirth ?? '';
          _emailController.text = userData.email ?? '';
          // Remove +91 prefix if present in mobile number
          String phone = userData.mobileNumber;
          if (phone.startsWith(
            AppLocalizations.of(context)!.indiaCountryCode,
          )) {
            phone = phone
                .replaceFirst(
                  AppLocalizations.of(context)!.indiaCountryCode,
                  '',
                )
                .trim();
          }
          _phoneController.text = phone;
          if (userData.profilePictureUrl != null &&
              userData.profilePictureUrl!.isNotEmpty) {
            _photoUrl = userData.profilePictureUrl!;
          }
          _partnerId = userData.partnerId;
        } else {
          // Fallback to Prefs
          final savedName = prefs.getString('profile_name');
          final savedDob = prefs.getString('profile_dob');
          final savedEmail = prefs.getString('profile_email');
          final savedPhone = prefs.getString('profile_phone');

          _nameController.text = LocalizationHelper.getLocalizedCustomerName(
            context,
            savedName,
          );
          _dobController.text = savedDob ?? '';
          _emailController.text = savedEmail ?? '';
          // Remove +91 prefix if present in saved phone
          String phone = savedPhone ?? '';
          if (phone.startsWith(
            AppLocalizations.of(context)!.indiaCountryCode,
          )) {
            phone = phone
                .replaceFirst(
                  AppLocalizations.of(context)!.indiaCountryCode,
                  '',
                )
                .trim();
          }
          _phoneController.text = phone;
        }

        final l10n = AppLocalizations.of(context)!;
        _photoUrl =
            userData?.profilePictureUrl ??
            prefs.getString('profile_photo_url') ??
            l10n.placeholderPhotoUrl;
        _localPhotoPath = prefs.getString('profile_photo_path');
        _selectedBloodGroup = prefs.getString('profile_blood_group');
        // Load partner ID from multiple possible keys, same as account screen
        _partnerId =
            _partnerId ??
            prefs.getString('profile_partner_code') ??
            prefs.getString('profile_referral_code') ??
            prefs.getString('profile_id') ??
            '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading saved data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangeContactPopup(String type) {
    final TextEditingController inputController = TextEditingController();
    final TextEditingController otpController = TextEditingController();
    bool otpSent = false;
    bool isSubmitting = false;
    String? statusMessage;
    bool isErrorStatus = false;
    String? verificationId;
    // ignore: unused_local_variable
    int? resendToken;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          // Callbacks for Phone Auth
          void onCodeSent(String vid, int? token) {
            if (context.mounted) {
              setSheetState(() {
                otpSent = true;
                isSubmitting = false;
                statusMessage = AppLocalizations.of(
                  context,
                )!.otpSentSuccessfully;
                isErrorStatus = false;
                verificationId = vid;
                resendToken = token;
              });
            }
          }

          void onVerificationFailed(FirebaseAuthException e) {
            if (context.mounted) {
              setSheetState(() {
                isSubmitting = false;
                statusMessage = e.message ?? 'Verification failed';
                isErrorStatus = true;
              });
            }
          }

          void onVerificationCompleted(PhoneAuthCredential credential) {
            // Auto-retrieval or instant verification
            // We can proceed to update mobile here if desired,
            // but usually we wait for user to click "Verify" or handle it automatically.
          }

          void onCodeAutoRetrievalTimeout(String vid) {
            verificationId = vid;
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              otpSent
                                  ? AppLocalizations.of(context)!.verifyOtp
                                  : (type == 'Phone'
                                        ? AppLocalizations.of(
                                            context,
                                          )!.updatePhone
                                        : AppLocalizations.of(
                                            context,
                                          )!.updateEmail),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        otpSent
                            ? (type == 'Phone'
                                  ? AppLocalizations.of(
                                      context,
                                    )!.enterOtpSentTo(
                                      AppLocalizations.of(context)!.phone,
                                    )
                                  : "Please enter your current password to confirm email change.")
                            : AppLocalizations.of(
                                context,
                              )!.enterNewToReceiveCode(
                                type == 'Phone'
                                    ? AppLocalizations.of(context)!.phone
                                    : AppLocalizations.of(context)!.email,
                              ),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      if (statusMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isErrorStatus
                                  ? Colors.red[50]
                                  : AppColors.successGreen.withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isErrorStatus
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : AppColors.successGreen.withValues(
                                        alpha: 0.2,
                                      ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isErrorStatus
                                      ? Icons.error_outline
                                      : Icons.check_circle_outline,
                                  color: isErrorStatus
                                      ? Colors.red
                                      : AppColors.successGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    statusMessage!,
                                    style: TextStyle(
                                      color: isErrorStatus
                                          ? Colors.red[700]
                                          : AppColors.successGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!otpSent)
                        TextField(
                          controller: inputController,
                          keyboardType: type == 'Phone'
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          inputFormatters: type == 'Phone'
                              ? [
                                  LengthLimitingTextInputFormatter(10),
                                  EnglishDigitFormatter(),
                                ]
                              : null,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: type == 'Phone'
                                ? AppLocalizations.of(context)!.newPhoneNumber
                                : AppLocalizations.of(context)!.newEmailAddress,
                            prefixIcon: type == 'Phone'
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      '${AppLocalizations.of(context)!.indiaCountryCode} ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                        )
                      else
                        (type == 'Phone')
                            ? Center(
                                child: Pinput(
                                  length: 6,
                                  controller: otpController,
                                  defaultPinTheme: PinTheme(
                                    width: 45,
                                    height: 50,
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: 45,
                                    height: 50,
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primaryOrangeStart,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              )
                            : TextField(
                                controller: otpController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Current Password",
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (!otpSent) {
                                    // Validate input
                                    final val = inputController.text.trim();
                                    if (type == 'Phone' && val.length != 10) {
                                      setSheetState(() {
                                        statusMessage = AppLocalizations.of(
                                          context,
                                        )!.pleaseEnterValid10DigitNumber;
                                        isErrorStatus = true;
                                      });
                                      return;
                                    }
                                    if (type == 'Email' &&
                                        (val.isEmpty || !val.contains('@'))) {
                                      setSheetState(() {
                                        statusMessage = AppLocalizations.of(
                                          context,
                                        )!.pleaseEnterValidEmail;
                                        isErrorStatus = true;
                                      });
                                      return;
                                    }

                                    setSheetState(() {
                                      isSubmitting = true;
                                      statusMessage = null;
                                    });

                                    // Send Logic
                                    if (type == 'Phone') {
                                      try {
                                        await _authRepository.sendOtp(
                                          phoneNumber: val,
                                          onCodeSent: onCodeSent,
                                          onVerificationFailed:
                                              onVerificationFailed,
                                          onVerificationCompleted:
                                              onVerificationCompleted,
                                          onCodeAutoRetrievalTimeout:
                                              onCodeAutoRetrievalTimeout,
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          setSheetState(() {
                                            isSubmitting = false;
                                            statusMessage = e.toString();
                                            isErrorStatus = true;
                                          });
                                        }
                                      }
                                    } else {
                                      // Email Mock (keeping existing logic)
                                      await Future.delayed(
                                        const Duration(seconds: 1),
                                      );
                                      setSheetState(() {
                                        otpSent = true;
                                        isSubmitting = false;
                                        statusMessage = AppLocalizations.of(
                                          context,
                                        )!.otpSentSuccessfully;
                                        isErrorStatus = false;
                                      });
                                    }
                                  } else {
                                    // Verify And Update Logic
                                    if (type == 'Phone') {
                                      if (otpController.text.length != 6)
                                        return;

                                      setSheetState(() {
                                        isSubmitting = true;
                                        statusMessage = null;
                                      });

                                      try {
                                        if (verificationId == null)
                                          throw Exception(
                                            "Verification ID missing",
                                          );

                                        final credential =
                                            PhoneAuthProvider.credential(
                                              verificationId: verificationId!,
                                              smsCode: otpController.text,
                                            );

                                        // Verify by signing in or linking
                                        // Using signInWithCredential to verify OTP validity
                                        await FirebaseAuth.instance
                                            .signInWithCredential(credential);
                                        // Note: Current user context might change here.
                                        // Assuming success means OTP is valid.

                                        await _userRepository.updateMobile(
                                          inputController.text.trim(),
                                        );

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString(
                                          'profile_phone',
                                          inputController.text.trim(),
                                        );
                                        await prefs.setBool(
                                          'phone_verified',
                                          true,
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          _loadSavedData();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.phoneUpdatedSuccessfully,
                                              ),
                                              backgroundColor:
                                                  AppColors.successGreen,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          setSheetState(() {
                                            isSubmitting = false;
                                            statusMessage = e.toString();
                                            isErrorStatus = true;
                                          });
                                        }
                                      }
                                    } else {
                                      // Email Verify via Password (Mock Removed)
                                      if (otpController.text.isEmpty) {
                                        setSheetState(() {
                                          statusMessage =
                                              "Please enter password";
                                          isErrorStatus = true;
                                        });
                                        return;
                                      }

                                      setSheetState(() {
                                        isSubmitting = true;
                                        statusMessage = null;
                                      });

                                      try {
                                        await _userRepository.updateEmail(
                                          inputController.text.trim(),
                                          otpController
                                              .text, // Sending password
                                        );

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString(
                                          'profile_email',
                                          inputController.text.trim(),
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          _loadSavedData();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.emailUpdatedSuccessfully,
                                              ),
                                              backgroundColor:
                                                  AppColors.successGreen,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          setSheetState(() {
                                            isSubmitting = false;
                                            statusMessage = e.toString();
                                            isErrorStatus = true;
                                          });
                                        }
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeStart,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
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
                                  otpSent
                                      ? AppLocalizations.of(
                                          context,
                                        )!.confirmChange
                                      : (type == 'Phone'
                                            ? AppLocalizations.of(
                                                context,
                                              )!.sendVerificationCode
                                            : "Continue"),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.helpAndSupport,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                      final l10n = AppLocalizations.of(context)!;
                      final String phoneNumber = l10n.whatsappSupportNumber;
                      final Uri whatsappUri = Uri.parse(
                        "https://wa.me/$phoneNumber",
                      );
                      if (!await launchUrl(
                        whatsappUri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.couldNotLaunchWhatsApp,
                              ),
                            ),
                          );
                        }
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
                    subtitle: AppLocalizations.of(
                      context,
                    )!.signOutOfYourAccount,
                    color: Colors.red,
                    isDestructive: true,
                    onTap: () {
                      Navigator.pop(context); // Close bottom sheet
                      _showLogoutConfirmation();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
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
    bool isDestructive = false,
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
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  // Validate profile before saving
  List<String> _validateProfile() {
    final List<String> errors = [];

    if (_nameController.text.trim().isEmpty) {
      errors.add(AppLocalizations.of(context)!.fullName);
    }
    if (_dobController.text.trim().isEmpty) {
      errors.add(AppLocalizations.of(context)!.dateOfBirth);
    }

    return errors;
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 15),
      ), // Minimum 15 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrangeStart,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Show validation error dialog
  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.requiredFields,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.pleaseFillRequiredFields,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final errors = _validateProfile();
    if (errors.isNotEmpty) {
      _showValidationErrors(errors);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save to backend
      await _userRepository.updateProfile(
        fullName: _nameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        profilePicture: _localPhotoPath != null ? File(_localPhotoPath!) : null,
      );

      // Also save to Prefs for offline access/speed
      await prefs.setString('profile_name', _nameController.text.trim());
      await prefs.setString('profile_dob', _dobController.text.trim());
      if (_selectedBloodGroup != null) {
        await prefs.setString('profile_blood_group', _selectedBloodGroup!);
      }

      if (_localPhotoPath != null) {
        await prefs.setString('profile_photo_path', _localPhotoPath!);
      }

      if (mounted) {
        AppColors.profileUpdateNotifier.value++;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.profileSavedSuccessfully,
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorSavingProfile(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePermissionAndPickImage(ImageSource source) async {
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
        PermissionStatus status;
        if (Platform.isAndroid) {
          status = await Permission.photos.status;
          if (status.isDenied) {
            status = await Permission.photos.request();
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        // Copy image to permanent app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final permanentPath = '${appDir.path}/$fileName';

        // Delete old profile picture if it exists in app directory
        if (_localPhotoPath != null &&
            _localPhotoPath!.contains(appDir.path) &&
            _localPhotoPath!.contains('profile_picture_')) {
          try {
            final oldFile = File(_localPhotoPath!);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
          } catch (e) {
            debugPrint('Error deleting old profile picture: $e');
          }
        }

        // Copy the picked image to permanent location
        final File tempFile = File(image.path);
        await tempFile.copy(permanentPath);

        setState(() {
          _localPhotoPath = permanentPath;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.profilePhoto,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: AppLocalizations.of(context)!.camera,
                  onTap: () {
                    Navigator.pop(context);
                    _handlePermissionAndPickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: AppLocalizations.of(context)!.gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _handlePermissionAndPickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryOrangeStart, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        children: [
                          _buildAvatarSection(),
                          const SizedBox(height: 24),
                          // Partner ID Section
                          if (_partnerId != null && _partnerId!.isNotEmpty)
                            _buildPartnerIdSection(),
                          if (_partnerId != null && _partnerId!.isNotEmpty)
                            const SizedBox(height: 24),
                          _buildPersonalInformationSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildSaveButton()),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding * 0.5,
        right: horizontalPadding,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
              AppLocalizations.of(context)!.editProfile,
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.055).clamp(18.0, 22.0),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!_hideHelp)
            IconButton(
              onPressed: _showHelpOptions,
              icon: const Icon(Icons.help_outline, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = (screenWidth * 0.13).clamp(40.0, 60.0);

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey[200],
            backgroundImage: _localPhotoPath != null
                ? (kIsWeb
                      ? NetworkImage(_localPhotoPath!)
                      : FileImage(File(_localPhotoPath!)) as ImageProvider)
                : NetworkImage(_photoUrl ?? 'https://via.placeholder.com/150'),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrangeStart,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.bloodGroup,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.of(context)!.recommended,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBloodGroup,
            decoration: InputDecoration(
              prefixIcon: Icon(
                MdiIcons.water,
                color: Colors.red[400],
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            hint: Text(
              AppLocalizations.of(context)!.selectBloodGroup,
              style: TextStyle(color: Colors.grey[500]),
            ),
            items: _bloodGroups.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(
                  group,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedBloodGroup = newValue;
              });
            },
            icon: const Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
    IconData? prefixIcon,
    String? hintText,
    bool isOptional = false,
    bool readOnly = false,
    String? actionLabel,
    VoidCallback? onActionTap,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            if (isOptional)
              Text(
                ' ${AppLocalizations.of(context)!.optional}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                readOnly: readOnly,
                onTap: onTap,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefix: prefix,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: prefixIcon != null
                      ? Container(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                prefixIcon,
                                size: 20,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        )
                      : null,
                  prefixIconConstraints: prefixIcon != null
                      ? const BoxConstraints(minWidth: 0, minHeight: 0)
                      : null,
                  filled: true,
                  fillColor: readOnly ? Colors.grey[100] : Colors.white,
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
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.primaryOrangeStart,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // Partner ID Section
  Widget _buildPartnerIdSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          const Text(
            'ID:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _partnerId ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _partnerId ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(AppLocalizations.of(context)!.copied),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.copy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Personal Information Section
  Widget _buildPersonalInformationSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    // Check if user logged in via Google (needs phone verification)
    final bool needsPhoneVerification =
        _loginMethod == 'google' && !_isPhoneVerified;
    // Check if user logged in via phone (email is optional)
    final bool isPhoneLogin = _loginMethod == 'phone';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryOrangeStart,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.personalInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            AppLocalizations.of(context)!.fullName,
            _nameController,
            prefixIcon: Icons.person_outline,
            hintText: AppLocalizations.of(context)!.enterYourFullName,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            AppLocalizations.of(context)!.dateOfBirth,
            _dobController,
            readOnly: true,
            onTap: _selectDate,
            prefixIcon: Icons.calendar_today_outlined,
            hintText: 'YYYY-MM-DD',
          ),
          const SizedBox(height: 16),
          _buildBloodGroupDropdown(),
          const SizedBox(height: 16),
          // Mobile Number field with verify option for Google login
          _buildMobileNumberField(
            isVerified: isPhoneLogin || _isPhoneVerified,
            needsVerification: needsPhoneVerification,
            onActionTap: () => _showChangeContactPopup('Phone'),
            actionLabel: _phoneController.text.isEmpty
                ? AppLocalizations.of(context)!.add
                : AppLocalizations.of(context)!.change,
          ),
          const SizedBox(height: 16),
          // Email field - optional for phone login, read-only for Google login
          _buildTextField(
            AppLocalizations.of(context)!.emailAddress,
            _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            hintText: AppLocalizations.of(context)!.exampleEmail,
            isOptional: isPhoneLogin,
            readOnly: true, // Making it read-only to force using Change option
            actionLabel: _emailController.text.isEmpty
                ? AppLocalizations.of(context)!.add
                : AppLocalizations.of(context)!.change,
            onActionTap: () => _showChangeContactPopup('Email'),
          ),
        ],
      ),
    );
  }

  // Mobile Number Field with Verify option
  Widget _buildMobileNumberField({
    required bool isVerified,
    required bool needsVerification,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.mobileNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            if (needsVerification)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  EnglishDigitFormatter(),
                ],
                readOnly: isVerified,
                maxLength: 10,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0000000000',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.indiaCountryCode,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  filled: true,
                  fillColor: isVerified ? Colors.grey[100] : Colors.white,
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
                  suffixIcon: isVerified
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 22,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (needsVerification) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _verifyPhoneNumber,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrangeStart,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.verify,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.primaryOrangeStart,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (needsVerification)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              AppLocalizations.of(context)!.pleaseVerifyMobileToContinue,
              style: TextStyle(fontSize: 12, color: Colors.orange[700]),
            ),
          ),
      ],
    );
  }

  // Verify phone number
  void _verifyPhoneNumber() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterValid10DigitMobile,
          ),
        ),
      );
      return;
    }

    // Show OTP verification bottom sheet
    _showOtpVerificationSheet(phone);
  }

  // OTP Verification Sheet
  void _showOtpVerificationSheet(String phone) {
    final TextEditingController otpController = TextEditingController();
    bool isVerifying = false;
    bool isSendingOtp = true;
    String? statusMessage;
    bool isErrorStatus = false;
    String? verificationId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          // Send OTP on first build
          if (isSendingOtp) {
            isSendingOtp = false;
            _authRepository.sendOtp(
              phoneNumber: phone,
              onCodeSent: (vid, token) {
                if (context.mounted) {
                  setSheetState(() {
                    verificationId = vid;
                    statusMessage = AppLocalizations.of(
                      context,
                    )!.otpSentSuccessfully;
                    isErrorStatus = false;
                  });
                }
              },
              onVerificationFailed: (e) {
                if (context.mounted) {
                  setSheetState(() {
                    statusMessage = e.message ?? 'Verification failed';
                    isErrorStatus = true;
                  });
                }
              },
              onVerificationCompleted: (credential) {
                // Auto-verification handled if needed
              },
              onCodeAutoRetrievalTimeout: (vid) {
                verificationId = vid;
              },
            );
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.verifyMobileNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.otpSentTo(phone),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  if (statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isErrorStatus
                              ? Colors.red[50]
                              : AppColors.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isErrorStatus
                                ? Colors.red.withValues(alpha: 0.2)
                                : AppColors.successGreen.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isErrorStatus
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: isErrorStatus
                                  ? Colors.red
                                  : AppColors.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                statusMessage!,
                                style: TextStyle(
                                  color: isErrorStatus
                                      ? Colors.red[700]
                                      : AppColors.successGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [EnglishDigitFormatter()],
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '------',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        letterSpacing: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isVerifying || otpController.text.length != 6
                          ? null
                          : () async {
                              if (verificationId == null) {
                                setSheetState(() {
                                  statusMessage =
                                      'Verification ID missing. Please try again.';
                                  isErrorStatus = true;
                                });
                                return;
                              }

                              setSheetState(() {
                                isVerifying = true;
                                statusMessage = null;
                              });

                              try {
                                final credential = PhoneAuthProvider.credential(
                                  verificationId: verificationId!,
                                  smsCode: otpController.text,
                                );

                                // Verify by signing in with credential
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);

                                // Save verification status
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('phone_verified', true);
                                await prefs.setString('profile_phone', phone);

                                setState(() {
                                  _isPhoneVerified = true;
                                });

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.mobileNumberVerifiedSuccessfully,
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setSheetState(() {
                                    isVerifying = false;
                                    statusMessage = AppLocalizations.of(
                                      context,
                                    )!.invalidOtpTryAgain;
                                    isErrorStatus = true;
                                  });
                                }
                              }
                            },
                      child: isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.verifyOtp),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = (screenHeight * 0.065).clamp(56.0, 64.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrangeStart,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.saveProfile,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
