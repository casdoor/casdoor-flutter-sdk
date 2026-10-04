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
import 'dart:js_interop';

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Key of the redirect URL in the message or the local storage item that the
/// callback page sends to the app.
const String _authKey = 'casdoor-auth';

/// Implementation for the Web that signs in in a popup window.
///
/// The callback page of the app sends the redirect URL back with
/// `window.opener.postMessage({'casdoor-auth': url})`, or by setting the
/// `casdoor-auth` local storage item when the popup has no opener.
class CasdoorFlutterSdkWeb extends CasdoorFlutterSdkPlatform {
  /// Constructs the web implementation.
  CasdoorFlutterSdkWeb() : super.create();

  /// Registers this class as the default instance of [CasdoorFlutterSdkPlatform]
  static void registerWith(Registrar registrar) {
    CasdoorFlutterSdkPlatform.instance = CasdoorFlutterSdkWeb();
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) async {
    final Completer<String> result = Completer<String>();
    void complete(String url) {
      if (!result.isCompleted) {
        result.complete(url);
      }
    }

    final StreamSubscription<web.MessageEvent> messages =
        web.window.onMessage.listen((event) {
      final String? url = _parseMessage(event);
      if (url != null) {
        complete(url);
      }
    });
    final StreamSubscription<web.StorageEvent> storage = web
        .EventStreamProviders.storageEvent
        .forTarget(web.window)
        .listen((event) {
      final String? url = event.newValue;
      if (event.key == _authKey && url != null) {
        web.window.localStorage.removeItem(_authKey);
        complete(url);
      }
    });

    web.window.open(params.url, '_blank');
    try {
      return await result.future;
    } finally {
      await messages.cancel();
      await storage.cancel();
    }
  }

  /// Returns the redirect URL in [event], or null if [event] is not a
  /// message from the callback page or from Sign in with Apple.
  static String? _parseMessage(web.MessageEvent event) {
    final String origin = event.origin;
    final Object? data = event.data.dartify();

    if (origin == Uri.base.origin) {
      if (data is Map && data[_authKey] is String) {
        return data[_authKey] as String;
      }
      return null;
    }

    final Uri appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
    if (origin == appleOrigin.toString() && data is String) {
      try {
        final Object? message = jsonDecode(data);
        if (message is Map && message['method'] == 'oauthDone') {
          final Object? appleAuth = (message['data'] as Map?)?['authorization'];
          if (appleAuth is Map) {
            final String query = Uri(
              queryParameters:
                  appleAuth.map((key, value) => MapEntry('$key', '$value')),
            ).query;
            return appleOrigin.replace(fragment: query).toString();
          }
        }
      } on FormatException {
        // Ignore messages from Apple that are not JSON.
      }
    }
    return null;
  }

  @override
  Future<String> getPlatformVersion() async {
    return 'web';
  }
}
