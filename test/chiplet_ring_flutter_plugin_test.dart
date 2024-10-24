import 'package:flutter_test/flutter_test.dart';
import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin.dart';
import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin_platform_interface.dart';
import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChipletRingFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements ChipletRingFlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChipletRingFlutterPluginPlatform initialPlatform = ChipletRingFlutterPluginPlatform.instance;

  test('$MethodChannelChipletRingFlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChipletRingFlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    ChipletRingFlutterPlugin chipletRingFlutterPlugin = ChipletRingFlutterPlugin();
    MockChipletRingFlutterPluginPlatform fakePlatform = MockChipletRingFlutterPluginPlatform();
    ChipletRingFlutterPluginPlatform.instance = fakePlatform;

    expect(await chipletRingFlutterPlugin.getPlatformVersion(), '42');
  });
}
