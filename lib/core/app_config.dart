/// Application Configuration
///
/// Contains sensitive configuration values that should be managed securely.
/// In production, consider using environment variables or secure storage.
class AppConfig {
  AppConfig._();

  // ==================== Tawk.to Configuration ====================

  /// Tawk.to Property ID
  /// Get this from: https://dashboard.tawk.to/#/admin/property
  ///
  /// IMPORTANT: In production, move this to:
  /// - Environment variables (.env file)
  /// - Firebase Remote Config
  /// - Secure backend endpoint
  static const String tawkPropertyId = '698c0ffbbafe421c2d8f15fd';

  /// Tawk.to Widget ID
  /// Get this from: https://dashboard.tawk.to/#/admin/property
  static const String tawkWidgetId = '1jh5hsrof';

  /// Full Tawk.to embed URL
  static String get tawkEmbedUrl =>
      'https://embed.tawk.to/$tawkPropertyId/$tawkWidgetId';

  /// Direct chat URL (for external browser opening if needed)
  static String get tawkChatUrl =>
      'https://tawk.to/chat/$tawkPropertyId/$tawkWidgetId';

  // ==================== API Configuration ====================
  // (Already configured in ApiEndpoints, but can be centralized here)

  // ==================== Feature Flags ====================

  /// Enable/disable live chat feature
  static const bool enableLiveChat = true;

  /// Enable user data injection in chat
  static const bool enableChatUserContext = true;

  /// Enable chat notifications
  static const bool enableChatNotifications = true;
}
