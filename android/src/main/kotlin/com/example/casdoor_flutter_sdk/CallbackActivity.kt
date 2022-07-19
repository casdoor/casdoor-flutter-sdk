package com.example.casdoor_flutter_sdk

import android.app.Activity
import android.net.Uri
import android.os.Bundle

class CallbackActivity: Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val url = intent?.data
    val scheme = url?.scheme

    if (scheme != null) {
      CasdoorFlutterSdkPlugin.callbacks.remove(scheme)?.success(url.toString())
    }

    finish()
  }
}
