import 'package:flutter/material.dart';
import '../screens/no_internet_screen.dart';
import '../services/network_checker.dart';

class NetworkGuard extends StatefulWidget {
  final Widget child;
  final bool showNoInternetOverlay;

  const NetworkGuard({
    Key? key,
    required this.child,
    this.showNoInternetOverlay = true,
  }) : super(key: key);

  @override
  State<NetworkGuard> createState() => _NetworkGuardState();
}

class _NetworkGuardState extends State<NetworkGuard> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToNetworkChanges();
  }

  void _checkInitialConnection() async {
    bool connected = await NetworkChecker.isConnected();
    if (mounted && !_isConnected && connected) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  void _listenToNetworkChanges() {
    NetworkChecker.networkStream.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected && widget.showNoInternetOverlay) {
      return const NoInternetScreen();
    }
    return widget.child;
  }
}
