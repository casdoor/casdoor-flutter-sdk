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
    this.clearCache = false,
  });

  /// URL of the sign-in page.
  final String url;

  /// URL scheme of the redirect URI that ends the sign-in.
  final String callbackUrlScheme;

  /// Whether to sign in without the cookies of previous sign-ins: an
  /// ephemeral browser session on Android, iOS and macOS, and a cleared web
  /// view cache on Linux and Windows.
  bool clearCache;

  /// Returns a copy of these parameters with the given fields replaced.
  CasdoorSdkParams copyWith({
    String? url,
    String? callbackUrlScheme,
    bool? clearCache,
  }) =>
      CasdoorSdkParams(
        url: url ?? this.url,
        callbackUrlScheme: callbackUrlScheme ?? this.callbackUrlScheme,
        clearCache: clearCache ?? this.clearCache,
      );
}
