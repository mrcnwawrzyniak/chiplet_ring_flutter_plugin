import 'dart:async';

import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _chipletRingStatus = 'Unknown';

  final _chipletRingFlutterPlugin = ChipletRingFlutterPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initialize();
  }

  Future<void> initialize() async {
    try {
      await _chipletRingFlutterPlugin.initialize();
    } on PlatformException {
      print('Failed to initialize chiplet ring.');
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    String chipletRingStatus;
    try {
      platformVersion = await _chipletRingFlutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      chipletRingStatus = await _chipletRingFlutterPlugin.initialize() ??
          'Unknown chiplet ring status';
    } on PlatformException {
      chipletRingStatus = 'Failed to get chiplet ring status.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _chipletRingStatus = chipletRingStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            Center(
              child: Text('ChipletSDK: $_chipletRingStatus\n'),
            ),
          ],
        ),
      ),
    );
  }
}
