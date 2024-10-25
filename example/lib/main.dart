import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:floating/floating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final floating = Floating();

  Future<void> enablePip(
    BuildContext context, {
    bool autoEnable = false,
  }) async {
    final rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final arguments = autoEnable
        ? OnLeavePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          )
        : ImmediatePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          );

    final status = await floating.enable(arguments);
    debugPrint('PiP enabled? $status');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark(),
        home: PiPSwitcher(
          childWhenDisabled: Scaffold(
            body: Center(child: Image.asset('assets/image.jpg')),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FutureBuilder<bool>(
              future: floating.isPipAvailable,
              initialData: false,
              builder: (context, snapshot) => snapshot.data ?? false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: () => enablePip(context),
                          label: const Text('Enable PiP'),
                          icon: const Icon(Icons.picture_in_picture),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton.extended(
                          onPressed: () => enablePip(context, autoEnable: true),
                          label: const Text('Enable PiP on app minimize'),
                          icon: const Icon(Icons.auto_awesome),
                        ),
                      ],
                    )
                  : const Card(
                      child: Text('PiP unavailable'),
                    ),
            ),
          ),
          childWhenEnabled: Image.asset('assets/image.jpg'),
        ),
      );
}
