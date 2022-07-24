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

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'casdoor_flutter_sdk_method_channel.dart';

abstract class CasdoorFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a CasdoorFlutterSdkPlatform.
  CasdoorFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static CasdoorFlutterSdkPlatform _instance = MethodChannelCasdoorFlutterSdk();

  /// The default instance of [CasdoorFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelCasdoorFlutterSdk].
  static CasdoorFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CasdoorFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(CasdoorFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  MethodChannel getMethodChannel() {
    return const MethodChannel('casdoor_flutter_sdk');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
