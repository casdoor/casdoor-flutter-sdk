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
import 'dart:io';

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CasdoorFlutterSdkDesktop extends CasdoorFlutterSdkPlatform {
  CasdoorFlutterSdkDesktop() : super.create();
  bool isWindowOpen = false;

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    CasdoorFlutterSdkPlatform.instance = CasdoorFlutterSdkDesktop();
  }

  Future<String> _getCacheDirWebPath() async {
    final Directory cacheDirRoot = await getApplicationCacheDirectory();
    return p.join(
      cacheDirRoot.path,
      'web_cache',
    );
  }

  @override
  Future<bool> clearCache() async {
    if (isWindowOpen == true) {
      return false;
    }

    final String cacheDirWebPath = await _getCacheDirWebPath();
    final Directory cacheDirWeb = Directory(cacheDirWebPath);
    if (cacheDirWeb.existsSync()) {
      await cacheDirWeb.delete(recursive: true);
    }
    await cacheDirWeb.create();
    return true;
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) async {
    final bool isWebviewAvailable = await WebviewWindow.isWebviewAvailable();

    if (isWindowOpen == true) {
      throw CasdoorDesktopWebViewAlreadyOpenException;
    }

    if (isWebviewAvailable == true) {
      final Completer<String> isWindowClosed = Completer<String>();

      String? returnUrl;
      final String cacheDirWebPath = await _getCacheDirWebPath();

      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowWidth: 400,
          windowHeight: 640,
          title: 'Login',
          titleBarTopPadding: Platform.isMacOS ? 30 : 0,
          titleBarHeight: 0,
          userDataFolderWindows: cacheDirWebPath,
        ),
      );
      webview
        ..launch(params.url)
        ..addOnUrlRequestCallback((requestUrl) {
          final uri = Uri.parse(requestUrl);
          if (uri.scheme == params.callbackUrlScheme) {
            returnUrl = requestUrl;
            webview.close();
            isWindowClosed.complete(returnUrl);
          }
        })
        ..onClose.whenComplete(() {
          if (returnUrl != null) {
            if (isWindowClosed.isCompleted == false) {
              isWindowClosed.complete(returnUrl);
            }
          } else {
            isWindowClosed.completeError(CasdoorAuthCancelledException);
          }

          isWindowOpen = false;
        });

      isWindowOpen = true;

      return isWindowClosed.future;
    } else {
      throw CasdoorDesktopWebViewNotAvailableException;
    }
  }

  @override
  Future<String> getPlatformVersion() async {
    return 'desktop';
  }
}
