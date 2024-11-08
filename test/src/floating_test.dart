import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating/floating.dart';

void main() {
  const MethodChannel channel = MethodChannel('floating');

  TestWidgetsFlutterBinding.ensureInitialized();
  final tester =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pipAvailable':
          return false;
        case 'inPipAlready':
          return true;
        case 'enablePip':
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    Floating().reset();
    tester.setMockMethodCallHandler(channel, null);
  });

  test('isPipAvailable', () async {
    expect(await Floating().isPipAvailable, false);
  });

  test('isPipAvailable returns false if platform returned null', () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'pipAvailable') {
        return null;
      }
      return null;
    });
    expect((await Floating().isPipAvailable), false);
  });

  test('pipStatus', () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'inPipAlready':
          return true;
        case 'pipAvailable':
          return true;
      }
      return null;
    });
    expect(await Floating().pipStatus, PiPStatus.enabled);
  });

  test('pipStatus returns PiPStatus.disabled if platform returned null',
      () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pipAvailable':
          return true;
      }
      return null;
    });
    expect(await Floating().pipStatus, PiPStatus.disabled);
  });

  test(
      'pipStatus returns PiPStatus.unavailable if platform does not support PiP',
      () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pipAvailable':
          return false;
      }
      return null;
    });
    expect(await Floating().pipStatus, PiPStatus.unavailable);
  });

  test('pipStatus returns PiPStatus.automatic if PiP is auto enabled',
      () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'pipAvailable':
          return true;
        case 'inPipAlready':
          return false;
      }
      return null;
    });
    Floating().lastEnableArguments = OnLeavePiP();
    expect(await Floating().pipStatus, PiPStatus.automatic);
    Floating().lastEnableArguments = null;
  });

  test('pipStatusStream skips repeated values', () async {
    int callCount = 0;

    final results = <PiPStatus>[];
    final floating = Floating();

    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      callCount++;
      switch (methodCall.method) {
        case 'inPipAlready':
          return callCount % 3 != 0;
        case 'pipAvailable':
          return true;
      }
      return null;
    });
    await floating.pipStatusStream.firstWhere((status) {
      results.add(status);
      return status == PiPStatus.disabled;
    });

    expect(results.length, equals(2));
    expect(results, equals(const [PiPStatus.enabled, PiPStatus.disabled]));
  });

  test('enablePip', () async {
    expect(await Floating().enable(ImmediatePiP()), PiPStatus.enabled);
  });

  test('enablePip returns PiPStatus.unavailable if platform returned null',
      () async {
    tester.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'enablePip':
          return null;
      }
      return null;
    });
    expect(await Floating().enable(ImmediatePiP()), PiPStatus.unavailable);
  });

  test('Throws if unable to conform to given PiP aspect ratio', () async {
    const invalidRational = Rational(1, 1000);
    expectLater(
      Floating().enable(ImmediatePiP(aspectRatio: invalidRational)),
      throwsA(isA<RationalNotMatchingAndroidRequirementsException>()),
    );
    expectLater(
      Floating().enable(OnLeavePiP(aspectRatio: invalidRational)),
      throwsA(isA<RationalNotMatchingAndroidRequirementsException>()),
    );

    // Also, should provide error details when stringified

    expect(
      RationalNotMatchingAndroidRequirementsException(invalidRational)
          .toString()
          .contains(
              '${invalidRational.numerator}/${invalidRational.denominator}'),
      isTrue,
    );
  });
}
