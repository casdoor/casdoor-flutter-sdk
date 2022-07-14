import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_config.dart';
import 'package:casdoor_flutter_sdk/casdoor_flutter_sdk_oauth.dart';
import 'package:crypto/crypto.dart';
class Casdoor {
  final CasdoorFlutterSdkConfig config;
  late final String codeVerifier;
  late final String nonce;

  Casdoor({required this.config}){
    codeVerifier = generateRandomString(43);
    nonce = generateRandomString(12);
  }

  Uri getSigninUrl({String scope = "read",String? state}) {
    return Uri.https(config.endpoint,"login/oauth/authorize",{
      "client_id":config.clientId,
      "response_type":"code",
      "scope":scope,
      "state": state ?? config.appName,
      "code_challenge_method": "S256",
      "code_challenge":generateCodeChallenge(codeVerifier),
      "redirect_uri": config.redirectUri
    });
  }
  Uri getSignupUrl({String scope = "read",String? state}) {
    return Uri.https(config.endpoint,"/signup/oauth/authorize",{
      "client_id":config.clientId,
      "response_type":"code",
      "scope":scope,
      "state": state ?? config.appName,
      "code_challenge_method": "S256",
      "code_challenge":generateCodeChallenge(codeVerifier),
      "redirect_uri": config.redirectUri
    });
  }

  Future<String> show({String scope = "read",String? state}) async {
    return CasdoorOauth.authenticate(url: getSigninUrl(scope: scope,state: state).toString(), callbackUrlScheme: config.callbackUrlScheme);
  }

  Future<http.Response> requestOauthAccessToken(String code) async {
    return await http.post(Uri.https(config.endpoint, "api/login/oauth/access_token"), body: {
       'client_id': config.clientId,
       'grant_type': 'authorization_code',
       'code': code,
       'code_verifier': codeVerifier
     });
  }
}

String generateRandomString(int length) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
          (index) => availableChars[random.nextInt(availableChars.length)])
      .join();

  return randomString;
}

String generateCodeChallenge(String verifier) {
  var bytes = utf8.encode(verifier);
  var digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll("=", "");
}