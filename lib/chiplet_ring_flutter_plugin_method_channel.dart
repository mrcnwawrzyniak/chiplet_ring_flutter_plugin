import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chiplet_ring_flutter_plugin_platform_interface.dart';

class MethodChannelChipletRingFlutterPlugin
    extends ChipletRingFlutterPluginPlatform {
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('chiplet_ring_flutter_plugin');

  @visibleForTesting
  final EventChannel eventChannel =
      const EventChannel('chiplet_ring_event_channel');

  @override
  Future<void> initialize() async {
    try {
      await methodChannel.invokeMethod('initializeSdk');
    } on PlatformException catch (e) {
      throw 'Failed to initialize chiplet ring: ${e.message}';
    }
  }

  @override
  Future<void> startScan() async {
    try {
      await methodChannel.invokeMethod('startScan',);
    } on PlatformException catch (e) {
      throw 'Failed to scan: ${e.message}';
    }
  }
  
  @override
  Future<void> connectToRing(String mac) async {
    try {
      await methodChannel.invokeMethod('connectToRing', {'mac': mac});
    } on PlatformException catch (e) {
      throw 'Failed to scan: ${e.message}';
    }
  }

  @override
  Future<void> getBatteryLevel() async {
    try {
      await methodChannel.invokeMethod('getBatteryLevel');
    } on PlatformException catch (e) {
      throw 'Failed to get battery level: ${e.message}';
    }
  }

  @override
  Future<void> getVersion() async {
    try {
      await methodChannel.invokeMethod('getVersion');
    } on PlatformException catch (e) {
      throw 'Failed to get version: ${e.message}';
    }
  }

  @override
  Future<void> syncTime() async {
    try {
      await methodChannel.invokeMethod('syncTime');
    } on PlatformException catch (e) {
      throw 'Failed to sync time: ${e.message}';
    }
  }

  @override
  Future<void> startHeartRateMeasurement() async {
    try {
      await methodChannel.invokeMethod('startHeartRateMeasurement');
    } on PlatformException catch (e) {
      throw 'Failed to start heart rate measurement: ${e.message}';
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final String? version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream<Map<String, dynamic>> get eventStream {
    return eventChannel.receiveBroadcastStream().map((event) {
      // Zakładamy, że event jest Map<String, dynamic>
      return Map<String, dynamic>.from(event);
    });
  }
}
