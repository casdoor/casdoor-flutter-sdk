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

import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk.dart';
import 'package:casdoor_flutter_sdk/src/casdoor_flutter_sdk.dart';
import 'package:casdoor_flutter_sdk/src/casdoor_flutter_sdk_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCasdoorFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements CasdoorFlutterSdkPlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> clearCache() {
    // TODO: implement clearCache
    throw UnimplementedError();
  }

  @override
  Future<String> authenticate(CasdoorSdkParams params) {
    // TODO: implement authenticate
    throw UnimplementedError();
  }
}

void main() {
  final CasdoorFlutterSdkPlatform initialPlatform = CasdoorFlutterSdkPlatform();

  test('$MethodChannelCasdoorFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCasdoorFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    final CasdoorFlutterSdk casdoorFlutterSdkPlugin = CasdoorFlutterSdk();
    final MockCasdoorFlutterSdkPlatform fakePlatform =
        MockCasdoorFlutterSdkPlatform();
    CasdoorFlutterSdkPlatform.instance = fakePlatform;

    expect(await casdoorFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
