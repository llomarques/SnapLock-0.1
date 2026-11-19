import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenSecurityService {
  static const MethodChannel _channel =
      MethodChannel('snaplock/screen_security');

  static Future<void> setEnabled(bool enabled) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>('setEnabled', enabled);
  }
}
