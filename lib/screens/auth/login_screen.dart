import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../repositories/auth_repository.dart';

enum LoginStep { phone, otp, gmail, recovery }

// Custom input formatter for Indian phone numbers
class IndianPhoneNumberFormatter extends TextInputFormatter {
  static String convertBengaliToEnglish(String input) {
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(bengali[i], english[i]);
    }
    return input;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert Bengali digits to English digits
    final text = convertBengaliToEnglish(newValue.text);

    // If the text is empty, allow it
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Check if the first character is 6, 7, 8, or 9
    final firstChar = text[0];
    if (!RegExp(r'^[6-9]').hasMatch(firstChar)) {
      // If first character is not 6-9, reject the input
      return oldValue;
    }

    // Check if all characters are digits
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
      return oldValue;
    }

    // Allow the input if it's valid
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginStep _currentStep = LoginStep.phone;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _recoveryPhoneController =
      TextEditingController();
  final TextEditingController _recoveryEmailController =
      TextEditingController();
  String? _phoneError;
  String? _recoveryPhoneError;
  String? _recoveryEmailError;
  bool _isLoading = false;
  bool _isOtpLoading = false;
  bool _isGoogleLoading = false;
  String _findAccountMethod = 'phone'; // 'phone' or 'email'
  String? _verificationId;
  late final AuthRepository _authRepository;

  // Lazy initialization (Removed for static operation)

  int _timerSeconds = 30;
  Timer? _resendTimer;

  void _startResendTimer() {
    setState(() {
      _timerSeconds = 30;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  /// Request permissions sequentially: SMS first, then Notification
  Future<void> _handlePermissions() async {
    // Request permissions on Mobile only
    if (!kIsWeb) {
      // First, request SMS permission
      await Permission.sms.request();

      // Then, request Notification permission
      await Permission.notification.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _otpController.addListener(() {
      setState(() {}); // Update UI when OTP changes
    });

    // Request permissions when login screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePermissions();
    });

    // Initialize AuthRepository
    _authRepository = AuthRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.removeListener(_validatePhone);
    _otpController.removeListener(() {});
    _phoneController.dispose();
    _otpController.dispose();
    _recoveryPhoneController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }

  // Google Sign-In Method (Real implementation)
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authResponse = await _authRepository.signInWithGoogle();

      if (!mounted) return;
      setState(() {
        _isGoogleLoading = false;
      });

      // Successful login - Check if profile/documents are verified
      // Successful login - Check if profile/documents are verified
      final partnerId = authResponse.data.partnerId;
      final hasPartnerId = partnerId != null && partnerId.isNotEmpty;
      final hasRemoteName = authResponse.data.name.isNotEmpty;

      if (authResponse.data.isVerified || hasPartnerId || hasRemoteName) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/verification');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.welcome} ${authResponse.data.name}',
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGoogleLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.failedToSignIn}: ${e.toString()}',
          ),
        ),
      );
    }
  }

  // Find Account by Phone (Mocked for static operation)
  Future<void> _findAccountByPhone() async {
    final phone = _recoveryPhoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _recoveryPhoneError = AppLocalizations.of(context)!.enterPhoneNumber;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _phoneController.text = phone;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.accountFound)),
    );
  }

  // Find Account by Email (Mocked for static operation)
  Future<void> _findAccountByEmail() async {
    final email = _recoveryEmailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _recoveryEmailError = AppLocalizations.of(context)!.enterEmailAddress;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.accountFound)),
    );
  }

  // Find Account by Phone or Email
  Future<void> _findAccount() async {
    if (_findAccountMethod == 'phone') {
      await _findAccountByPhone();
    } else {
      await _findAccountByEmail();
    }
  }

  void _validatePhone() {
    setState(() {
      final phone = _phoneController.text;
      if (phone.isEmpty) {
        _phoneError = null;
      } else if (phone.isNotEmpty && !RegExp(r'^[6-9]').hasMatch(phone)) {
        _phoneError = AppLocalizations.of(context)!.phoneNumberMustStartWith;
      } else if (phone.length > 10) {
        _phoneError = AppLocalizations.of(context)!.phoneNumberMustBe10Digits;
      } else if (phone.isNotEmpty && phone.length < 10) {
        _phoneError = AppLocalizations.of(context)!.phoneNumberMustBe10Digits;
      } else if (phone.length == 10 &&
          !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
        _phoneError = AppLocalizations.of(context)!.invalidPhoneFormat;
      } else {
        _phoneError = null;
      }
    });
  }

  bool get _isPhoneValid {
    final phone = _phoneController.text;
    return phone.length == 10 &&
        RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone) &&
        _phoneError == null;
  }

  // Send OTP (Using Firebase)
  Future<void> _sendOtp() async {
    if (!_isPhoneValid || _isOtpLoading) return;

    setState(() {
      _isOtpLoading = true;
    });

    try {
      await _authRepository.sendOtp(
        phoneNumber: _phoneController.text,
        onCodeSent: (verificationId, resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isOtpLoading = false;
              _currentStep = LoginStep.otp; // Switch to OTP step
            });
            _startResendTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.debugOtpSent),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        },
        onVerificationFailed: (e) {
          if (mounted) {
            setState(() {
              _isOtpLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onVerificationCompleted: (credential) {
          // Could handle auto-verification here
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOtpLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Verify OTP (Using Backend API via /partner)
  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6 || _isLoading) return;

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification ID missing. Resend OTP.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await _authRepository.verifyOtp(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
        phoneNumber: _phoneController.text,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Successful login - Check if profile/documents are verified
      // Successful login - Check if profile/documents are verified
      final partnerId = authResponse.data.partnerId;
      final hasPartnerId = partnerId != null && partnerId.isNotEmpty;
      final hasRemoteName = authResponse.data.name.isNotEmpty;

      if (authResponse.data.isVerified || hasPartnerId || hasRemoteName) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP or Login failed: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFE0E7FF),
            ], // blue-50 to indigo-100
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.06), // 6% of screen width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: (screenWidth * 0.07).clamp(24, 32),
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context)!.welcome} ',
                        style: const TextStyle(color: Color(0xFF0A192F)),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.partner,
                        style: const TextStyle(
                          color: AppColors.primaryOrangeStart,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.loginSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: (screenWidth * 0.04).clamp(14, 18),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildStepContent(screenWidth, screenHeight),
                const SizedBox(height: 40),
                _buildFooter(screenWidth),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(double screenWidth, double screenHeight) {
    switch (_currentStep) {
      case LoginStep.phone:
        return _buildPhoneStep(screenWidth, screenHeight);
      case LoginStep.otp:
        return _buildOtpStep(screenWidth, screenHeight);
      case LoginStep.gmail:
        return _buildGmailStep(screenWidth, screenHeight);
      case LoginStep.recovery:
        return _buildRecoveryStep(screenWidth, screenHeight);
    }
  }

  Widget _buildPhoneStep(double screenWidth, double screenHeight) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            // Combined Indian Flag and Phone Number Container
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _phoneError != null ? Colors.red : AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Indian Flag and +91 prefix
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Fixed Indian Flag representation
                        Container(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.04,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFFF9933),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Container(
                                      width: screenWidth * 0.01,
                                      height: screenWidth * 0.01,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF000080),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: const Color(0xFF128807),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          AppLocalizations.of(context)!.indiaCountryCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (screenWidth * 0.038).clamp(14, 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical divider
                  Container(height: 48, width: 1, color: AppColors.border),
                  // Phone number input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [
                        EnglishDigitFormatter(),
                        IndianPhoneNumberFormatter(),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.phoneNumber,
                        counterText: '',
                        errorText: null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Error message below the combined container
            if (_phoneError != null)
              Padding(
                padding: EdgeInsets.only(top: 8, left: screenWidth * 0.03),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _phoneError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isPhoneValid && !_isOtpLoading && !_isGoogleLoading)
                    ? _sendOtp
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isOtpLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.sendOtpToPhoneNumber),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.or,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: (_isOtpLoading || _isGoogleLoading)
                  ? null
                  : _signInWithGoogle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.border),
              ),
              child: _isGoogleLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryOrangeStart,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'images/google_logo.svg',
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          placeholderBuilder: (context) => SizedBox(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            child: const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          AppLocalizations.of(context)!.continueWithGoogle,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14, 16),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: TextButton.icon(
                onPressed: _isLoading ? null : () => _showFindAccountDialog(),
                icon: const Icon(Icons.search, size: 20, color: Colors.black),
                label: Text(
                  AppLocalizations.of(context)!.findMyAccount,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpStep(double screenWidth, double screenHeight) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = LoginStep.phone;
                      _otpController.clear();
                      _resendTimer?.cancel();
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: AppLocalizations.of(context)!.backToPhoneNumber,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.enterOtp,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: (screenWidth * 0.045).clamp(16, 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.sentTo(_phoneController.text),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Pinput(
              length: 6,
              controller: _otpController,
              inputFormatters: [EnglishDigitFormatter()],
              defaultPinTheme: PinTheme(
                width: 50,
                height: 56,
                textStyle: TextStyle(
                  fontSize: (screenWidth * 0.05).clamp(18, 22),
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_otpController.text.length == 6 && !_isLoading)
                    ? _verifyOtp
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(AppLocalizations.of(context)!.verifyAndContinue),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.didntReceiveOtp,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: (_timerSeconds == 0 && !_isLoading)
                      ? _sendOtp
                      : null,
                  child: Text(
                    _timerSeconds == 0
                        ? AppLocalizations.of(context)!.resendOtp
                        : AppLocalizations.of(
                            context,
                          )!.resendIn(_timerSeconds.toString()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGmailStep(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.selectYourAccount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: (screenWidth * 0.045).clamp(16, 20),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildAccountCard('John Doe', 'john.doe@gmail.com'),
        _buildAccountCard('Jane Smith', 'jane.smith@gmail.com'),
      ],
    );
  }

  Widget _buildAccountCard(String name, String email) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name),
        subtitle: Text(email),
        onTap: () {
          // This is placeholder code for Gmail account selection
          // In production, implement proper account linking
          Navigator.pushReplacementNamed(context, '/verification');
        },
      ),
    );
  }

  Widget _buildRecoveryStep(double screenWidth, double screenHeight) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.successGreen,
              size: screenWidth * 0.16,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              AppLocalizations.of(context)!.accountRecovered,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: (screenWidth * 0.05).clamp(18, 22),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              AppLocalizations.of(context)!.accountVerifiedSuccess,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/verification'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.goToDashboard),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(double screenWidth) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.byContinyingYouAgree,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/terms'),
              child: Text(
                AppLocalizations.of(context)!.termsOfService,
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
            Text(
              ' ${AppLocalizations.of(context)!.and} ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/privacy'),
              child: Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: const TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFindAccountDialog() {
    _recoveryPhoneController.clear();
    _recoveryEmailController.clear();
    setState(() {
      _recoveryPhoneError = null;
      _recoveryEmailError = null;
      _findAccountMethod = 'phone'; // Default to phone
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.findMyAccountTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enterRegisteredInfo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Toggle between Phone and Email
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  setState(() {
                                    _findAccountMethod = 'phone';
                                    _recoveryEmailError = null;
                                  });
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _findAccountMethod == 'phone'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _findAccountMethod == 'phone'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.phone,
                                  style: TextStyle(
                                    fontWeight: _findAccountMethod == 'phone'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _findAccountMethod == 'phone'
                                        ? AppColors.primaryOrangeStart
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  setState(() {
                                    _findAccountMethod = 'email';
                                    _recoveryPhoneError = null;
                                  });
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _findAccountMethod == 'email'
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _findAccountMethod == 'email'
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.email,
                                  style: TextStyle(
                                    fontWeight: _findAccountMethod == 'email'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _findAccountMethod == 'email'
                                        ? AppColors.primaryOrangeStart
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Input field based on selected method
                    if (_findAccountMethod == 'phone') ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _recoveryPhoneError != null
                                ? Colors.red
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // +91 prefix
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  bottomLeft: Radius.circular(11),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 6),
                                  Text(
                                    '+91',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Vertical divider
                            Container(
                              height: 48,
                              width: 1,
                              color: AppColors.border,
                            ),
                            // Phone number input
                            Expanded(
                              child: TextField(
                                controller: _recoveryPhoneController,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                autofocus: true,
                                inputFormatters: [
                                  EnglishDigitFormatter(),
                                  IndianPhoneNumberFormatter(),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.phoneNumber,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (_recoveryPhoneError != null) {
                                      setState(() {
                                        _recoveryPhoneError = null;
                                      });
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_recoveryPhoneError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _recoveryPhoneError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ] else ...[
                      // Email input field
                      TextField(
                        controller: _recoveryEmailController,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterEmailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          errorText: _recoveryEmailError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _recoveryEmailError != null
                                  ? Colors.red
                                  : AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _recoveryEmailError != null
                                  ? Colors.red
                                  : AppColors.primaryOrangeStart,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() {
                            if (_recoveryEmailError != null) {
                              setState(() {
                                _recoveryEmailError = null;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _recoveryPhoneError = null;
                            _recoveryEmailError = null;
                          });
                          Navigator.pop(context);
                        },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed:
                      (_isLoading ||
                          (_findAccountMethod == 'phone' &&
                              _recoveryPhoneController.text.length != 10) ||
                          (_findAccountMethod == 'email' &&
                              _recoveryEmailController.text.isEmpty))
                      ? null
                      : () async {
                          await _findAccount();
                          if ((_findAccountMethod == 'phone' &&
                                  _recoveryPhoneError == null) ||
                              (_findAccountMethod == 'email' &&
                                  _recoveryEmailError == null)) {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            setDialogState(() {});
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrangeStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.findMyAccount),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
