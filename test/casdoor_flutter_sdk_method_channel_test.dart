import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_method_channel.dart';

void main() {
  MethodChannelCasdoorFlutterSdk platform = MethodChannelCasdoorFlutterSdk();
  const MethodChannel channel = MethodChannel('casdoor_flutter_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
