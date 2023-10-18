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

class AuthConfig {
  final String clientId;
  final String serverUrl;
  final String organizationName;
  String redirectUri;
  final String callbackUrlScheme;
  final String appName;

  AuthConfig({
    required this.clientId,
    required this.serverUrl,
    required this.organizationName,
    required this.appName,
    this.redirectUri = 'casdoor://callback',
    this.callbackUrlScheme = 'casdoor',
  });
}

class CasdoorSdkParams {
  CasdoorSdkParams({
    required this.url,
    required this.callbackUrlScheme,
    this.buildContext,
    this.showFullscreen,
    this.isMaterialStyle,
    this.preferEphemeral,
    this.clearCache,
  });

  final String url;
  final String callbackUrlScheme;
  BuildContext? buildContext;
  bool? showFullscreen;
  bool? isMaterialStyle;
  bool? preferEphemeral;
  bool? clearCache;

  CasdoorSdkParams copyWith({
    String? url,
    String? callbackUrlScheme,
    BuildContext? buildContext,
    bool? showFullscreen,
    bool? isMaterialStyle,
    bool? preferEphemeral,
    bool? clearCache,
  }) =>
      CasdoorSdkParams(
        url: url ?? this.url,
        callbackUrlScheme: callbackUrlScheme ?? this.callbackUrlScheme,
        buildContext: buildContext ?? this.buildContext,
        showFullscreen: showFullscreen ?? this.showFullscreen,
        isMaterialStyle: isMaterialStyle ?? this.isMaterialStyle,
        preferEphemeral: preferEphemeral ?? this.preferEphemeral,
        clearCache: clearCache ?? this.clearCache,
      );
}
