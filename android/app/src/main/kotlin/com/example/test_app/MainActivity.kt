package com.example.test_app

import android.content.ComponentName
import android.content.pm.PackageManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val PLATFORM_CHANNEL = "com.example.test_app/platform"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLATFORM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setActionEnabled" -> {
                        val actionId = call.argument<String>("actionId")
                        val enabled = call.argument<Boolean>("enabled")
                        if (actionId != null && enabled != null) {
                            setActionComponentEnabled(actionId, enabled)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGS", "Missing actionId or enabled", null)
                        }
                    }
                    "showToast" -> {
                        val message = call.argument<String>("message") ?: ""
                        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun setActionComponentEnabled(actionId: String, enabled: Boolean) {
        val componentMap = mapOf(
            "rephrase" to ".ProcessTextRephrase",
            "fix_grammar" to ".ProcessTextFixGrammar",
            "shorten" to ".ProcessTextShorten",
            "expand" to ".ProcessTextExpand",
            "formal" to ".ProcessTextFormal",
            "casual" to ".ProcessTextCasual",
            "summarize" to ".ProcessTextSummarize",
            "custom_1" to ".ProcessTextCustom1",
            "custom_2" to ".ProcessTextCustom2",
            "custom_3" to ".ProcessTextCustom3",
            "custom_4" to ".ProcessTextCustom4",
            "custom_5" to ".ProcessTextCustom5",
        )

        val aliasName = componentMap[actionId] ?: return
        val componentName = ComponentName(packageName, "$packageName$aliasName")
        val newState = if (enabled)
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        else
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED

        packageManager.setComponentEnabledSetting(
            componentName,
            newState,
            PackageManager.DONT_KILL_APP
        )
    }
}
