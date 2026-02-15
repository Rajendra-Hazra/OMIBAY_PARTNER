import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home/home_screen.dart';
import '../screens/jobs/jobs_list_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/account/account_screen.dart';
import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import '../core/network/api_endpoints.dart';
import '../repositories/order_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'incoming_job_modal.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  const MainNavigationWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _selectedIndex;
  StreamSubscription<Map<String, dynamic>>? _incomingJobSubscription;
  bool _isJobModalShowing = false;
  late final OrderRepository _orderRepository;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _orderRepository = OrderRepositoryImpl(baseUrl: ApiEndpoints.baseUrl);
    _checkDocumentVerification();
    _listenForIncomingJobs();
  }

  Future<void> _checkDocumentVerification() async {
    final prefs = await SharedPreferences.getInstance();
    final isAadharVerified = prefs.getBool('aadhar_verified') ?? false;
    final isPanVerified = prefs.getBool('pan_verified') ?? false;
    final isDlVerified = prefs.getBool('dl_verified') ?? false;
    final isSkillVerified = prefs.getBool('skill_verified') ?? false;

    final isAllVerified =
        isAadharVerified && isPanVerified && isDlVerified && isSkillVerified;
    final isVerificationSkipped =
        prefs.getBool('verification_skipped') ?? false;

    // Check if profile details are filled (using name as a proxy, or check login method)
    // If user has verified Work and Aadhar, and has basic profile details, we can skip
    final hasProfileName = prefs.getString('profile_name')?.isNotEmpty ?? false;
    final isProfileVerified =
        hasProfileName || prefs.getBool('phone_verified') == true;

    // Allow access if:
    // 1. All docs verified OR
    // 2. Verification skipped explicitly OR
    // 3. (Work Selected AND Aadhar Verified AND Profile details filled) -> User request
    final canBypass =
        isAllVerified ||
        isVerificationSkipped ||
        hasProfileName || // Allow access if we have a profile name (partially onboarded/restored)
        (isSkillVerified && isAadharVerified && isProfileVerified);

    if (!canBypass && mounted) {
      // Redirect to verification screen if any required document is not verified and not skipped
      Navigator.pushReplacementNamed(context, '/verification');
    }
  }

  @override
  void dispose() {
    _incomingJobSubscription?.cancel();
    super.dispose();
  }

  /// Listen for incoming job notifications from FCM
  void _listenForIncomingJobs() {
    try {
      _incomingJobSubscription = NotificationService.instance.incomingJobStream
          .listen((jobData) {
            // Check if this is a direct action from notification buttons
            if (jobData['action'] == 'accept') {
              _handleJobAccepted(jobData);
              return;
            } else if (jobData['action'] == 'decline') {
              _handleJobDeclined(jobData);
              return;
            }

            // Show the incoming job modal
            _showIncomingJobModal(jobData);
          });
    } catch (e) {
      debugPrint('NotificationService not available on this platform: $e');
    }
  }

  /// Show the incoming job modal dialog
  void _showIncomingJobModal(Map<String, dynamic> jobData) {
    // Prevent multiple modals from showing
    if (_isJobModalShowing) {
      debugPrint('Job modal already showing, updating existing notification');
      return;
    }

    _isJobModalShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false, // User must accept or decline
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => IncomingJobModal(
        job: jobData,
        onAccept: () {
          // Modal closes itself now
          _isJobModalShowing = false;
          _handleJobAccepted(jobData);
        },
        onDecline: () {
          // Modal closes itself now
          _isJobModalShowing = false;
          _handleJobDeclined(jobData);
        },
      ),
    ).then((_) {
      _isJobModalShowing = false;
    });
  }

  /// Handle when user accepts the job
  Future<void> _handleJobAccepted(Map<String, dynamic> jobData) async {
    final orderId = jobData['id'] ?? jobData['job_id'];
    debugPrint('Job accepted: $orderId');

    if (orderId == null) return;

    final success = await _orderRepository.acceptOrder(orderId);

    if (success) {
      Fluttertoast.showToast(msg: "Order accepted successfully!");
      // Navigate to active job screen or jobs tab
      // If we are on home tab, it will refresh.
      // Moving to Jobs tab (index 1) might be better?
      // For now keeping existing behavior but maybe refreshing?

      // Actually, let's navigate to active jobs page which shows details
      // Or switch to Jobs tab
      Navigator.pushNamed(context, '/active-job', arguments: jobData);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to accept order",
        backgroundColor: Colors.red,
      );
    }
  }

  /// Handle when user declines the job
  Future<void> _handleJobDeclined(Map<String, dynamic> jobData) async {
    final orderId = jobData['id'] ?? jobData['job_id'];
    debugPrint('Job declined: $orderId');

    if (orderId == null) return;

    final success = await _orderRepository.rejectOrder(
      orderId,
      reason: "Partner declined",
    );

    if (success) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)?.jobDeclined ?? 'Job declined',
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to decline order",
        backgroundColor: Colors.red,
      );
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    JobsListScreen(),
    EarningsScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // Navigate to the corresponding route for proper URL updates on web
    final routes = ['/home', '/jobs', '/earnings', '/account'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  /// Tracks the timestamp of the last back button press.
  /// Used to implement double-back-to-exit functionality on Home screen.
  DateTime? _lastBackPressTime;

  /// Controls whether the system can pop this route.
  /// Only true when on Home screen and user pressed back once within 2 seconds.
  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    // Custom back navigation behavior:
    // - Home screen (index 0): Double-back-to-exit
    // - Other tabs: Navigate back to Home tab
    // - Pushed screens: Default Flutter back behavior (handled by their own routes)
    return PopScope(
      // Only allow system pop when double-back-to-exit is triggered on Home screen
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) {
        // If pop was successful, nothing more to do
        if (didPop) return;

        if (_selectedIndex == 0) {
          // HOME SCREEN: Implement double-back-to-exit
          final now = DateTime.now();
          final isSecondPressWithinTimeout =
              _lastBackPressTime != null &&
              now.difference(_lastBackPressTime!) <= const Duration(seconds: 2);

          if (isSecondPressWithinTimeout) {
            // Second back press within 2 seconds - exit the app
            SystemNavigator.pop();
          } else {
            // First back press - show Flipkart-style compact exit message with logo
            _lastBackPressTime = now;

            // Clear any existing snackbars and show new one
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'images/logo.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    // Text
                    Text(
                      AppLocalizations.of(context)!.pressBackAgainToExit,
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF323232),
                // Center it with proper spacing above bottom nav
                margin: const EdgeInsets.only(
                  bottom: 20,
                  left: 100,
                  right: 100,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            );

            // Enable pop for the next 2 seconds
            setState(() {
              _canPop = true;
            });

            // Reset _canPop after 2 seconds timeout
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _canPop = false;
                });
              }
            });
          }
        } else {
          // OTHER TABS (Jobs, Earnings, Account): Navigate back to Home tab
          // This provides a consistent "back to home" experience from any tab
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.black.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -2), // Shadow moves upwards
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation:
                  0, // Set elevation to 0 since we're using Container shadow
              selectedItemColor: AppColors.primaryOrangeStart,
              unselectedItemColor: AppColors.textSecondary,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.work),
                  label: AppLocalizations.of(context)!.jobs,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: AppLocalizations.of(context)!.earnings,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: AppLocalizations.of(context)!.account,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
