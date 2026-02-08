import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/network_checker.dart';
import 'package:partner_app/l10n/app_localizations.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isLoading = false;

  Future<void> _tryAgain() async {
    setState(() {
      _isLoading = true;
    });

    bool connected = await NetworkChecker.isConnected();

    if (connected) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Static illustration using SVG
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SvgPicture.asset(
                        'assets/images/no_internet.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Builder(
                        builder: (context) {
                          final loc = AppLocalizations.of(context)!;
                          return Text(
                            loc.noInternetConnection, // Localized string
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Builder(
                        builder: (context) {
                          final loc = AppLocalizations.of(context)!;
                          return Text(
                            loc.pleaseCheckYourNetwork, // Localized string
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Builder(
                          builder: (context) {
                            final loc = AppLocalizations.of(context)!;
                            return OutlinedButton(
                              onPressed: _isLoading ? null : _tryAgain,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(
                                  0xFF4CAF50,
                                ), // Green text
                                side: const BorderSide(
                                  color: Color(0xFF4CAF50),
                                ), // Green outline
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF4CAF50),
                                            ),
                                      ),
                                    )
                                  : Text(
                                      loc.tryAgain, // Localized string
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
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
        ),
      ),
    );
  }
}
