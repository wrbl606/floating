import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:floating/floating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isPipEnabled, isPipSupported;

  @override
  void initState() {
    super.initState();
    checkPipSupport();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkPipSupport() async {
    final isPipSupported = await Floating.isPipAvailable;
    final isPipEnabled = await Floating.isInPipMode;
    setState(() {
      this.isPipSupported = isPipSupported;
      this.isPipEnabled = isPipEnabled;
    });
  }

  Future<void> enablePip() async {
    final enabledSuccessfully = await Floating.enablePip();
    print('PiP enabled? $enabledSuccessfully');
    await checkPipSupport();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Floating example app'),
        ),
        body: Center(
          child: Text('PiP available: $isPipSupported\nPiP enabled: $isPipEnabled'),
        ),
        floatingActionButton: isPipSupported ?? false ? FloatingActionButton.extended(onPressed: enablePip, label: Text('Enable PiP'), icon: const Icon(Icons.picture_in_picture),) : null,
      ),
    );
  }
}
