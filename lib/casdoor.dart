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
import 'package:http/http.dart' as http;
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_config.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_oauth.dart';
import 'package:crypto/crypto.dart';
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
    String scheme = "https";
    var uri = Uri.parse(config.serverUrl);
    if (uri.hasScheme) {
      scheme = uri.scheme;
    }
    return scheme;
  }

  String parseHost() {
    var uri = Uri.parse(config.serverUrl);
    return uri.host;
  }

  Uri getSigninUrl({String scope = "read", String? state}) {
    return Uri(
        scheme: parseScheme(),
        host: parseHost(),
        path: "login/oauth/authorize",
        queryParameters: {
          "client_id": config.clientId,
          "response_type": "code",
          "scope": scope,
          "state": state ?? config.appName,
          "code_challenge_method": "S256",
          "nonce": nonce,
          "code_challenge": generateCodeChallenge(codeVerifier),
          "redirect_uri": config.redirectUri
        });
  }

  Uri getSignupUrl({String scope = "read", String? state}) {
    return Uri(
        scheme: parseScheme(),
        host: parseHost(),
        path: "/signup/oauth/authorize",
        queryParameters: {
          "client_id": config.clientId,
          "response_type": "code",
          "scope": scope,
          "state": state ?? config.appName,
          "code_challenge_method": "S256",
          "nonce": nonce,
          "code_challenge": generateCodeChallenge(codeVerifier),
          "redirect_uri": config.redirectUri
        });
  }

  Future<String> show({String scope = "read", String? state}) async {
    return CasdoorOauth.authenticate(
        url: getSigninUrl(scope: scope, state: state).toString(),
        callbackUrlScheme: config.callbackUrlScheme);
  }

  Future<http.Response> requestOauthAccessToken(String code) async {
    return await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          path: "api/login/oauth/access_token",
        ),
        body: {
          'client_id': config.clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': codeVerifier
        });
  }

  Future<http.Response> refreshToken(String refreshToken, String? clientSecret,
      {String scope = "read"}) async {
    return await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          path: "api/login/oauth/refresh_token",
        ),
        body: {
          'grant_type': 'authorization_code',
          'refresh_token': refreshToken,
          'scope': scope,
          'client_id': config.clientId,
          'client_secret': clientSecret
        });
  }

  Future<http.Response> tokenLogout(
      String idTokenHint, String? postLogoutRedirectUri, String state) async {
    return await http.post(
        Uri(
          scheme: parseScheme(),
          host: parseHost(),
          path: "api/login/oauth/logout",
        ),
        body: {
          'id_token_hint ': idTokenHint,
          'post_logout_redirect_uri': postLogoutRedirectUri,
          'state ': state
        });
  }

  Future<http.Response> getUserInfo(String accessToken) async {
    return await http.post(
      Uri(
        scheme: parseScheme(),
        host: parseHost(),
        path: "api/userinfo",
      ),
      headers: {"Authorization": "Bearer $accessToken"},
    );
  }

  Map<String, dynamic> decodedToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  }

  bool isTokenExpired(String token) {
    bool isTokenExpired = JwtDecoder.isExpired(token);
    return isTokenExpired;
  }

  bool isNonce(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    bool isNonce = decodedToken["nonce"] == nonce ? true : false;
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
  var bytes = utf8.encode(verifier);
  var digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll("=", "");
}
