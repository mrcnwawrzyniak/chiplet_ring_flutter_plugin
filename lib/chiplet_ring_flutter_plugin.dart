import 'chiplet_ring_flutter_plugin_platform_interface.dart';

class ChipletRingFlutterPlugin {
  Future<void> initialize() {
    return ChipletRingFlutterPluginPlatform.instance.initialize();
  }

  Future<void> connectToRing(String mac) {
    return ChipletRingFlutterPluginPlatform.instance.connectToRing(mac);
  }

  Future<void> getBatteryLevel() {
    return ChipletRingFlutterPluginPlatform.instance.getBatteryLevel();
  }

  Future<void> getVersion() {
    return ChipletRingFlutterPluginPlatform.instance.getVersion();
  }

  Future<void> syncTime() {
    return ChipletRingFlutterPluginPlatform.instance.syncTime();
  }

  Future<void> startHeartRateMeasurement() {
    return ChipletRingFlutterPluginPlatform.instance
        .startHeartRateMeasurement();
  }

  Future<String?> getPlatformVersion() {
    return ChipletRingFlutterPluginPlatform.instance.getPlatformVersion();
  }

  Stream<Map<String, dynamic>> get eventStream =>
      ChipletRingFlutterPluginPlatform.instance.eventStream;
}
