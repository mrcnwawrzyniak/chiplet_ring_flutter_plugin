import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chiplet_ring_flutter_plugin_platform_interface.dart';

class MethodChannelChipletRingFlutterPlugin
    extends ChipletRingFlutterPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('chiplet_ring_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> initialize() async {
    try {
      return await methodChannel.invokeMethod<String>('initialize');
    } on PlatformException catch (e) {
      return 'Failed to initialize chiplet ring: ${e.message}';
    }
  }
}
