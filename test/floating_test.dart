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
      expect(await Floating.isPipAvailable, false);
    });

    test('isPipAvailable returns false if platform returned null', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'pipAvailable') {
          return null;
        }
      });
      expect(await Floating.isPipAvailable, false);
    });
  });

  group('check if app is in PiP mode', () {
    test('isInPipMode', () async {
      expect(await Floating.isInPipMode, true);
    });

    test('isInPipMode returns false if platform returned null', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'isInPipMode') {
          return null;
        }
      });
      expect(await Floating.isInPipMode, false);
    });
  });

  group('enabling PiP mode', () {
    test('enablePip', () async {
      expect(await Floating.enablePip(), true);
    });

    test('enablePip returns false if platform returned null', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'enablePip') {
          return null;
        }
      });
      expect(await Floating.enablePip(), false);
    });
  });
}
