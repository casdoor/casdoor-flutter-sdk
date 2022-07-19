import 'casdoor_flutter_sdk_platform_interface.dart';

/// An implementation of [CasdoorFlutterSdkPlatform] that uses method channels.
class MethodChannelCasdoorFlutterSdk extends CasdoorFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() async {
    final version = await getMethodChannel().invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
