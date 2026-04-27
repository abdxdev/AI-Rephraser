package com.example.test_app

import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.FlutterInjector

class App : FlutterApplication() {
    companion object {
        const val PROCESS_TEXT_ENGINE_ID = "process_text_engine"
    }

    override fun onCreate() {
        super.onCreate()

        // Create and cache a FlutterEngine for background process text handling
        val flutterEngine = FlutterEngine(this)

        // Start executing Dart code in the background entry point
        val flutterLoader = FlutterInjector.instance().flutterLoader()
        flutterLoader.startInitialization(this)
        flutterLoader.ensureInitializationComplete(this, null)

        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                flutterLoader.findAppBundlePath(),
                "processTextEntrypoint"
            )
        )

        // Cache the engine so ProcessTextActivity can use it
        FlutterEngineCache.getInstance().put(PROCESS_TEXT_ENGINE_ID, flutterEngine)
    }
}
