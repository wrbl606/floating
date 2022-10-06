import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../lib/main.dart' as app;

void main() {
  patrolTest(
    'Detects PiP state',
    ($) async {
      await $.pumpWidgetAndSettle(app.MyApp());
      expect($('disabled'), findsOneWidget);
      await $.tap($('Enable PiP'));
      await $.waitUntilVisible(
        $('enabled'),
        timeout: const Duration(seconds: 1),
      );
    },
  );
}
