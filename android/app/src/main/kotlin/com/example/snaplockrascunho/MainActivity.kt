package com.example.snaplockrascunho

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"snaplock/screen_security",
		).setMethodCallHandler { call, result ->
			if (call.method != "setEnabled") {
				result.notImplemented()
				return@setMethodCallHandler
			}

			val enabled = call.arguments as? Boolean
			if (enabled == null) {
				result.error("invalid_argument", "Expected a boolean value.", null)
				return@setMethodCallHandler
			}

			if (enabled) {
				window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
			} else {
				window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
			}
			result.success(null)
		}
	}
}
