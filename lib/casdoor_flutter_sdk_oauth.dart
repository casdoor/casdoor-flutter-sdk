
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'casdoor_flutter_sdk_platform_interface.dart';

class _OnAppLifecycleResumeObserver extends WidgetsBindingObserver {
  final Function onResumed;

  _OnAppLifecycleResumeObserver(this.onResumed);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
class CasdoorOauth {
  static final MethodChannel _channel = CasdoorFlutterSdkPlatform.instance.getMethodChannel();

  Future<String?> getPlatformVersion() {
    return CasdoorFlutterSdkPlatform.instance.getPlatformVersion();
  }
  static final _OnAppLifecycleResumeObserver _resumedObserver = _OnAppLifecycleResumeObserver(() {
    _cleanUpDanglingCalls(); // unawaited
  });
  static Future<String> authenticate({required String url, required String callbackUrlScheme, bool? preferEphemeral}) async {
    WidgetsBinding.instance.removeObserver(_resumedObserver); // safety measure so we never add this observer twice
    WidgetsBinding.instance.addObserver(_resumedObserver);
    return await _channel.invokeMethod('authenticate', <String, dynamic>{
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
      'preferEphemeral': preferEphemeral ?? false,
    }) as String;
  }
  /// On Android, the plugin has to store the Result callbacks in order to pass the result back to the caller of
  /// `authenticate`. But if that result never comes the callback will dangle around forever. This can be called to
  /// terminate all `authenticate` calls with an error.
  static Future<void> _cleanUpDanglingCalls() async {
    await _channel.invokeMethod('cleanUpDanglingCalls');
    WidgetsBinding.instance.removeObserver(_resumedObserver);
  }
}
