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
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final AuthConfig config = AuthConfig(
    clientId: '014ae4bd048734ca2dea',
    serverUrl: 'https://door.casdoor.com',
    organizationName: 'casbin',
    appName: 'app-casnode',
  );

  test('generateRandomString', () {
    final String s = generateRandomString(43);
    expect(s.length, 43);
    expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(s), isTrue);
    expect(generateRandomString(43), isNot(s));
  });

  test('generateCodeChallenge matches RFC 7636', () {
    expect(
      generateCodeChallenge('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
      'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
    );
  });

  test('getSigninUrl', () {
    final Casdoor casdoor = Casdoor(config: config);
    final Uri uri = casdoor.getSigninUrl();
    expect(uri.host, 'door.casdoor.com');
    expect(uri.path, '/login/oauth/authorize');
    expect(uri.queryParameters['client_id'], config.clientId);
    expect(uri.queryParameters['redirect_uri'], 'casdoor://callback');
    expect(uri.queryParameters['state'], casdoor.state);
    expect(uri.queryParameters['nonce'], casdoor.nonce);
    expect(uri.queryParameters['code_challenge'],
        generateCodeChallenge(casdoor.codeVerifier));
    expect(casdoor.getSigninUrl(state: 'custom').queryParameters['state'],
        'custom');
  });

  test('state is random and checked by isState', () {
    final Casdoor casdoor = Casdoor(config: config);
    expect(casdoor.state, isNot(config.appName));
    expect(casdoor.state, isNot(Casdoor(config: config).state));
    expect(casdoor.isState('casdoor://callback?code=x&state=${casdoor.state}'),
        isTrue);
    expect(casdoor.isState('casdoor://callback?code=x&state=other'), isFalse);
    expect(casdoor.isState('casdoor://callback?code=x'), isFalse);
  });

  test('tokenLogout without postLogoutRedirectUri', () async {
    late http.Request request;
    final MockClient client = MockClient((req) async {
      request = req;
      return http.Response('{"status":"ok"}', 200);
    });
    final http.Response resp = await http.runWithClient(
      () => Casdoor(config: config).tokenLogout('token', null, 'state'),
      () => client,
    );
    expect(resp.statusCode, 200);
    expect(request.url.path, '/api/login/oauth/logout');
    expect(request.bodyFields, {'id_token_hint': 'token', 'state': 'state'});
  });
}
