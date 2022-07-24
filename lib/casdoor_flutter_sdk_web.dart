// Copyright 2021 The casbin Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
        final flutterWebAuthMessage = messageEvent.data['casdoor-auth'];
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
