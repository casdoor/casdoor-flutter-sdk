// Copyright 2022 The casbin Authors. All Rights Reserved.
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
import 'dart:html';
import 'dart:js';

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class CasdoorFlutterSdkWeb extends CasdoorFlutterSdkPlatform {
  CasdoorFlutterSdkWeb() : super.create();

  static void registerWith(Registrar registrar) {
    CasdoorFlutterSdkPlatform.instance = CasdoorFlutterSdkWeb();
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) async {
    context.callMethod('open', [params.url]);
    await for (MessageEvent messageEvent in window.onMessage) {
      if (messageEvent.origin == Uri.base.origin) {
        final flutterWebAuthMessage = messageEvent.data['casdoor-auth'];
        if (flutterWebAuthMessage is String) {
          return flutterWebAuthMessage;
        }
      }
      final appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
      if (messageEvent.origin == appleOrigin.toString()) {
        try {
          final Map<String, dynamic> data =
              jsonDecode(messageEvent.data as String) as Map<String, dynamic>;
          if (data['method'] == 'oauthDone') {
            final appleAuth = data['data']['authorization'];
            if (appleAuth != null) {
              final appleAuthQuery =
                  Uri(queryParameters: appleAuth as Map<String, dynamic>?)
                      .query;
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
  Future<String> getPlatformVersion() async {
    return 'web';
  }
}
