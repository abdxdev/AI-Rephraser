import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'models/history_entry.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';

/// Background entry point for handling process text requests.
///
/// This runs in a separate FlutterEngine created by the Android Application class.
/// It listens for MethodChannel calls from ProcessTextActivity, calls the Gemini
/// API, and returns the result.
@pragma('vm:entry-point')
void processTextEntrypoint() {
  WidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.test_app/process_text');

  channel.setMethodCallHandler((call) async {
    debugPrint('[ProcessText] Received method call: ${call.method}');
    if (call.method == 'processText') {
      final args = call.arguments as Map;
      final text = args['text'] as String;
      final actionId = args['actionId'] as String;
      debugPrint('[ProcessText] Processing text for action: $actionId');

      return await _handleProcessText(text, actionId);
    }
    throw PlatformException(
      code: 'NOT_IMPLEMENTED',
      message: 'Method ${call.method} not implemented',
    );
  });

  debugPrint('[ProcessText] Handler registered and ready');
}

Future<String> _handleProcessText(String text, String actionId) async {
  try {
    // Load the API key
    debugPrint('[ProcessText] Loading API key...');
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured. Please open the app to set up.');
    }
    debugPrint('[ProcessText] API key loaded successfully');

    // Load actions to find the correct one
    final actions = await StorageService.getActions();
    debugPrint('[ProcessText] Loaded ${actions.length} actions, looking for: $actionId');
    final action = actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action "$actionId" not found'),
    );

    // Load settings
    debugPrint('[ProcessText] Loading outputLanguage...');
    final outputLanguage = await StorageService.getOutputLanguage();
    debugPrint('[ProcessText] Loaded outputLanguage: $outputLanguage');
    
    debugPrint('[ProcessText] Loading clipboardBackup...');
    final clipboardBackup = await StorageService.getClipboardBackup();
    debugPrint('[ProcessText] Loaded clipboardBackup: $clipboardBackup');

    // Copy original to clipboard if preference is set
    if (clipboardBackup) {
      debugPrint('[ProcessText] Attempting to backup to clipboard...');
      try {
        await Clipboard.setData(ClipboardData(text: text))
            .timeout(const Duration(milliseconds: 500));
        debugPrint('[ProcessText] Clipboard backup successful');
      } catch (e) {
        debugPrint('[ProcessText] Clipboard backup failed or timed out: $e');
        // Ignore clipboard errors in background engine
      }
    }

    // Call Gemini API
    debugPrint('[ProcessText] Calling Gemini API with model=${GeminiService.defaultModel}...');
    final result = await GeminiService.processText(
      text: text,
      systemPrompt: action.effectivePrompt,
      apiKey: apiKey,
      outputLanguage: outputLanguage,
    );
    debugPrint('[ProcessText] Gemini API returned successfully');

    // Save to history if enabled
    final historyEnabled = await StorageService.getHistoryEnabled();
    if (historyEnabled) {
      final entry = HistoryEntry(
        id: const Uuid().v4(),
        actionName: action.name,
        timestamp: DateTime.now(),
        originalText: text,
        resultText: result,
      );
      await StorageService.addHistoryEntry(entry);
    }

    return result;
  } catch (e) {
    debugPrint('[ProcessText] Error: $e');
    // On error, return the original text unchanged
    // The error message goes back to Kotlin as an exception,
    // which shows a Toast
    throw PlatformException(
      code: 'PROCESSING_ERROR',
      message: e.toString().replaceFirst('Exception: ', ''),
    );
  }
}

