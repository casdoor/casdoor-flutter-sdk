// Copyright 2026 The casbin Authors. All Rights Reserved.
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

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  // On Linux and Windows the sign-in window runs in a separate engine.
  if (!kIsWeb && runWebViewTitleBarWidget(args)) {
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthConfig _config = AuthConfig(
    clientId: '014ae4bd048734ca2dea',
    serverUrl: 'https://door.casdoor.com',
    organizationName: 'casbin',
    appName: 'app-casnode',
    // On the Web, this must point to web/callback.html of this app.
    redirectUri:
        kIsWeb ? 'http://localhost:9000/callback.html' : 'casdoor://callback',
    callbackUrlScheme: 'casdoor',
  );

  String _accessToken = '';
  String _idToken = '';
  String _message = '';
  bool _busy = false;

  Future<void> _login() async {
    setState(() => _busy = true);
    // Use the same instance for signing in and requesting the token, it holds
    // the PKCE code verifier, nonce and state.
    final Casdoor casdoor = Casdoor(config: _config);
    try {
      final String callbackUrl =
          await casdoor.show(scope: 'openid profile email');
      if (!casdoor.isState(callbackUrl)) {
        throw Exception('state mismatch');
      }
      final String code = Uri.parse(callbackUrl).queryParameters['code'] ?? '';
      final response = await casdoor.requestOauthAccessToken(code);
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (body['access_token'] == null) {
        throw Exception(body['error_description'] ?? response.body);
      }
      setState(() {
        _accessToken = body['access_token'] as String? ?? '';
        _idToken = body['id_token'] as String? ?? '';
        _message = '';
      });
    } on CasdoorAuthCancelledException {
      setState(() => _message = 'Sign-in cancelled');
    } catch (e) {
      setState(() => _message = 'Sign-in failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    await Casdoor(config: _config)
        .tokenLogout(_idToken, null, 'logout', clearCache: true);
    setState(() {
      _accessToken = '';
      _idToken = '';
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> claims = _accessToken.isEmpty
        ? {}
        : Casdoor(config: _config).decodedToken(_accessToken);

    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Casdoor Flutter Example')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_accessToken.isEmpty
                    ? 'Not signed in'
                    : 'Signed in as ${claims['name']}'),
                if (_message.isNotEmpty) Text(_message),
                const SizedBox(height: 20),
                if (_accessToken.isEmpty)
                  ElevatedButton(
                    onPressed: _busy ? null : _login,
                    child: const Text('Sign in'),
                  )
                else
                  ElevatedButton(
                    onPressed: _busy ? null : _logout,
                    child: const Text('Sign out'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
