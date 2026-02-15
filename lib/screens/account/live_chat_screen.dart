import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_config.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isControllerReady = false;

  // User data for tawk.to attributes
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _partnerId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load logged-in user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to get user data from various storage keys
      _userName =
          prefs.getString('profile_name') ??
          prefs.getString('user_name') ??
          prefs.getString('fullName') ??
          'Partner';

      _userEmail =
          prefs.getString('profile_email') ??
          prefs.getString('user_email') ??
          prefs.getString('email') ??
          '';

      _userPhone =
          prefs.getString('profile_phone') ??
          prefs.getString('user_phone') ??
          prefs.getString('mobileNumber') ??
          '';

      _partnerId =
          prefs.getString('partner_id') ?? prefs.getString('partnerId') ?? '';

      debugPrint(
        '📞 Tawk.to User Data: $_userName | $_userEmail | $_userPhone | ID: $_partnerId',
      );

      // Initialize WebView after loading user data
      _initWebView();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _initWebView();
    }
  }

  void _initWebView() {
    final propertyId = AppConfig.tawkPropertyId;
    final widgetId = AppConfig.tawkWidgetId;

    // Use tawk.to direct chat URL - this avoids localStorage security issues
    final tawkDirectUrl = 'https://tawk.to/chat/$propertyId/$widgetId';

    debugPrint('🔧 Initializing Tawk.to WebView with URL: $tawkDirectUrl');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('📄 Page started: $url');
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            debugPrint('✅ Page finished: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
            // Inject user data into Tawk.to after page loads
            _injectUserData();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            debugPrint('Error code: ${error.errorCode}');
            debugPrint('Error type: ${error.errorType}');
            // Don't show error for subresource failures
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation request: ${request.url}');
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(tawkDirectUrl));

    if (mounted) {
      setState(() {
        _isControllerReady = true;
      });
    }
  }

  /// Inject logged-in user data into Tawk.to widget
  /// This ensures support team can see partner details immediately
  void _injectUserData() {
    if (_controller == null) return;

    // Build the attributes object
    final attributes = <String, String>{};

    if (_userName != null && _userName!.isNotEmpty && _userName != 'Partner') {
      attributes['name'] = _userName!;
    }

    if (_userEmail != null && _userEmail!.isNotEmpty) {
      attributes['email'] = _userEmail!;
    }

    if (_userPhone != null && _userPhone!.isNotEmpty) {
      attributes['phone'] = _userPhone!;
    }

    if (_partnerId != null && _partnerId!.isNotEmpty) {
      attributes['Partner ID'] = _partnerId!;
    }

    // Add partner identifier
    attributes['User Type'] = 'Partner';

    // Convert attributes to JavaScript object string
    final jsAttributes = attributes.entries
        .map((e) => '"${e.key}": "${_escapeJsString(e.value)}"')
        .join(', ');

    // Inject JavaScript to set user attributes - wait longer for direct URL load
    final jsCode =
        '''
      (function() {
        console.log('🔄 Injecting user data into Tawk.to...');
        
        var maxAttempts = 40;
        var attempts = 0;
        
        var injectUserData = function() {
          if (typeof Tawk_API !== 'undefined' && typeof Tawk_API.setAttributes === 'function') {
            console.log('✅ Tawk_API found, setting attributes...');
            
            try {
              Tawk_API.setAttributes({
                $jsAttributes
              }, function(error) {
                if (error) {
                  console.error('❌ Error setting Tawk.to attributes:', error);
                } else {
                  console.log('✅ User attributes set successfully');
                }
              });
            } catch(e) {
              console.error('Exception setting attributes:', e);
            }
            
            return true;
          }
          return false;
        };
        
        var checkInterval = setInterval(function() {
          attempts++;
          if (injectUserData()) {
            clearInterval(checkInterval);
          } else if (attempts >= maxAttempts) {
            console.warn('⚠️ Tawk_API not available after ' + attempts + ' attempts');
            clearInterval(checkInterval);
          }
        }, 500);
      })();
    ''';

    _controller!.runJavaScript(jsCode);
    debugPrint('📤 User data injection script executed');
  }

  /// Escape special characters for JavaScript string
  String _escapeJsString(String str) {
    return str
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        8,
        103,
        192,
      ), // Dark color matching tawk.to
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen WebView
            if (_isControllerReady && _controller != null)
              WebViewWidget(controller: _controller!),

            // Loading indicator
            if (_isLoading)
              Container(
                color: const Color(0xFF1A1A2E),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrangeStart,
                  ),
                ),
              ),

            // Error state
            if (_hasError)
              Container(
                color: const Color(0xFF1A1A2E),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load chat',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isControllerReady = false;
                          });
                          _loadUserData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrangeStart,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

            // Initial loading (before controller is ready)
            if (!_isControllerReady)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrangeStart,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
