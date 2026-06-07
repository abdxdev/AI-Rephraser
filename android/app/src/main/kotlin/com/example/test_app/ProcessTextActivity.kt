package com.example.test_app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class ProcessTextActivity : Activity() {
    private val TAG = "ProcessTextActivity"

    companion object {
        private const val CHANNEL_NAME = "com.example.test_app/process_text"
        private const val MAX_RETRIES = 20
        private const val RETRY_DELAY_MS = 500L
    }

    private var hasReturned = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Show a translucent overlay with a spinner
        showLoadingOverlay()

        val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString() ?: ""
        val readonly = intent.getBooleanExtra(Intent.EXTRA_PROCESS_TEXT_READONLY, false)

        // Get action ID from this activity-alias's meta-data
        val actionId = getActionId()

        // Get the cached FlutterEngine
        val engine = FlutterEngineCache.getInstance().get(App.PROCESS_TEXT_ENGINE_ID)
        if (engine == null) {
            Log.e(TAG, "FlutterEngine not found in cache")
            Toast.makeText(this, "AI Text not initialized. Please open the app first.", Toast.LENGTH_SHORT).show()
            returnResult(text)
            return
        }

        Log.d(TAG, "Calling Dart with actionId=$actionId, text length=${text.length}")
        callDart(engine, text, actionId, MAX_RETRIES)

        // Timeout: if no result after 60 seconds, return original
        // gemini-2.5-flash is a thinking model and can take longer
        Handler(Looper.getMainLooper()).postDelayed({
            if (!hasReturned) {
                Toast.makeText(this, "Request timed out", Toast.LENGTH_SHORT).show()
                returnResult(text)
            }
        }, 60000)
    }

    private fun showLoadingOverlay() {
        val frame = FrameLayout(this).apply {
            setBackgroundColor(0x80000000.toInt())
            val progressBar = ProgressBar(this@ProcessTextActivity).apply {
                layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    Gravity.CENTER
                )
            }
            addView(progressBar)
        }
        setContentView(frame)
    }

    private fun getActionId(): String {
        return try {
            val ai = packageManager.getActivityInfo(
                componentName,
                PackageManager.GET_META_DATA
            )
            ai.metaData?.getString("action_id") ?: "rephrase"
        } catch (e: Exception) {
            "rephrase"
        }
    }

    private fun callDart(
        engine: io.flutter.embedding.engine.FlutterEngine,
        text: String,
        actionId: String,
        retriesLeft: Int
    ) {
        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)

        channel.invokeMethod(
            "processText",
            mapOf("text" to text, "actionId" to actionId),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.d(TAG, "Dart returned success")
                    val processed = result as? String ?: text
                    returnResult(processed)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "Dart returned error: $errorCode - $errorMessage")
                    Toast.makeText(
                        this@ProcessTextActivity,
                        errorMessage ?: "Processing failed",
                        Toast.LENGTH_SHORT
                    ).show()
                    returnResult(text)
                }

                override fun notImplemented() {
                    Log.w(TAG, "Dart handler not implemented yet, retries left: $retriesLeft")
                    if (retriesLeft > 0) {
                        Handler(Looper.getMainLooper()).postDelayed({
                            callDart(engine, text, actionId, retriesLeft - 1)
                        }, RETRY_DELAY_MS)
                    } else {
                        Toast.makeText(
                            this@ProcessTextActivity,
                            "Service not ready. Please open the app first.",
                            Toast.LENGTH_SHORT
                        ).show()
                        returnResult(text)
                    }
                }
            }
        )
    }

    private fun returnResult(text: String) {
        if (hasReturned) return
        hasReturned = true

        val resultIntent = Intent().apply {
            putExtra(Intent.EXTRA_PROCESS_TEXT, text)
        }
        setResult(RESULT_OK, resultIntent)
        finish()
    }
}
