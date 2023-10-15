# Casdoor Flutter SDK

<p align="left">
    <a href="https://pub.dev/packages/casdoor_flutter_sdk"><img src="https://img.shields.io/pub/likes/casdoor_flutter_sdk?logo=flutter" alt="Pub.dev likes"/></a>
    <a href="https://pub.dev/packages/casdoor_flutter_sdk"><img src="https://img.shields.io/pub/points/casdoor_flutter_sdk?logo=flutter" alt="Pub.dev points"/></a>
    <a href="https://pub.dev/packages/casdoor_flutter_sdk"><img src="https://img.shields.io/pub/v/casdoor_flutter_sdk.svg?include_prereleases" alt="latest version"/></a>
    <a href="https://pub.dev/packages/casdoor_flutter_sdk"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Web-blue?logo=flutter" alt="Platform"/></a>
    <a href="./LICENSE"><img src="https://img.shields.io/github/license/agoraio-community/flutter-uikit?color=lightgray" alt="License"/></a>
</p>

casdoor-flutter-sdk will allow you to easily connect your Flutter-based application to the [Casdoor authentication system](https://casdoor.org/) without having to implement it from scratch.

The following platforms are supported:

- Android
- iOS
- Linux
- macOS
- Web
- Windows

| **Android**                    | **iOS**                | **Web**                |
| ------------------------------ | ---------------------- | ---------------------- |
| ![Android](screen-andriod.gif) | ![iOS](screen-ios.gif) | ![Web](screen-web.gif) |

# Features

Use this plugin in your Flutter app to:

- Connect to casdoor for SSO
- Get the token after the casdoor authentication

# Usage

This section has examples of code for the following tasks:

- [Initialization requires 6 parameters](#jump1)
- [Judgment platform](#jump2)
- [Authorize with the Casdoor server](#jump3)
- [Get token and parse](#jump4)

<span id="jump1">Initialization requires 6 parameters</span>

Initialization requires 6 parameters, which are all str type:
| Name (in order) | Must | Description |
| ---- | ---- |---- |
| clientId | Yes | Application.client_id |
| endpoint | Yes | Casdoor Server Url, such as `door.casdoor.com` |
| organizationName | Yes | Organization name |
| appName | Yes | Application name |
| redirectUri | Yes | URI of Web redirection |
| callbackUrlScheme | Yes | URL Scheme |

```
  final CasdoorFlutterSdkConfig _config =  CasdoorFlutterSdkConfig(
      clientId: "014ae4bd048734ca2dea",
      endpoint: "door.casdoor.com",
      organizationName: "casbin",
      appName: "app-casnode",
      redirectUri: "http://localhost:9000/callback",
      callbackUrlScheme: "casdoor"
  );
```

<span id="jump2">Judgment platform</span>

Set the callbackuri parameter by judging different platforms

```
 final platform = await CasdoorFlutterSdkPlatform.instance.getPlatformVersion() ?? "";
    String callbackUri;
    if (platform == "web") {
       callbackUri = "${_config.redirectUri}.html";
    } else {
       callbackUri = "${_config.callbackUrlScheme}://callback" ;
    }
```

<span id="jump3">Authorize with the Casdoor server</span>

At this point, we should use some ways to verify with the Casdoor server.

To start, we want you understand clearly the verification process of Casdoor. The following paragraphs will mention your app that wants to use Casdoor as a means of verification as `APP`, and Casdoor as `Casdoor`.

1. `APP` will send a request to` Casdoor`.
   Since `Casdoor` is a UI-based OAuth provider, you cannot use request management service like Postman to send a URL with parameters and get back a JSON file.

2. The simplest way to try it out is to type the URL in your browser.

3. Type in the URL in your browser in this format: `endpoint/login/oauth/authorize?client_id=xxx&response_type=code&redirect_uri=xxx&scope=read&state=xxx`
   In this URL the `endpoint` is your Casdoor's location, as mentioned in Step1; then the `xxx` need to be filled out by yourself.

<span id="jump4">Get token and parse</span>

After Casdoor verification passed, it will be redirected to your application with code and state, like `https://localhost:9000/callback?code=xxx&state=yyyy`.

Your application can get the `code` and call` _casdoor.requestOauthAccessToken(code)`, then parse out jwt token.

# Getting Started

Add casdoor-flutter-sdk to the dependencies of your pubspec.yaml.

```
dependencies:
  casdoor_flutter_sdk: ^1.0.0
```

Notes for different platforms:

## Android and iOS

Please check the [documentation](https://inappwebview.dev/docs/intro) of the InAppWebView package for more details.

## Android

Increase the SDK version in `android/app/build.gradle` to 34:

```
...
android {
    compileSdkVersion 34
...
```

## Windows and Linux

Please check the [documentation](https://pub.dev/packages/desktop_webview_window) of the desktop_webview_window package for more details.

## Web

On the Web platform an endpoint needs to be created that captures the callback URL and sends it to the application using the JavaScript postMessage() method. In the ./web folder of the project, create an HTML file with the name e.g. callback.html with content:

```
<!DOCTYPE html>
<title>Authentication complete</title>
<p>Authentication is complete. If this does not happen automatically, please
close the window.
<script>
  window.opener.postMessage({
    'casdoor-auth': window.location.href
  }, window.location.origin);
  window.close();
</script>

```

Redirection URL passed to the authentication service must be the same as the URL on which the application is running (schema, host, port if necessary) and the path must point to created HTML file, /callback.html in this case, like `callbackUri = "${_config.redirectUri}.html"`. The callbackUrlScheme parameter of the authenticate() method does not take into account, so it is possible to use a schema for native platforms in the code.It should be noted that when obtaining a token, cross domain may occur

For the Sign in with Apple in web_message response mode, postMessage from https://appleid.apple.com is also captured, and the authorization object is returned as a URL fragment encoded as a query string (for compatibility with other providers).

# API reference interface

#### Get sign up url

```typescript
getSignupUrl(enablePassword)
```

#### Get sign in url

```typescript
getSigninUrl()
```

#### Get code in a new window (all platforms)

```typescript
show()
```

#### Get code inside the app (Android and iOS)

```typescript
showFullscreen()
```

#### Get token

```typescript
requestOauthAccessToken()
```

#### Refresh token

```typescript
refreshToken()
```

#### Log out

```typescript
tokenLogout()
```

#### Get user information

```typescript
getUserInfo()
```

#### Decode token

```typescript
decodedToken()
```

#### Judge whether the token is expired

```typescript
isTokenExpired()
```

#### Verify nonce

```typescript
isNonce()
```

# Example

See at: https://github.com/casdoor/casdoor-flutter-example
