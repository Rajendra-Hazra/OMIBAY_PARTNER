import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  // TODO: Replace with your Tawk.to Property ID and Widget ID
  static const String _tawkPropertyId = '698c0ffbbafe421c2d8f15fd';
  static const String _tawkWidgetId = '1jh5hsrof';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            // Inject additional JavaScript to ensure Tawk.to loads properly
            _controller.runJavaScript('''
              console.log('Page finished loading');
              if (typeof Tawk_API !== 'undefined') {
                console.log('Tawk_API is defined');
              } else {
                console.log('Tawk_API is not defined yet');
              }
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            debugPrint('Error code: ${error.errorCode}');
            debugPrint('Error type: ${error.errorType}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation within tawk.to domain
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_getTawkToHtml());
  }

  String _getTawkToHtml() {
    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { 
      margin: 0; 
      padding: 0; 
      box-sizing: border-box; 
    }
    html, body { 
      width: 100%; 
      height: 100%; 
      overflow: hidden;
      background-color: #f8fafc;
    }
    #tawk-container {
      width: 100%;
      height: 100%;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
    }
    .loading {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
      color: #64748b;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .loading p { 
      margin-top: 12px; 
      font-size: 14px; 
    }
    .spinner {
      width: 40px;
      height: 40px;
      margin: 0 auto;
      border: 4px solid #f3f4f6;
      border-top: 4px solid #ff7a00;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    /* Hide default Tawk.to bubble since we're embedding it */
    #tawk-bubble-container {
      display: none !important;
    }
  </style>
</head>
<body>
  <div id="tawk-container"></div>
  <div class="loading" id="loading">
    <div class="spinner"></div>
    <p>Connecting to support...</p>
  </div>
  
  <!--Start of Tawk.to Script-->
  <script type="text/javascript">
    var Tawk_API = Tawk_API || {}, Tawk_LoadStart = new Date();
    var tawkLoaded = false;
    
    Tawk_API.customStyle = {
      visibility: {
        desktop: {
          position: 'br',
          xOffset: 0,
          yOffset: 0
        },
        mobile: {
          position: 'br',
          xOffset: 0,
          yOffset: 0
        },
        bubble: {
          rotate: '0deg',
          xOffset: 0,
          yOffset: 0
        }
      }
    };
    
    Tawk_API.onLoad = function(){
      console.log('Tawk.to loaded successfully');
      tawkLoaded = true;
      // Hide loading message
      var loading = document.getElementById('loading');
      if (loading) {
        loading.style.display = 'none';
      }
      // Maximize the chat widget after a short delay
      setTimeout(function(){
        try {
          Tawk_API.maximize();
        } catch(e) {
          console.error('Error maximizing chat:', e);
        }
      }, 500);
    };
    
    Tawk_API.onChatMaximized = function(){
      console.log('Chat maximized');
    };
    
    Tawk_API.onChatMinimized = function(){
      console.log('Chat minimized');
      // Auto-maximize again if minimized
      setTimeout(function(){
        try {
          Tawk_API.maximize();
        } catch(e) {
          console.error('Error re-maximizing chat:', e);
        }
      }, 100);
    };
    
    // Set a timeout to check if Tawk.to loaded
    setTimeout(function(){
      if (!tawkLoaded) {
        console.error('Tawk.to failed to load within timeout');
        var loading = document.getElementById('loading');
        if (loading) {
          loading.innerHTML = '<div class="spinner"></div><p>Reconnecting...</p>';
        }
        // Try to reload the script
        var existingScript = document.querySelector('script[src*="tawk.to"]');
        if (existingScript) {
          existingScript.remove();
        }
        // Reload the page after a delay
        setTimeout(function(){
          window.location.reload();
        }, 2000);
      }
    }, 10000); // 10 second timeout
    
    (function(){
      var s1 = document.createElement("script"), s0 = document.getElementsByTagName("script")[0];
      s1.async = true;
      s1.src = 'https://embed.tawk.to/$_tawkPropertyId/$_tawkWidgetId';
      s1.charset = 'UTF-8';
      s1.setAttribute('crossorigin','*');
      s1.onerror = function() {
        console.error('Failed to load Tawk.to script');
        var loading = document.getElementById('loading');
        if (loading) {
          loading.innerHTML = '<p style="color: #ef4444;">Failed to connect. Please check your internet connection.</p>';
        }
      };
      s0.parentNode.insertBefore(s1, s0);
    })();
  </script>
  <!--End of Tawk.to Script-->
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headingFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, headingFontSize, smallFontSize, iconSize),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryOrangeStart,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headingFontSize,
    double smallFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 16,
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
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.7),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Container(
            width: (iconSize * 1.5).clamp(36.0, 48.0),
            height: (iconSize * 1.5).clamp(36.0, 48.0),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'images/logo.png',
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business_center,
                size: iconSize * 0.7,
                color: AppColors.primaryOrangeStart,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.omibaySupport,
                  style: TextStyle(
                    fontSize: headingFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), // Green dot
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.online,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
