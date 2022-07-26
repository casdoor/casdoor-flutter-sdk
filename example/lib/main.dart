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

import 'package:casdoor_flutter_sdk/casdoor.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_config.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_platform_interface.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _token = 'User is not logged in';

  final AuthConfig _config = AuthConfig(
      clientId: "014ae4bd048734ca2dea",
      endpoint: "door.casdoor.com",
      organizationName: "casbin",
      appName: "app-casnode",
      redirectUri: "http://localhost:9000/callback",
      callbackUrlScheme: "casdoor");

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> authenticate() async {
    // Get platform information
    final platform =
        await CasdoorFlutterSdkPlatform.instance.getPlatformVersion() ?? "";
    String callbackUri;
    if (platform == "web") {
      callbackUri = "${_config.redirectUri}.html";
    } else {
      callbackUri = "${_config.callbackUrlScheme}://callback";
    }
    _config.redirectUri = callbackUri;
    final Casdoor _casdoor = Casdoor(config: _config);
    final result = await _casdoor.show();
    // Get code
    final code = Uri.parse(result).queryParameters['code'] ?? "";
    final response = await _casdoor.requestOauthAccessToken(code);
    setState(() {
      _token = jsonDecode(response.body)["access_token"] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Casdoor flutter SDK example'),
          ),
          body: Center(
            child: Text('Running on: $_token\n'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: authenticate,
            tooltip: 'Authenticate',
            child: const Icon(Icons.people),
          )),
    );
  }
}
