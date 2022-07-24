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

import Flutter
import UIKit
import AuthenticationServices
import SafariServices

public class SwiftCasdoorFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "casdoor_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftCasdoorFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "authenticate",
              let arguments = call.arguments as? Dictionary<String, AnyObject>,
              let urlString = arguments["url"] as? String,
              let url = URL(string: urlString),
              let callbackURLScheme = arguments["callbackUrlScheme"] as? String,
              let preferEphemeral = arguments["preferEphemeral"] as? Bool
           {

               var sessionToKeepAlive: Any? = nil // if we do not keep the session alive, it will get closed immediately while showing the dialog
               let completionHandler = { (url: URL?, err: Error?) in
                   sessionToKeepAlive = nil

                   if let err = err {
                       if #available(iOS 12, *) {
                           if case ASWebAuthenticationSessionError.canceledLogin = err {
                               result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
                               return
                           }
                       }

                       if #available(iOS 11, *) {
                           if case SFAuthenticationError.canceledLogin = err {
                               result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
                               return
                           }
                       }

                       result(FlutterError(code: "EUNKNOWN", message: err.localizedDescription, details: nil))
                       return
                   }

                   guard let url = url else {
                       result(FlutterError(code: "EUNKNOWN", message: "URL was null, but no error provided.", details: nil))
                       return
                   }

                   result(url.absoluteString)
               }

               if #available(iOS 12, *) {
                   let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)

                   if #available(iOS 13, *) {
                       guard var topController = UIApplication.shared.keyWindow?.rootViewController else {
                           result(FlutterError.aquireRootViewControllerFailed)
                           return
                       }

                       while let presentedViewController = topController.presentedViewController {
                           topController = presentedViewController
                       }
                       if let nav = topController as? UINavigationController {
                           topController = nav.visibleViewController ?? topController
                       }

                       guard let contextProvider = topController as? ASWebAuthenticationPresentationContextProviding else {
                           result(FlutterError.aquireRootViewControllerFailed)
                           return
                       }
                       session.presentationContextProvider =  contextProvider
                       session.prefersEphemeralWebBrowserSession = preferEphemeral
                   }

                   session.start()
                   sessionToKeepAlive = session
               } else if #available(iOS 11, *) {
                   let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                   session.start()
                   sessionToKeepAlive = session
               } else {
                   result(FlutterError(code: "FAILED", message: "This plugin does currently not support iOS lower than iOS 11" , details: nil))
               }
           } else if (call.method == "cleanUpDanglingCalls") {
               // we do not keep track of old callbacks on iOS, so nothing to do here
               result(nil)
           } else if (call.method == "getPlatformVersion") {
               result("iOS " + ProcessInfo.processInfo.operatingSystemVersionString)
           } else {
               result(FlutterMethodNotImplemented)
           }
       }
}
@available(iOS 13, *)
extension FlutterViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}

fileprivate extension FlutterError {
    static var aquireRootViewControllerFailed: FlutterError {
        return FlutterError(code: "AQUIRE_ROOT_VIEW_CONTROLLER_FAILED", message: "Failed to aquire root view controller" , details: nil)
    }
}