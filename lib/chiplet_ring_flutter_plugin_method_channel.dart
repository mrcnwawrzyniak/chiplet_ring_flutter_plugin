import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chiplet_ring_flutter_plugin_platform_interface.dart';

/// An implementation of [ChipletRingFlutterPluginPlatform] that uses method channels.
class MethodChannelChipletRingFlutterPlugin extends ChipletRingFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('chiplet_ring_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
