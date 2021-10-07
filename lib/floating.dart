import 'dart:async';

import 'package:flutter/services.dart';

/// Manages app picture in picture mode.
///
/// PiP mode in desired mode is available only in Android
/// so iOS and web support is not planned until
/// the platforms adds native support for such feature.
class Floating {
  static const MethodChannel _channel = const MethodChannel('floating');

  /// Confirms or denies PiP availability.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  static Future<bool> get isPipAvailable async {
    final bool? supportsPip = await _channel.invokeMethod('pipAvailable');
    return supportsPip ?? false;
  }

  /// Checks current app PiP status.
  ///
  /// When `false` the app can call [enablePip] method.
  /// When the app is already in PiP mode user will have an option
  /// to bring the app to it's original size via system UI.
  static Future<bool> get isInPipMode async {
    final bool? inPipAlready = await _channel.invokeMethod('inPipAlready');
    return inPipAlready ?? false;
  }

  /// Turns on PiP mode.
  ///
  /// When enabled, PiP mode can be ended by the user via system UI.
  static Future<bool> enablePip() async {
    final bool? enabledSuccessfully = await _channel.invokeMethod('enablePip');
    return enabledSuccessfully ?? false;
  }
}
