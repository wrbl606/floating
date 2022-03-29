part of floating;

enum PiPStatus { enabled, disabled, unavailable }

/// Manages app picture in picture mode.
///
/// PiP mode in is available only in Android.
/// Support for other platforms is not planned.
class Floating {
  final _channel = const MethodChannel('floating');
  final _controller = StreamController<PiPStatus>();
  final Duration _probeInterval;
  Timer? _timer;
  Stream<PiPStatus>? _stream;

  Floating({
    Duration probeInterval = const Duration(milliseconds: 100),
  }) : _probeInterval = probeInterval;

  /// Confirms or denies PiP availability.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  Future<bool> get isPipAvailable async {
    final bool? supportsPip = await _channel.invokeMethod('pipAvailable');
    return supportsPip ?? false;
  }

  /// Checks current app PiP status.
  ///
  /// When `false` the app can call [enable] method.
  /// When the app is already in PiP mode user will have an option
  /// to bring the app to it's original size via system UI.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  Future<PiPStatus> get pipStatus async {
    if (!await isPipAvailable) {
      return PiPStatus.unavailable;
    }
    final bool? inPipAlready = await _channel.invokeMethod('inPipAlready');
    return inPipAlready ?? false ? PiPStatus.enabled : PiPStatus.disabled;
  }

  // Notifies about changes of the PiP mode.
  //
  // PiP state is probed, by default in the 100 milliseconds interval.
  // The probing interval can be configured in the constructor.
  //
  // This stream will call listeners only when the value changed.
  Stream<PiPStatus> get pipStatus$ {
    _timer ??= Timer.periodic(
      _probeInterval,
      (_) async => _controller.add(await pipStatus),
    );
    _stream ??= _controller.stream.asBroadcastStream();
    return _stream!.distinct();
  }

  /// Turns on PiP mode.
  ///
  /// When enabled, PiP mode can be ended by the user via system UI.
  ///
  /// PiP may be unavailable because of system settings managed
  /// by admin or device manufacturer. Also, the device may
  /// have Android version that was released without this feature.
  Future<PiPStatus> enable() async {
    final bool? enabledSuccessfully = await _channel.invokeMethod('enablePip');
    return enabledSuccessfully ?? false
        ? PiPStatus.enabled
        : PiPStatus.unavailable;
  }

  // Disposes internal components used to update the [isInPipMode$] stream.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
