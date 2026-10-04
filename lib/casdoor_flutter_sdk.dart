/// Flutter SDK for signing in to [Casdoor](https://casdoor.org) on Android,
/// iOS, macOS, Linux, Windows and the Web.
///
/// Create a [Casdoor] client with an [AuthConfig], open the sign-in page with
/// [Casdoor.show] or [Casdoor.showFullscreen], then exchange the returned code
/// with [Casdoor.requestOauthAccessToken].
library;

export 'src/casdoor.dart';
export 'src/casdoor_flutter_sdk_config.dart';
export 'src/casdoor_flutter_sdk_desktop.dart';
export 'src/casdoor_flutter_sdk_exceptions.dart';
export 'src/casdoor_flutter_sdk_mobile.dart';
export 'src/casdoor_flutter_sdk_platform_interface.dart';
