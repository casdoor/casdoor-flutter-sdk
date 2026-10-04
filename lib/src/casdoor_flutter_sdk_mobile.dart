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

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Implementation for Android, iOS and macOS that signs in in the system
/// browser with flutter_web_auth_2: Custom Tabs on Android and
/// `ASWebAuthenticationSession` on iOS and macOS.
class CasdoorFlutterSdkMobile extends CasdoorFlutterSdkPlatform {
  /// Constructs the mobile implementation.
  CasdoorFlutterSdkMobile() : super.create();

  /// Whether the next sign-in uses an ephemeral browser session.
  bool willClearCache = false;

  /// Registers this class as the default instance of [CasdoorFlutterSdkPlatform]
  static void registerWith() {
    CasdoorFlutterSdkPlatform.instance = CasdoorFlutterSdkMobile();
  }

  /// The cookies of the system browser cannot be cleared by the app, so the
  /// next sign-in uses an ephemeral browser session that does not share them.
  @override
  Future<bool> clearCache() async {
    willClearCache = true;
    return true;
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) async {
    final bool preferEphemeral = params.clearCache || willClearCache;
    willClearCache = false;

    try {
      return await FlutterWebAuth2.authenticate(
        url: params.url,
        callbackUrlScheme: params.callbackUrlScheme,
        options: FlutterWebAuth2Options(preferEphemeral: preferEphemeral),
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        throw CasdoorAuthCancelledException();
      }
      rethrow;
    }
  }

  @override
  Future<String> getPlatformVersion() async {
    return 'mobile';
  }
}
