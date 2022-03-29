import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating/floating.dart';

void main() {
  const MethodChannel channel = MethodChannel('floating');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pipAvailable':
          return false;
        case 'inPipAlready':
          return true;
        case 'enablePip':
          return true;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('check if PiP is available', () {
    test('isPipAvailable', () async {
      expect(await Floating().isPipAvailable, false);
    });

    test('isPipAvailable returns false if platform returned null', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'pipAvailable') {
          return null;
        }
      });
      expect((await Floating().isPipAvailable), false);
    });
  });

  group('check if app is in PiP mode', () {
    test('pipStatus', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'inPipAlready':
            return true;
          case 'pipAvailable':
            return true;
        }
      });
      expect(await Floating().pipStatus, PiPStatus.enabled);
    });

    test('pipStatus returns PiPStatus.disabled if platform returned null',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'pipAvailable':
            return true;
        }
      });
      expect(await Floating().pipStatus, PiPStatus.disabled);
    });

    test(
        'pipStatus returns PiPStatus.unavailable if platform does not support PiP',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'pipAvailable':
            return false;
        }
      });
      expect(await Floating().pipStatus, PiPStatus.unavailable);
    });
  });

  group('probe if app is in PiP mode', () {
    test('pipStatus\$ skips repeated values', () async {
      int callCount = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        callCount++;
        switch (methodCall.method) {
          case 'inPipAlready':
            return callCount % 3 != 0;
          case 'pipAvailable':
            return true;
        }
      });

      final results = <PiPStatus>[];
      final floating = Floating();
      await floating.pipStatus$.firstWhere((status) {
        results.add(status);
        return status == PiPStatus.disabled;
      });
      floating.dispose();

      expect(results.length, equals(2));
      expect(results, equals(const [PiPStatus.enabled, PiPStatus.disabled]));
    });
  });

  group('enabling PiP mode', () {
    test('enablePip', () async {
      expect(await Floating().enable(), PiPStatus.enabled);
    });

    test('enablePip returns PiPStatus.unavailable if platform returned null',
        () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'enablePip':
            return null;
        }
      });
      expect(await Floating().enable(), PiPStatus.unavailable);
    });
  });
}
