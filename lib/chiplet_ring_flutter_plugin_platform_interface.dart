import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chiplet_ring_flutter_plugin_method_channel.dart';

abstract class ChipletRingFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a ChipletRingFlutterPluginPlatform.
  ChipletRingFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChipletRingFlutterPluginPlatform _instance =
      MethodChannelChipletRingFlutterPlugin();

  /// The default instance of [ChipletRingFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelChipletRingFlutterPlugin].
  static ChipletRingFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChipletRingFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(ChipletRingFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the Chiplet Ring SDK.
  Future<void> initialize();

  /// Connects to the ring using the provided MAC address.
  Future<void> connectToRing(String mac);

  /// Retrieves the battery level of the ring.
  Future<void> getBatteryLevel();

  /// Retrieves the version of the SDK or device.
  Future<void> getVersion();

  /// Synchronizes the time with the ring.
  Future<void> syncTime();

  /// Starts the heart rate measurement.
  Future<void> startHeartRateMeasurement();

  /// Retrieves the platform version.
  Future<String?> getPlatformVersion();

  /// Stream of events from the native side.
  Stream<Map<String, dynamic>> get eventStream;
}
