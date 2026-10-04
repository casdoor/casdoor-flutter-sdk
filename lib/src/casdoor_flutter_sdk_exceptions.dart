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

/// Thrown when the user closes the sign-in page before signing in.
class CasdoorAuthCancelledException implements Exception {}

/// Thrown when no web view is available on the desktop platform.
class CasdoorDesktopWebViewNotAvailableException implements Exception {}

/// Thrown when a sign-in window is already open on the desktop platform.
class CasdoorDesktopWebViewAlreadyOpenException implements Exception {}

/// Thrown when the iOS web authentication session is not available or
/// another one is in progress.
class CasdoorMobileWebAuthSessionNotAvailableException implements Exception {}

/// Thrown when the iOS web authentication session fails to start.
class CasdoorMobileWebAuthSessionFailedException implements Exception {}
