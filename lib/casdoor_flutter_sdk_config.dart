class CasdoorFlutterSdkConfig {
   final String clientId;
   final String endpoint;
   final String organizationName;
   String redirectUri;
   final String callbackUrlScheme;
   final String appName;

  CasdoorFlutterSdkConfig({
      required this.clientId,
      required this.endpoint,
      required this.organizationName,
      required this.appName,
      this.redirectUri = "casdoor://callback",
      this.callbackUrlScheme = "casdoor"});
}