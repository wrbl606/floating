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
  ///
  /// Provider [aspectRatio] to override default 16/9 aspect ratio.
  /// [aspectRatio] must fit into Android-supported values:
  /// min: 1/2.39, max: 2.39/1, otherwise [RationalNotMatchingAndroidRequirementsException]
  /// will be thrown.
  /// Note: this will not make any effect on Android SDK older than 26.
  Future<PiPStatus> enable(
      [Rational aspectRatio = const Rational.landscape()]) async {
    if (!aspectRatio.fitsInAndroidRequirements) {
      throw RationalNotMatchingAndroidRequirementsException(aspectRatio);
    }

    final bool? enabledSuccessfully = await _channel.invokeMethod(
      'enablePip',
      aspectRatio.toMap(),
    );
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

/// Represents rational in [numerator]/[denominator] notation.
class Rational {
  final int numerator;
  final int denominator;

  const Rational(this.numerator, this.denominator);
  const Rational.square()
      : numerator = 1,
        denominator = 1;
  const Rational.landscape()
      : numerator = 16,
        denominator = 9;
  const Rational.vertical()
      : numerator = 9,
        denominator = 16;

  @override
  String toString() =>
      'Rational(numerator: $numerator, denominator: $denominator)';

  Map<String, dynamic> toMap() => {
        'numerator': numerator,
        'denominator': denominator,
      };
}

/// Extension for [Rational] to confirm whether Android aspect ration
/// requirements are met or not.
extension on Rational {
  /// Checks whether given [Rational] instance fits into Android requirements
  /// or not.
  ///
  /// Android docs specified boundaries as inclusive.
  bool get fitsInAndroidRequirements {
    final aspectRatio = numerator / denominator;
    final min = 1 / 2.39;
    final max = 2.39;
    return (min <= aspectRatio) && (aspectRatio <= max);
  }
}

/// Provides details about Android requirements and compares current
/// [rational] value to those.
class RationalNotMatchingAndroidRequirementsException implements Exception {
  final Rational rational;

  RationalNotMatchingAndroidRequirementsException(this.rational);

  @override
  String toString() => 'RationalNotMatchingAndroidRequirementsException('
      '${rational.numerator}/${rational.denominator} does not fit into '
      'Android-supported aspect ratios. Boundaries: '
      'min: 1/2.39, max: 2.39/1. '
      ')';
}
