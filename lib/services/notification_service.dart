import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Conditional import for platform detection (Web-safe)
import 'platform_stub.dart' if (dart.library.io) 'dart:io' as platform_io;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');

  // For incoming job notifications, the system will play the channel sound
  // The notification is shown automatically by FCM for data+notification messages
  if (message.data['type'] == 'incoming_job') {
    await NotificationService.instance.showIncomingJobNotification(
      message.data,
      fromBackground: true,
    );
  }
}

/// Singleton notification service for handling FCM and local notifications
/// Implements Uber/Ola-style incoming job alerts with:
/// - High-importance notification channel with custom sound
/// - Background/foreground/terminated state handling
/// - Non-dismissible ongoing notifications
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Firebase messaging is only available on mobile platforms (not web)
  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channel IDs
  static const String _incomingJobChannelId = 'incoming_job_channel';
  static const String _incomingJobChannelName = 'Incoming Job Alerts';
  static const String _incomingJobChannelDescription =
      'High-priority alerts for incoming job requests';

  // Notification IDs - using fixed ID ensures only one notification at a time
  static const int _incomingJobNotificationId = 1001;

  // Stream controller for incoming job events
  final StreamController<Map<String, dynamic>> _incomingJobController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of incoming job data for UI to listen to
  Stream<Map<String, dynamic>> get incomingJobStream =>
      _incomingJobController.stream;

  // Global navigator key for showing dialogs from notification taps
  static GlobalKey<NavigatorState>? navigatorKey;

  // Track if notification is currently active
  bool _isJobNotificationActive = false;
  bool get isJobNotificationActive => _isJobNotificationActive;

  /// Initialize the notification service
  /// Call this in main() after Firebase.initializeApp()
  Future<void> initialize({GlobalKey<NavigatorState>? navKey}) async {
    navigatorKey = navKey;

    // Initialize Firebase Messaging only on mobile platforms
    if (!kIsWeb) {
      _firebaseMessaging = FirebaseMessaging.instance;
    }

    // Request notification permissions (Android 13+ and iOS)
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM handlers
    await _configureFCM();

    debugPrint('NotificationService initialized successfully');
  }

  /// Request notification permissions for Android 13+ and iOS
  Future<bool> _requestPermissions() async {
    // Skip permissions on Web
    if (kIsWeb || _firebaseMessaging == null) {
      debugPrint('Notification permissions not available on Web');
      return false;
    }

    // Request FCM permissions (covers iOS and Android 13+)
    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true, // For urgent notifications like incoming jobs
      provisional: false,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('Notification permission granted: $granted');
    return granted;
  }

  /// Initialize flutter_local_notifications with Android and iOS settings
  Future<void> _initializeLocalNotifications() async {
    // Skip local notifications on Web - they're not supported
    if (kIsWeb) {
      debugPrint('Local notifications not supported on Web');
      return;
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Create Android notification channel (only on Android)
    if (_isAndroid) {
      await _createIncomingJobChannel();
    }
  }

  /// Check if running on Android (Web-safe)
  bool get _isAndroid {
    if (kIsWeb) return false;
    try {
      return platform_io.Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  /// Create high-importance notification channel for incoming jobs (Android)
  Future<void> _createIncomingJobChannel() async {
    const channel = AndroidNotificationChannel(
      _incomingJobChannelId,
      _incomingJobChannelName,
      description: _incomingJobChannelDescription,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('incoming_job'),
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFFF6B00), // Orange LED
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    debugPrint('Incoming job notification channel created');
  }

  /// Configure Firebase Cloud Messaging handlers
  Future<void> _configureFCM() async {
    // Skip FCM configuration on Web
    if (kIsWeb || _firebaseMessaging == null) {
      debugPrint('FCM not available on Web');
      return;
    }

    // Get FCM token for server registration
    final token = await _firebaseMessaging!.getToken();
    debugPrint('FCM Token: $token');

    // Listen for token refresh
    _firebaseMessaging!.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // TODO: Send new token to your backend server
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _firebaseMessaging!.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      _handleNotificationTap(initialMessage);
    }

    // Set foreground notification presentation options for iOS
    await _firebaseMessaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Handle messages when app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    if (message.data['type'] == 'incoming_job') {
      // Show local notification with sound and vibration
      showIncomingJobNotification(message.data, fromBackground: false);

      // Also emit to stream so UI can show the modal
      _emitIncomingJob(message.data);
    }
  }

  /// Handle notification tap (app opened from background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');

    if (message.data['type'] == 'incoming_job') {
      _emitIncomingJob(message.data);
    }
  }

  /// Emit incoming job data to stream
  void _emitIncomingJob(Map<String, dynamic> data) {
    final jobData = _parseJobData(data);
    _incomingJobController.add(jobData);
  }

  /// Parse job data from FCM message
  Map<String, dynamic> _parseJobData(Map<String, dynamic> data) {
    // Parse JSON if job data is stringified
    if (data['job'] != null && data['job'] is String) {
      try {
        return json.decode(data['job']) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error parsing job data: $e');
      }
    }

    // Return raw data with defaults
    return {
      'id': data['job_id'] ?? data['id'] ?? '',
      'service': data['service'] ?? 'Service',
      'serviceKey': data['service_key'] ?? data['serviceKey'] ?? '',
      'customer': data['customer'] ?? 'Customer',
      'location': data['location'] ?? 'Location',
      'price': data['price'] ?? '0',
      'distance': data['distance'] ?? '0 km',
      'eta': data['eta'] ?? '0 min',
      'timeType': data['time_type'] ?? data['timeType'] ?? 'immediate',
      'scheduledDate': data['scheduled_date'] ?? data['scheduledDate'],
      'scheduledTime': data['scheduled_time'] ?? data['scheduledTime'],
    };
  }

  /// Show incoming job notification with high importance and custom sound
  Future<void> showIncomingJobNotification(
    Map<String, dynamic> data, {
    bool fromBackground = false,
  }) async {
    // Skip local notifications on Web
    if (kIsWeb) {
      debugPrint(
        'Local notifications not supported on Web - emitting to stream only',
      );
      _emitIncomingJob(data);
      return;
    }

    _isJobNotificationActive = true;

    final jobData = _parseJobData(data);
    final serviceName = jobData['service'] ?? 'New Job';
    final price = jobData['price'] ?? '0';
    final location = jobData['location'] ?? 'Nearby';

    // Android notification details
    final androidDetails = AndroidNotificationDetails(
      _incomingJobChannelId,
      _incomingJobChannelName,
      channelDescription: _incomingJobChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('incoming_job'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      ongoing: true, // Non-dismissible
      autoCancel: false,
      fullScreenIntent: true, // Show on lock screen
      category: AndroidNotificationCategory.call, // Treat like a call
      visibility: NotificationVisibility.public,
      ticker: 'New job request',
      styleInformation: BigTextStyleInformation(
        'Service: $serviceName\nEarning: ₹$price\nLocation: $location',
        contentTitle: '🔔 New Job Request!',
        summaryText: 'Tap to view details',
      ),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'accept',
          'Accept',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'decline',
          'Decline',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'incoming_job.mp3', // iOS custom sound
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'incoming_job',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification with fixed ID (replaces existing if any)
    await _localNotifications.show(
      _incomingJobNotificationId,
      '🔔 New Job Request!',
      '$serviceName - ₹$price - $location',
      notificationDetails,
      payload: json.encode(data),
    );

    debugPrint('Incoming job notification shown');
  }

  /// Cancel the incoming job notification and stop sound
  Future<void> cancelIncomingJobNotification() async {
    _isJobNotificationActive = false;
    // Skip on Web
    if (!kIsWeb) {
      await _localNotifications.cancel(_incomingJobNotificationId);
    }
    debugPrint('Incoming job notification cancelled');
  }

  /// Handle notification tap callback
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.actionId == 'accept') {
      instance._handleNotificationAction(response.payload, true);
    } else if (response.actionId == 'decline') {
      instance._handleNotificationAction(response.payload, false);
    } else {
      // Regular tap - show the incoming job modal
      instance._handleRegularNotificationTap(response.payload);
    }
  }

  /// Handle background notification tap callback
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('Background notification tapped: ${response.payload}');
    // This will trigger when app opens from terminated state
    _onNotificationTapped(response);
  }

  /// Handle notification action (accept/decline button)
  void _handleNotificationAction(String? payload, bool accepted) {
    cancelIncomingJobNotification();

    if (payload != null) {
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        final jobData = _parseJobData(data);
        jobData['action'] = accepted ? 'accept' : 'decline';
        _incomingJobController.add(jobData);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle regular notification tap (open modal)
  void _handleRegularNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        _emitIncomingJob(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Get FCM token for server registration
  Future<String?> getToken() async {
    if (kIsWeb || _firebaseMessaging == null) return null;
    return await _firebaseMessaging!.getToken();
  }

  /// Subscribe to a topic for receiving targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb || _firebaseMessaging == null) {
      debugPrint('Topic subscription not available on Web');
      return;
    }
    await _firebaseMessaging!.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb || _firebaseMessaging == null) {
      debugPrint('Topic unsubscription not available on Web');
      return;
    }
    await _firebaseMessaging!.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb || _firebaseMessaging == null) return false;
    final settings = await _firebaseMessaging!.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Dispose resources
  void dispose() {
    _incomingJobController.close();
  }
}
