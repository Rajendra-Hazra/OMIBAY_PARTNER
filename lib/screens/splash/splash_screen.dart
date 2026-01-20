import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward().then((value) async {
      // Check login status
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (mounted) {
        if (isLoggedIn) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final logoSize = (132 * paddingScale).clamp(100.0, 160.0);
    final titleFontSize = (screenWidth * 0.08).clamp(24.0, 36.0);
    final bodyFontSize = (screenWidth * 0.04).clamp(14.0, 18.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0 * paddingScale),
                    child: Image.asset(
                      'images/logo.png',
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.business_center,
                        size: (60 * paddingScale).clamp(48.0, 80.0),
                        color: AppColors.primaryOrangeStart,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 * paddingScale),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8 * paddingScale),
                Text(
                  AppLocalizations.of(context)!.appSlogan,
                  style: TextStyle(
                    color: const Color(0xFF4B5563),
                    fontSize: bodyFontSize,
                  ),
                ),
                SizedBox(height: 60 * paddingScale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF2563EB),
                      size: (20 * paddingScale).clamp(18.0, 24.0),
                    ),
                    SizedBox(width: 8 * paddingScale),
                    Text(
                      AppLocalizations.of(context)!.continuingToLogin,
                      style: TextStyle(
                        color: const Color(0xFF4B5563),
                        fontSize: bodyFontSize - 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * paddingScale),
                Container(
                  width: (200 * paddingScale).clamp(150.0, 250.0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width:
                          (200 * paddingScale).clamp(150.0, 250.0) *
                          _animation.value,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
