import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'casdoor_flutter_sdk_method_channel.dart';

abstract class CasdoorFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a CasdoorFlutterSdkPlatform.
  CasdoorFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static CasdoorFlutterSdkPlatform _instance = MethodChannelCasdoorFlutterSdk();

  /// The default instance of [CasdoorFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelCasdoorFlutterSdk].
  static CasdoorFlutterSdkPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CasdoorFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(CasdoorFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  MethodChannel getMethodChannel() {
    return const MethodChannel('casdoor_flutter_sdk');
  }
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
