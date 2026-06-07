import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformService {
  static const _channel = MethodChannel('com.example.test_app/platform');

  static Future<void> setActionEnabled(String actionId, bool enabled) async {
    try {
      await _channel.invokeMethod('setActionEnabled', {
        'actionId': actionId,
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      // Handle error
      debugPrint('Failed to set action enabled: $e');
    }
  }

  static Future<void> showToast(String message) async {
    try {
      await _channel.invokeMethod('showToast', {'message': message});
    } on PlatformException catch (_) {}
  }
}
