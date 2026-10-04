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

/// Client for signing in to a Casdoor server with the OAuth 2.0 authorization
/// code flow and PKCE.
///
/// Each instance generates its own PKCE code verifier, OIDC nonce and OAuth
/// state, so use the same instance for [show] and for
/// [requestOauthAccessToken].
class Casdoor {
  /// Configuration of the Casdoor application to sign in to.
  final AuthConfig config;

  /// PKCE code verifier sent with [requestOauthAccessToken].
  late final String codeVerifier;

  /// OIDC nonce sent in the authorization request, see [isNonce].
  late final String nonce;

  /// Default OAuth state sent in the authorization request, see [isState].
  late final String state;

  /// Creates a client for the Casdoor application described by [config].
  Casdoor({required this.config}) {
    codeVerifier = generateRandomString(43);
    nonce = generateRandomString(32);
    state = generateRandomString(32);
  }

  /// Returns the scheme of [AuthConfig.serverUrl], `https` if it has none.
  String parseScheme() {
    String scheme = 'https';
    final uri = Uri.parse(config.serverUrl);
    if (uri.hasScheme) {
      scheme = uri.scheme;
    }
    return scheme;
  }

  /// Returns the host of [AuthConfig.serverUrl].
  String parseHost() {
    final uri = Uri.parse(config.serverUrl);
    return uri.host;
  }

  /// Returns the port of [AuthConfig.serverUrl].
  int parsePort() {
    final uri = Uri.parse(config.serverUrl);
    return uri.port;
  }

  /// Returns the URL of the Casdoor sign-in page.
  ///
  /// If [state] is omitted, the random [Casdoor.state] of this instance is
  /// used.
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
          'state': state ?? this.state,
          'code_challenge_method': 'S256',
          'nonce': nonce,
          'code_challenge': generateCodeChallenge(codeVerifier),
          'redirect_uri': config.redirectUri
        });
  }

  /// Returns the URL of the Casdoor sign-up page.
  ///
  /// If [state] is omitted, the random [Casdoor.state] of this instance is
  /// used.
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
          'state': state ?? this.state,
          'code_challenge_method': 'S256',
          'nonce': nonce,
          'code_challenge': generateCodeChallenge(codeVerifier),
          'redirect_uri': config.redirectUri
        });
  }

  /// Opens the sign-in page and returns the callback URL that contains the
  /// authorization `code` and `state`.
  ///
  /// The page is shown in the system browser on Android, iOS and macOS, in a
  /// web view window on Linux and Windows, and in a popup window on the Web.
  ///
  /// Throws [CasdoorAuthCancelledException] if the user closes the page.
  Future<String> show({
    String scope = 'read',
    String? state,
  }) async {
    return CasdoorOauth.authenticate(CasdoorSdkParams(
      url: getSigninUrl(scope: scope, state: state).toString(),
      callbackUrlScheme: config.callbackUrlScheme,
    ));
  }

  /// Same as [show]. [buildContext] and [isMaterialStyle] are ignored.
  @Deprecated('The sign-in page is shown in the system browser since 2.0.0, '
      'use show() instead')
  Future<String> showFullscreen(
    BuildContext buildContext, {
    bool? isMaterialStyle,
    String scope = 'read',
    String? state,
  }) {
    return show(scope: scope, state: state);
  }

  /// Exchanges the authorization [code] for an access token, an ID token and
  /// a refresh token.
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

  /// Gets a new access token with [refreshToken].
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

  /// Signs the user out of Casdoor.
  ///
  /// If [clearCache] is true, the cookies and cache of the sign-in web view are
  /// also cleared, so the next sign-in asks for the credentials again.
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
          if (postLogoutRedirectUri != null)
            'post_logout_redirect_uri': postLogoutRedirectUri,
          'state': state
        });
    if (clearCache == true) {
      await CasdoorOauth.clearCache();
    }
    return resp;
  }

  /// Gets the claims of the user that [accessToken] was issued to.
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

  /// Decodes the payload of the JWT [token] without verifying its signature.
  Map<String, dynamic> decodedToken(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken;
  }

  /// Returns whether the JWT [token] has expired.
  bool isTokenExpired(String token) {
    final bool isTokenExpired = JwtDecoder.isExpired(token);
    return isTokenExpired;
  }

  /// Returns whether the ID [token] contains the [nonce] of this instance.
  bool isNonce(String token) {
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final bool isNonce = (decodedToken['nonce'] == nonce);
    return isNonce;
  }

  /// Returns whether the `state` query parameter of [callbackUrl], as returned
  /// by [show], matches the [state] of this instance.
  ///
  /// Check it before calling [requestOauthAccessToken] to prevent CSRF.
  bool isState(String callbackUrl) {
    final Uri uri = Uri.parse(callbackUrl);
    return uri.queryParameters['state'] == state;
  }
}

/// Returns a random alphanumeric string of [length] characters generated with
/// a cryptographically secure random number generator.
String generateRandomString(int length) {
  final random = Random.secure();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
      (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

/// Returns the PKCE S256 code challenge of [verifier].
String generateCodeChallenge(String verifier) {
  final bytes = utf8.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
