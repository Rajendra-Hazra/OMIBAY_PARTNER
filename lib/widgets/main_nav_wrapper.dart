import 'package:flutter/material.dart';
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
  DateTime? _lastBackPressTime;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return; // Already popped, do nothing

    final now = DateTime.now();

    // If this is the first back press OR more than 2 seconds since last press
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;

      // Show snackbar message
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 20,
            right: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Update state to allow exit on next press within 2 seconds
      setState(() {
        _canPop = true;
      });

      // Reset _canPop after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _canPop = false;
          });
        }
      });
    } else {
      // Second back press within 2 seconds - exit the app
      Navigator.of(context).pop();
    }
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    JobsListScreen(),
    EarningsScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    String routeName = '/home';
    switch (index) {
      case 0:
        routeName = '/home';
        break;
      case 1:
        routeName = '/jobs';
        break;
      case 2:
        routeName = '/earnings';
        break;
      case 3:
        routeName = '/account';
        break;
    }

    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) => _handlePopInvoked(didPop),
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
