#import "CasdoorFlutterSdkPlugin.h"
#if __has_include(<casdoor_flutter_sdk/casdoor_flutter_sdk-Swift.h>)
#import <casdoor_flutter_sdk/casdoor_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "casdoor_flutter_sdk-Swift.h"
#endif

@implementation CasdoorFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCasdoorFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
