package com.example.casdoor_flutter_sdk

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build

import androidx.browser.customtabs.CustomTabsIntent

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class CasdoorFlutterSdkPlugin(private var context: Context? = null, private var channel: MethodChannel? = null): MethodCallHandler, FlutterPlugin {

  companion object {
    val callbacks = mutableMapOf<String, Result>()

      @JvmStatic
      fun registerWith(registrar: Registrar) {
          val plugin = CasdoorFlutterSdkPlugin()
          plugin.initInstance(registrar.messenger(), registrar.context())
      }
  }

  private fun initInstance(messenger: BinaryMessenger, context: Context) {
      this.context = context
      channel = MethodChannel(messenger, "casdoor_flutter_sdk")
      channel?.setMethodCallHandler(this)
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
      initInstance(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
      context = null
      channel = null
  }

  override fun onMethodCall(call: MethodCall, resultCallback: Result) {
    when (call.method) {
        "authenticate" -> {
          val url = Uri.parse(call.argument("url"))
          val callbackUrlScheme = call.argument<String>("callbackUrlScheme")!!
          val preferEphemeral = call.argument<Boolean>("preferEphemeral")!!

          callbacks[callbackUrlScheme] = resultCallback

          val intent = CustomTabsIntent.Builder().build()
          val keepAliveIntent = Intent(context, KeepAliveService::class.java)

          intent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
          if (preferEphemeral) {
              intent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
          }
          intent.intent.putExtra("android.support.customs.extra.KEEP_ALIVE", keepAliveIntent)

          intent.launchUrl(context!!, url)
        }
        "cleanUpDanglingCalls" -> {
          callbacks.forEach{ (_, danglingResultCallback) ->
              danglingResultCallback.error("CANCELED", "User canceled login", null)
          }
          callbacks.clear()
          resultCallback.success(null)
        }
        "getPlatformVersion" -> {
            resultCallback.success("Android ${Build.VERSION.RELEASE}")
        }
        else -> resultCallback.notImplemented()
    }
  }
}
