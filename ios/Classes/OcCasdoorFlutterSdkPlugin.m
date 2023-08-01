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

#import <Foundation/Foundation.h>
#import "CasdoorFlutterSdkPlugin.h"
#import <UIKit/UIKit.h>
// #import <WXApiObject.h>
// #import <WXApi.h>
// #import <WechatAuthSDK.h>
@import WebKit;

// #define APP_ID @"wx049c70e6c2027b0b"
// #define UNIVERSAL_LINK @"https://testdomain.com"


typedef void (^AuthResultCallback)(NSString *);
@interface CasdoorFlutterSdkPlugin () <FlutterPlugin, WKNavigationDelegate, WXApiDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *callbackURLScheme;
@property (nonatomic, copy) AuthResultCallback authResultCallback;
@end

@implementation CasdoorFlutterSdkPlugin




+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"casdoor_flutter_sdk"
                                     binaryMessenger:[registrar messenger]];
    CasdoorFlutterSdkPlugin* instance = [[CasdoorFlutterSdkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[WKWebView alloc] init];
        _webView.navigationDelegate = self;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"authenticate"]) {
        NSDictionary *arguments = call.arguments;
        NSString *urlString = arguments[@"url"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *callbackURLScheme = arguments[@"callbackUrlScheme"];

        self.callbackURLScheme = callbackURLScheme;

        __weak typeof(self) weakSelf = self;
        self.authResultCallback = ^(NSString *authResult) {
            result(authResult);
        };

        UIViewController *viewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
        self.webView.frame = viewController.view.bounds;
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [viewController.view addSubview:self.webView];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:0 metrics:nil views:@{@"view": self.webView}]];
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:@{@"view": self.webView}]];

        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.webView loadRequest:req];
        });
    } else if ([call.method isEqualToString:@"cleanUpDanglingCalls"]) {
        result(nil);
    } else if ([call.method isEqualToString:@"getPlatformVersion"]) {
        NSString *version = [NSString stringWithFormat:@"iOS %@", [[NSProcessInfo processInfo] operatingSystemVersionString]];
        result(version);
    } else if ([call.method isEqualToString:@"registerWXApi"]) {
        NSDictionary *arguments = call.arguments;
        NSString *app_id = arguments[@"app_id"];
        NSString *universal_link = arguments[@"universal_link"];
        // register WeChat
//         BOOL isWeChatRegistered = [WXApi registerApp:app_id universalLink:universal_link];
//         NSLog(@"Is WeChat Registered: %@",  isWeChatRegistered ? @"YES" : @"NO");
    }else {
        result(FlutterMethodNotImplemented);
    }
}

// - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//     return  [WXApi handleOpenURL:url delegate:self];
// }

// - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//     return [WXApi handleOpenURL:url delegate:self];
// }

// - (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
//     return [WXApi handleOpenUniversalLink:userActivity delegate:self];
// }

// -(void) onReq:(BaseReq*)reqonReq {
//
// }

// -(void) onResp:(BaseResp*)resp {
//     /*
//     enum WXErrCode {
//     WXSuccess = 0, 成功
//     WXErrCodeCommon = -1, 普通错误类型
//     WXErrCodeUserCancel = -2, 用户点击取消并返回
//     WXErrCodeSentFail = -3, 发送失败
//     WXErrCodeAuthDeny = -4, 授权失败
//     WXErrCodeUnsupport = -5, 微信不支持
//     };
//     */
//     if (resp.errCode == 0) { //Success
//         NSLog(@"Login Success.");
//         SendAuthResp *resp2 = (SendAuthResp *)resp;
//         NSLog(@"code: %@", resp2.code);
//
//     }else{ //Failed
//         NSLog(@"error %@", resp.errStr);
//         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login failed." message:[NSString stringWithFormat:@"reason: %@", resp.errStr] preferredStyle:UIAlertControllerStyleAlert];
//
//         UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
//         UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil];
//
//         [alertController addAction:cancelAction];
//         [alertController addAction:confirmAction];
//
//         UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
//         [rootViewController presentViewController:alertController animated:YES completion:nil];
//     }
// }

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *callbackUrl = navigationAction.request.URL;
    if (callbackUrl.scheme && [callbackUrl.scheme isEqualToString:self.callbackURLScheme]) {

        NSLog(@"callbackUrl: %@", callbackUrl);

        self.authResultCallback(callbackUrl.absoluteString);

        decisionHandler(WKNavigationActionPolicyCancel);
        [webView removeFromSuperview];
        return;
    } else if ([navigationAction.request.URL.absoluteString containsString:@"https://open.weixin.qq.com"]) {

        BOOL isInstalled = [WXApi isWXAppInstalled];
        NSLog(@"Is WeChat Installed: %@",  isInstalled ? @"YES" : @"NO");
        if ([WXApi isWXAppInstalled]) {

            // Open the log before register, and you can troubleshoot problems based on the log later
//            [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
//                NSLog(@"WeChatSDK: %@", log);
//            }];
//
//            // Call the self-test function
//            [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
//                NSLog(@"%@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
//            }];

//            SendAuthReq *req = [[SendAuthReq alloc]init];
//            req.scope = @"snsapi_userinfo";
//            req.state = @"wx_oauth_authorization_state";
//            [WXApi sendReq:req completion:nil];


            decisionHandler(WKNavigationActionPolicyCancel);
            [webView removeFromSuperview];
        }else{
            // If WeChat is not installed, do nothing, use the scan code of the website to log in.
        }

        NSLog(@"Clicked on a link containing 'https://open.weixin.qq.com'");
        return;
    } else if ([navigationAction.request.URL.absoluteString containsString:@"https://openauth.alipay.com"]) {
        // If we click on Alipay as a third-party login, write the implementation part here.
//        decisionHandler(WKNavigationActionPolicyCancel);
//        [webView removeFromSuperview];
        NSLog(@"Clicked on a link containing 'https://openauth.alipay.com'");
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

@end


