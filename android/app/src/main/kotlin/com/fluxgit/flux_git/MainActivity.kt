package com.fluxgit.flux_git

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.fluxgit/termux"
    private val termuxPackage = "com.termux"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openTermux" -> {
                        val intent = packageManager.getLaunchIntentForPackage(termuxPackage)
                        if (intent != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("NOT_INSTALLED", "Termux is not installed", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
