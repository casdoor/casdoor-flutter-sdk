import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_platform_interface.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCasdoorFlutterSdkPlatform 
    with MockPlatformInterfaceMixin
    implements CasdoorFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  MethodChannel getMethodChannel() {
    // TODO: implement getMethodChannel
    throw UnimplementedError();
  }
}

void main() {
  final CasdoorFlutterSdkPlatform initialPlatform = CasdoorFlutterSdkPlatform.instance;

  test('$MethodChannelCasdoorFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCasdoorFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    MethodChannelCasdoorFlutterSdk casdoorFlutterSdkPlugin = MethodChannelCasdoorFlutterSdk();
    MockCasdoorFlutterSdkPlatform fakePlatform = MockCasdoorFlutterSdkPlatform();
    CasdoorFlutterSdkPlatform.instance = fakePlatform;
  
    expect(await casdoorFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
