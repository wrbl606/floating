
import 'dart:async';

import 'package:flutter/services.dart';

class Floating {
  static const MethodChannel _channel =
      const MethodChannel('floating');

  static Future<bool> get isPipAvailable async {
    final bool supportsPip = await _channel.invokeMethod('pipAvailable');
    return supportsPip;
  }

  static Future<bool> get isInPipMode async {
    final bool inPipAlready = await _channel.invokeMethod('inPipAlready');
    return inPipAlready;
  }

  static Future<bool> enablePip() async {
    final bool enabledSuccessfully = await _channel.invokeMethod('enablePip');
    return enabledSuccessfully;
  }
}
