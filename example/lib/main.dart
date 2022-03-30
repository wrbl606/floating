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

class _MyAppState extends State<MyApp> {
  final floating = Floating();

  @override
  void dispose() {
    floating.dispose();
    super.dispose();
  }

  Future<void> enablePip() async {
    final status = await floating.enable();
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
