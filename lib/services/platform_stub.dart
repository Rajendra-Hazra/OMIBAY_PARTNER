// Stub file for Web platform compatibility
// This provides a fake Platform class when dart:io is not available (Web)

/// Platform stub for Web compatibility
class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isFuchsia => false;
}
