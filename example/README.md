# casdoor_flutter_sdk example

A minimal app that signs in to the demo Casdoor server `https://door.casdoor.com`, shows the user name from the access token and signs out. The main code is in [lib/main.dart](lib/main.dart).

Generate the platform folders and run it:

```bash
flutter create --platforms=android,ios,linux,macos,web,windows .
flutter run
```

On native platforms the redirect URI is `casdoor://callback`. On Android, add the callback activity for the `casdoor` scheme to `android/app/src/main/AndroidManifest.xml` as described in the [Android setup](../README.md#android) of the SDK. On the Web the redirect URI is `http://localhost:9000/callback.html`, served from [web/callback.html](web/callback.html), so run the app on port 9000:

```bash
flutter run -d chrome --web-port 9000
```

See the README of the SDK for the platform setup, and https://github.com/casdoor/casdoor-flutter-example for a complete app with all platform folders.
