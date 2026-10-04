/// Flutter SDK for signing in to [Casdoor](https://casdoor.org) on Android,
/// iOS, macOS, Linux, Windows and the Web.
///
/// Create a [Casdoor] client with an [AuthConfig], open the sign-in page with
/// [Casdoor.show], then exchange the returned code with
/// [Casdoor.requestOauthAccessToken].
library;

export 'src/casdoor.dart';
export 'src/casdoor_flutter_sdk_config.dart';
export 'src/casdoor_flutter_sdk_exceptions.dart';
// The native implementations import dart:io, keep them out of the Web build.
export 'src/casdoor_flutter_sdk_native.dart'
    if (dart.library.js_interop) 'src/casdoor_flutter_sdk_native_stub.dart';
export 'src/casdoor_flutter_sdk_platform_interface.dart';
