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

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeFlutterWebAuth2Platform extends FlutterWebAuth2Platform
    with MockPlatformInterfaceMixin {
  final List<Map<String, dynamic>> calls = [];
  Object? error;

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    calls.add({
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
      'options': options,
    });
    if (error != null) {
      throw error!;
    }
    return 'casdoor://callback?code=code&state=state';
  }

  @override
  Future<void> clearAllDanglingCalls() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFlutterWebAuth2Platform webAuth;
  late CasdoorFlutterSdkMobile mobile;

  setUp(() {
    webAuth = FakeFlutterWebAuth2Platform();
    FlutterWebAuth2Platform.instance = webAuth;
    mobile = CasdoorFlutterSdkMobile();
  });

  CasdoorSdkParams params({bool clearCache = false}) => CasdoorSdkParams(
        url: 'https://door.casdoor.com/login/oauth/authorize',
        callbackUrlScheme: 'casdoor',
        clearCache: clearCache,
      );

  test('authenticate returns the callback URL', () async {
    expect(await mobile.authenticate(params()),
        'casdoor://callback?code=code&state=state');
    expect(webAuth.calls.single['url'],
        'https://door.casdoor.com/login/oauth/authorize');
    expect(webAuth.calls.single['callbackUrlScheme'], 'casdoor');
    expect(webAuth.calls.single['options']['preferEphemeral'], isFalse);
  });

  test('clearCache makes only the next sign-in ephemeral', () async {
    await mobile.clearCache();
    await mobile.authenticate(params());
    await mobile.authenticate(params());
    await mobile.authenticate(params(clearCache: true));
    expect(webAuth.calls.map((c) => c['options']['preferEphemeral']),
        [true, false, true]);
  });

  test('cancelling throws CasdoorAuthCancelledException', () async {
    webAuth.error = PlatformException(code: 'CANCELED');
    expect(mobile.authenticate(params()),
        throwsA(isA<CasdoorAuthCancelledException>()));
  });

  test('other errors are rethrown', () async {
    webAuth.error = PlatformException(code: 'FAILED');
    expect(
        mobile.authenticate(params()),
        throwsA(
            isA<PlatformException>().having((e) => e.code, 'code', 'FAILED')));
  });
}
