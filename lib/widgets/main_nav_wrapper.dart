import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home/home_screen.dart';
import '../screens/jobs/jobs_list_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/account/account_screen.dart';
import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  const MainNavigationWrapper({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    JobsListScreen(),
    EarningsScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
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
            // First back press - show exit message
            _lastBackPressTime = now;

            // Clear any existing snackbars and show new one
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.pressBackAgainToExit,
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                // Position just above the bottom navigation bar with no gap
                margin: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
