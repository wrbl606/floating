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
    final status = await Floating().enable();
    debugPrint('PiP enabled? $status');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Floating example app'),
          ),
          body: Center(
            child: StreamBuilder<PiPStatus>(
              stream: floating.pipStatus$,
              initialData: PiPStatus.unavailable,
              builder: (context, snapshot) =>
                  Text('PiP status: ${snapshot.data}'),
            ),
          ),
          floatingActionButton: StreamBuilder<PiPStatus>(
            stream: floating.pipStatus$,
            initialData: PiPStatus.unavailable,
            builder: (context, snapshot) =>
                snapshot.data != PiPStatus.unavailable
                    ? FloatingActionButton.extended(
                        onPressed: enablePip,
                        label: Text('Enable PiP'),
                        icon: const Icon(Icons.picture_in_picture),
                      )
                    : null,
          ),
        ),
      );
}
