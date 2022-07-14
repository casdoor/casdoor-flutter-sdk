import 'dart:async';
import 'dart:convert';
import 'dart:html' as html show window;
import 'dart:html';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'casdoor_flutter_sdk_platform_interface.dart';

class CasdoorFlutterSdkWeb extends CasdoorFlutterSdkPlatform  {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'casdoor_flutter_sdk', const StandardMethodCodec(), registrar.messenger);
    final CasdoorFlutterSdkWeb instance = CasdoorFlutterSdkWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
    CasdoorFlutterSdkPlatform.instance = instance;
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'authenticate':
        final String url = call.arguments['url'];
        return _authenticate(url);
      case 'getPlatformVersion':
        return await getPlatformVersion();
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The flutter_web_auth plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  static Future<String> _authenticate(String url) async {
    context.callMethod('open', [url]);
    await for (MessageEvent messageEvent in window.onMessage) {
      if (messageEvent.origin == Uri.base.origin) {
        final flutterWebAuthMessage = messageEvent.data['casdoor-flutter-sdk'];
        if (flutterWebAuthMessage is String) {
          return flutterWebAuthMessage;
        }
      }
      var appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
      if (messageEvent.origin == appleOrigin.toString()) {
        try {
          Map<String, dynamic> data = jsonDecode(messageEvent.data);
          if (data['method'] == 'oauthDone') {
            final appleAuth = data['data']['authorization'];
            if (appleAuth != null) {
              final appleAuthQuery = Uri(queryParameters: appleAuth).query;
              return appleOrigin.replace(fragment: appleAuthQuery).toString();
            }
          }
        } on FormatException {}
      }
    }
    throw PlatformException(
        code: 'error', message: 'Iterable window.onMessage is empty');
  }

  @override
  Future<String?> getPlatformVersion() async {
    return "web";
  }
}
