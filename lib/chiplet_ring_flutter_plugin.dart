
import 'chiplet_ring_flutter_plugin_platform_interface.dart';

class ChipletRingFlutterPlugin {
  Future<String?> getPlatformVersion() {
    return ChipletRingFlutterPluginPlatform.instance.getPlatformVersion();
  }
}
