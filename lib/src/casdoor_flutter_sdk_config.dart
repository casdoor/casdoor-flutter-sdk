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

import 'package:flutter/widgets.dart';

/// User agent of the sign-in web view on Android and iOS.
// ignore: constant_identifier_names
const CASDOOR_USER_AGENT =
    'Mozilla/5.0 (Android 14; Mobile; rv:123.0) Gecko/123.0 Firefox/123.0';

/// Configuration of a Casdoor application.
class AuthConfig {
  /// Client ID of the Casdoor application.
  final String clientId;

  /// URL of the Casdoor server, such as `https://door.casdoor.com`.
  final String serverUrl;

  /// Name of the organization that the application belongs to.
  final String organizationName;

  /// Redirect URI registered in the Casdoor application, such as
  /// `casdoor://callback` on native platforms or
  /// `http://localhost:9000/callback.html` on the Web.
  String redirectUri;

  /// URL scheme of [redirectUri] that ends the sign-in on native platforms.
  final String callbackUrlScheme;

  /// Name of the Casdoor application.
  final String appName;

  /// Creates the configuration of a Casdoor application.
  AuthConfig({
    required this.clientId,
    required this.serverUrl,
    required this.organizationName,
    required this.appName,
    this.redirectUri = 'casdoor://callback',
    this.callbackUrlScheme = 'casdoor',
  });
}

/// Parameters of a sign-in passed to the platform implementation.
class CasdoorSdkParams {
  /// Creates the parameters of a sign-in.
  CasdoorSdkParams({
    required this.url,
    required this.callbackUrlScheme,
    this.buildContext,
    this.showFullscreen = false,
    this.isMaterialStyle = true,
    this.clearCache = false,
  });

  /// URL of the sign-in page.
  final String url;

  /// URL scheme of the redirect URI that ends the sign-in.
  final String callbackUrlScheme;

  /// Context whose navigator shows the full screen sign-in page.
  BuildContext? buildContext;

  /// Whether to show the sign-in page in a full screen page instead of a new
  /// window. Supported on Android and iOS.
  bool showFullscreen;

  /// Whether the full screen sign-in page uses Material instead of Cupertino
  /// widgets.
  bool isMaterialStyle;

  /// Whether to clear the cookies and cache of the web view before signing in.
  bool clearCache;

  /// Returns a copy of these parameters with the given fields replaced.
  CasdoorSdkParams copyWith({
    String? url,
    String? callbackUrlScheme,
    BuildContext? buildContext,
    bool? showFullscreen,
    bool? isMaterialStyle,
    bool? clearCache,
  }) =>
      CasdoorSdkParams(
        url: url ?? this.url,
        callbackUrlScheme: callbackUrlScheme ?? this.callbackUrlScheme,
        buildContext: buildContext ?? this.buildContext,
        showFullscreen: showFullscreen ?? this.showFullscreen,
        isMaterialStyle: isMaterialStyle ?? this.isMaterialStyle,
        clearCache: clearCache ?? this.clearCache,
      );
}
