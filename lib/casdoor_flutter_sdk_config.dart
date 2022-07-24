class AuthConfig {
   final String clientId;
   final String endpoint;
   final String organizationName;
   String redirectUri;
   final String callbackUrlScheme;
   final String appName;

   AuthConfig({
      required this.clientId,
      required this.endpoint,
      required this.organizationName,
      required this.appName,
      this.redirectUri = "casdoor://callback",
      this.callbackUrlScheme = "casdoor"});
}