import 'package:flutter/material.dart';
import 'dart:async';

import 'package:floating/floating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final floating = Floating();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    floating.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive) {
      floating.enable(Rational.square());
    }
  }

  Future<void> enablePip() async {
    final status = await floating.enable(Rational.landscape());
    debugPrint('PiP enabled? $status');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Floating example app'),
          ),
          body: Center(
            child: PiPSwitcher(
              childWhenDisabled: const Text('disabled'),
              childWhenEnabled: const Text('enabled'),
            ),
          ),
          floatingActionButton: FutureBuilder<bool>(
            future: floating.isPipAvailable,
            initialData: false,
            builder: (context, snapshot) => snapshot.data
                ? PiPSwitcher(
                    childWhenDisabled: FloatingActionButton.extended(
                      onPressed: enablePip,
                      label: const Text('Enable PiP'),
                      icon: const Icon(Icons.picture_in_picture),
                    ),
                    childWhenEnabled: const SizedBox(),
                  )
                : const Card(
                    child: Text('PiP unavailable'),
                  ),
          ),
        ),
      );
}
