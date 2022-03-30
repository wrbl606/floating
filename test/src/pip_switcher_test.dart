import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pip_switcher_test.mocks.dart';

@GenerateMocks([Floating])
void main() {
  group(
    'Shows proper children for each PiPStatus',
    () {
      testWidgets(
        'Shows childWhenEnabled when status is enabled',
        (tester) async {
          const expectedText = 'enabled';
          const unwantedText = 'disabled';
          final mockFloating = MockFloating();
          final widget = MaterialApp(
            home: PiPSwitcher(
              floating: mockFloating,
              childWhenEnabled: Text(expectedText),
              childWhenDisabled: Text(unwantedText),
            ),
          );

          when(mockFloating.pipStatus$)
              .thenAnswer((_) => Stream.value(PiPStatus.enabled));
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          expect(find.text(expectedText), findsOneWidget);
          expect(find.text(unwantedText), findsNothing);
        },
      );
      testWidgets(
        'Shows childWhenDisabled when status is disabled',
        (tester) async {
          const expectedText = 'disabled';
          const unwantedText = 'enabled';
          final mockFloating = MockFloating();
          final widget = MaterialApp(
            home: PiPSwitcher(
              floating: mockFloating,
              childWhenEnabled: Text(unwantedText),
              childWhenDisabled: Text(expectedText),
            ),
          );

          when(mockFloating.pipStatus$)
              .thenAnswer((_) => Stream.value(PiPStatus.disabled));
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          expect(find.text(expectedText), findsOneWidget);
          expect(find.text(unwantedText), findsNothing);
        },
      );
      testWidgets(
        'Shows childWhenDisabled when status is unavailable',
        (tester) async {
          const expectedText = 'unavailable';
          const unwantedText = 'enabled';
          final mockFloating = MockFloating();
          final widget = MaterialApp(
            home: PiPSwitcher(
              floating: mockFloating,
              childWhenEnabled: Text(unwantedText),
              childWhenDisabled: Text(expectedText),
            ),
          );

          when(mockFloating.pipStatus$)
              .thenAnswer((_) => Stream.value(PiPStatus.unavailable));
          await tester.pumpWidget(widget);
          await tester.pumpAndSettle();

          expect(find.text(expectedText), findsOneWidget);
          expect(find.text(unwantedText), findsNothing);
        },
      );
    },
  );
}
