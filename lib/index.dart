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
library dart._index;

import 'dart:core';
import 'dart:html';
import 'dart:io';
import 'dart:convert';

abstract class SdkConfig {
  late String serverUrl; // your Casdoor server URL, e.g., "https://door.casbin.com" for the official demo site
  late String clientId; // the Client ID of your Casdoor application, e.g., "014ae4bd048734ca2dea"
  late String appName; // the name of your Casdoor application, e.g., "app-casnode"
  late String organizationName; // the name of the Casdoor organization connected with your Casdoor application, e.g., "casbin"
  String? redirectPath; // the path of the redirect URL for your Casdoor application, will be "/callback" if not provided
}

// reference: https://github.com/casdoor/casdoor-go-sdk/blob/90fcd5646ec63d733472c5e7ce526f3447f99f1f/auth/jwt.go#L19-L32
abstract class Account {
  late String organization;
  late String username;
  late String type;
  late String name;
  late String avatar;
  late String email;
  late String phone;
  late String affiliation;
  late String tag;
  late String language;
  late int score;
  late bool isAdmin;
  late String accessToken;
}

class Sdk {
  late SdkConfig _config;
  Sdk(SdkConfig _config) {
    this._config = _config;
    if (this._config.redirectPath == null) {
      this._config.redirectPath = "/callback";
    }
  }

  String getSignupUrl([bool enablePassword = true]) {
    if (enablePassword) {
      return "${this._config.serverUrl.trim()}/signup/${this._config.appName}";
    } else {
      return this.getSigninUrl().replaceAll("/login/oauth/authorize", "/signup/oauth/authorize");
    }
  }

  String getSigninUrl() {
    String redirectUri = "${window.location.origin}${this._config.redirectPath}";
    String scope = "read";
    String state = this._config.appName;
    return "${this._config.serverUrl.trim()}/login/oauth/authorize?client_id=${this._config.clientId}&response_type=code&redirect_uri=${Uri.encodeComponent(redirectUri)}&scope=${scope}&state=${state}";
  }

  String getUserProfileUrl(String userName, Account account) {
    String param = "";
    if (account != null) {
      param = "?access_token=${account.accessToken}";
    }
    return "${this._config.serverUrl.trim()}/users/${this._config.organizationName}/${userName}${param}";
  }

  String getMyProfileUrl(Account account) {
    String param = "";
    if (account != null) {
      param = "?access_token=${account.accessToken}";
    }
    return "${this._config.serverUrl.trim()}/account${param}";
  }

  Future signin(String serverUrl) async {
    Uri params = Uri.parse("${window.location.search}");
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse("${serverUrl}/api/signin?code=${params.queryParameters["code"]}&state=${params.queryParameters["state"]}"));
    request.write('{ "credentials": "include"}');
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  }
}
