# casdoor_flutter_sdk example

A minimal app that signs in to the demo Casdoor server `https://door.casdoor.com`, shows the user name from the access token and signs out. The main code is in [lib/main.dart](lib/main.dart).

Generate the platform folders and run it:

```bash
flutter create --platforms=android,ios,linux,macos,web,windows .
flutter run
```

On native platforms the redirect URI is `casdoor://callback`. On the Web it is `http://localhost:9000/callback.html`, served from [web/callback.html](web/callback.html), so run the app on port 9000:

```bash
flutter run -d chrome --web-port 9000
```

See the README of the SDK for the platform setup, and https://github.com/casdoor/casdoor-flutter-example for a complete app with all platform folders.
