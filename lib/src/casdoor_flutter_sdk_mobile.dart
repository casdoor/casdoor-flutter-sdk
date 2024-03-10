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
import 'dart:collection';

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppAuthBrowser extends InAppBrowser {
  InAppAuthBrowser({
    int? windowId,
    UnmodifiableListView<UserScript>? initialUserScripts,
  }) : super(windowId: windowId, initialUserScripts: initialUserScripts);

  Function? onExitCallback;
  Future<NavigationActionPolicy> Function(Uri? url)?
      onShouldOverrideUrlLoadingCallback;

  void setOnExitCallback(Function cb) => (onExitCallback = cb);

  void setOnShouldOverrideUrlLoadingCallback(
          Future<NavigationActionPolicy> Function(Uri? url) cb) =>
      onShouldOverrideUrlLoadingCallback = cb;

  @override
  void onExit() {
    if (onExitCallback != null) {
      onExitCallback!();
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      NavigationAction navigationAction) async {
    if (onShouldOverrideUrlLoadingCallback != null) {
      return onShouldOverrideUrlLoadingCallback!(navigationAction.request.url);
    }

    return NavigationActionPolicy.ALLOW;
  }
}

// -----------------------------------------------------------------------------

class FullScreenAuthPage extends StatefulWidget {
  const FullScreenAuthPage({
    super.key,
    required this.params,
  });

  final CasdoorSdkParams params;

  @override
  State<FullScreenAuthPage> createState() => _FullScreenAuthPageState();
}

class _FullScreenAuthPageState extends State<FullScreenAuthPage> {
  double progress = 0;

  Widget webViewWidget(BuildContext ctx) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.params.url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              userAgent:
                  "Mozilla/5.0 (Android 14; Mobile; rv:123.0) Gecko/123.0 Firefox/123.0",
              clearCache: widget.params.clearCache!,
              useShouldOverrideUrlLoading: true,
              useOnLoadResource: true,
            ),
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final uri = navigationAction.request.url!;

            if (uri.scheme == widget.params.callbackUrlScheme) {
              Navigator.pop(ctx, uri.toString());
              return NavigationActionPolicy.CANCEL;
            }

            return NavigationActionPolicy.ALLOW;
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
        ),
        progress < 1.0
            ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
              )
            : Container(),
      ],
    );
  }

  Widget materialAuthWidget(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        backgroundColor: Colors.grey.shade300,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: webViewWidget(ctx),
    );
  }

  Widget cupertinoAuthWidget(BuildContext ctx) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
        ),
        middle: const Text('Login'),
      ),
      child: webViewWidget(ctx),
    );
  }

  @override
  Widget build(BuildContext context) {
    //WebView.debugLoggingSettings.enabled = false;
    return (widget.params.isMaterialStyle ?? true)
        ? materialAuthWidget(context)
        : cupertinoAuthWidget(context);
  }
}

// -----------------------------------------------------------------------------

class CasdoorFlutterSdkMobile extends CasdoorFlutterSdkPlatform {
  CasdoorFlutterSdkMobile() : super.create();

  bool willClearCache = false;

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    CasdoorFlutterSdkPlatform.instance = CasdoorFlutterSdkMobile();
  }

  @override
  Future<bool> clearCache() async {
    willClearCache = true;
    return true;
  }

  Future<String> _fullScreenAuth(CasdoorSdkParams params) async {
    final result = await Navigator.push(
      params.buildContext!,
      MaterialPageRoute(
        builder: (BuildContext ctx) => FullScreenAuthPage(
          params: params,
        ),
      ),
    );

    if (result is String) {
      return result;
    }

    throw CasdoorAuthCancelledException;
  }

  Future<String> _inAppBrowserAuth(CasdoorSdkParams params) async {
    final Completer<String> isFinished = Completer<String>();
    final InAppAuthBrowser browser = InAppAuthBrowser();

    browser.setOnExitCallback(() {
      if (!isFinished.isCompleted) {
        isFinished.completeError(CasdoorAuthCancelledException);
      }
    });

    browser.setOnShouldOverrideUrlLoadingCallback((returnUrl) async {
      if (returnUrl != null) {
        if (returnUrl.scheme == params.callbackUrlScheme) {
          isFinished.complete(returnUrl.toString());
          browser.close();
          return NavigationActionPolicy.CANCEL;
        }
      }
      return NavigationActionPolicy.ALLOW;
    });

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: Uri.parse(params.url)),
      options: InAppBrowserClassOptions(
        inAppWebViewGroupOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent:
                "Mozilla/5.0 (Android 14; Mobile; rv:123.0) Gecko/123.0 Firefox/123.0",
            clearCache: params.clearCache!,
            useOnLoadResource: true,
            useShouldOverrideUrlLoading: true,
          ),
        ),
        crossPlatform: InAppBrowserOptions(
          hideUrlBar: true,
          toolbarTopBackgroundColor: Colors.grey.shade300,
        ),
        android: AndroidInAppBrowserOptions(
          toolbarTopFixedTitle: 'Login',
        ),
        ios: IOSInAppBrowserOptions(
          hideToolbarBottom: true,
        ),
      ),
    );

    return isFinished.future;
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) async {
    final CasdoorSdkParams newParams =
        params.copyWith(clearCache: willClearCache);

    if (newParams.clearCache == true) {
      willClearCache = false;
    }

    if (([TargetPlatform.android, TargetPlatform.iOS]
            .contains(defaultTargetPlatform)) &&
        (params.showFullscreen == true)) {
      return _fullScreenAuth(newParams);
    }

    return _inAppBrowserAuth(newParams);
  }

  @override
  Future<String> getPlatformVersion() async {
    return 'mobile';
  }
}
