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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> initialize() {
    throw UnimplementedError(
        'initializeChipletRingSDK() has not been implemented.');
  }
}
