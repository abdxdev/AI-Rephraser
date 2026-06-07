import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles communication with the native Android platform.
///
/// Used to enable/disable context menu actions and show native toasts.
class PlatformService {
  static const _channel = MethodChannel('com.example.test_app/platform');

  /// Enable or disable a process text action component in the Android manifest.
  static Future<void> setActionEnabled(String actionId, bool enabled) async {
    try {
      await _channel.invokeMethod('setActionEnabled', {
        'actionId': actionId,
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      // Silently fail if platform channel is not available
      // (e.g., running on non-Android platform)
      debugPrint('Failed to set action enabled: ${e.message}');
    }
  }

  /// Show a native Android toast message.
  static Future<void> showToast(String message) async {
    try {
      await _channel.invokeMethod('showToast', {'message': message});
    } on PlatformException catch (_) {
      // Ignore — toast is non-critical
    }
  }
}
