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

import 'dart:convert';
import 'dart:math';

import 'package:casdoor_flutter_sdk/src/casdoor_flutter_sdk_config.dart';
import 'package:casdoor_flutter_sdk/src/casdoor_flutter_sdk_oauth.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class Casdoor {
  final AuthConfig config;
  late final String codeVerifier;
  late final String nonce;

  Casdoor({required this.config}) {
    codeVerifier = generateRandomString(43);
    nonce = generateRandomString(12);
  }

  String parseScheme() {
    String scheme = 'https';
    final uri = Uri.parse(config.serverUrl);
    if (uri.hasScheme) {
      scheme = uri.scheme;
    }
    return scheme;
  }

  String parseHost() {
    final uri = Uri.parse(config.serverUrl);
    return uri.host;
  }

  int parsePort() {
    final uri = Uri.parse(config.serverUrl);
    return uri.port;
  }

  Uri getSigninUrl({String scope = 'read', String? state}) {
    return Uri(
        scheme: parseScheme(),
        host: parseHost(),
        port: parsePort(),
        path: 'login/oauth/authorize',
        queryParameters: {
          'client_id': config.clientId,
          'response_type': 'code',
          'scope': scope,
          'state': state ?? config.appName,
          'code_challenge_method': 'S256',
          'nonce': nonce,
          'code_challenge': generateCodeChallenge(codeVerifier),
          'redirect_uri': config.redirectUri
        });
  }

  Uri getSignupUrl({String scope = 'read', String? state}) {
    return Uri(
        scheme: parseScheme(),
        host: parseHost(),
        port: parsePort(),
        path: '/signup/oauth/authorize',
        queryParameters: {
          'client_id': config.clientId,
          'response_type': 'code',
          'scope': scope,
          'state': state ?? config.appName,
          'code_challenge_method': 'S256',
          'nonce': nonce,
          'code_challenge': generateCodeChallenge(codeVerifier),
          'redirect_uri': config.redirectUri
        });
  }

  Future<String> show({
    String scope = 'read',
    String? state,
  }) async {
    return CasdoorOauth.authenticate(CasdoorSdkParams(
      url: getSigninUrl(scope: scope, state: state).toString(),
      callbackUrlScheme: config.callbackUrlScheme,
    ));
  }

  Future<String> showFullscreen(
    BuildContext buildContext, {
    bool? isMaterialStyle,
    String scope = 'read',
    String? state,
  }) {
    return CasdoorOauth.authenticate(CasdoorSdkParams(
      url: getSigninUrl(scope: scope, state: state).toString(),
      callbackUrlScheme: config.callbackUrlScheme,
      buildContext: buildContext,
      showFullscreen: true,
      isMaterialStyle: isMaterialStyle ?? true,
    ));
  }

  Future<http.Response> requestOauthAccessToken(String code) async {
    return await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          port: parsePort(),
          path: 'api/login/oauth/access_token',
        ),
        body: {
          'client_id': config.clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': codeVerifier
        });
  }

  Future<http.Response> refreshToken(String refreshToken, String? clientSecret,
      {String scope = 'read'}) async {
    final body = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'scope': scope,
      'client_id': config.clientId,
    };
    if (clientSecret != null) {
      body['client_secret'] = clientSecret;
    }
    return await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          port: parsePort(),
          path: 'api/login/oauth/refresh_token',
        ),
        body: body);
  }

  Future<http.Response> tokenLogout(
    String idTokenHint,
    String? postLogoutRedirectUri,
    String state, {
    bool clearCache = false,
  }) async {
    final http.Response resp = await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          port: parsePort(),
          path: 'api/login/oauth/logout',
        ),
        body: {
          'id_token_hint': idTokenHint,
          'post_logout_redirect_uri': postLogoutRedirectUri,
          'state': state
        });
    if (clearCache == true) {
      await CasdoorOauth.clearCache();
    }
    return resp;
  }

  Future<http.Response> getUserInfo(String accessToken) async {
    return await http.get(
      Uri(
        scheme: parseScheme(),
        host: parseHost(),
        port: parsePort(),
        path: 'api/userinfo',
      ),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Map<String, dynamic> decodedToken(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  }

  bool isTokenExpired(String token) {
    final bool isTokenExpired = JwtDecoder.isExpired(token);
    return isTokenExpired;
  }

  bool isNonce(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final bool isNonce = (decodedToken['nonce'] == nonce);
    return isNonce;
  }
}

String generateRandomString(int length) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
      (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

String generateCodeChallenge(String verifier) {
  final bytes = utf8.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
