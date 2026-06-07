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
    if (call.method == 'processText') {
      final args = call.arguments as Map;
      final text = args['text'] as String;
      final actionId = args['actionId'] as String;

      return await _handleProcessText(text, actionId);
    }
    throw PlatformException(
      code: 'NOT_IMPLEMENTED',
      message: 'Method ${call.method} not implemented',
    );
  });
}

Future<String> _handleProcessText(String text, String actionId) async {
  try {
    // Load the API key
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not configured. Please open the app to set up.');
    }

    // Load actions to find the correct one
    final actions = await StorageService.getActions();
    final action = actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action "$actionId" not found'),
    );

    // Load settings
    final outputLanguage = await StorageService.getOutputLanguage();
    final clipboardBackup = await StorageService.getClipboardBackup();

    // Copy original to clipboard if preference is set
    if (clipboardBackup) {
      await Clipboard.setData(ClipboardData(text: text));
    }

    // Call Gemini API
    final result = await GeminiService.processText(
      text: text,
      systemPrompt: action.effectivePrompt,
      apiKey: apiKey,
      outputLanguage: outputLanguage,
    );

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
    // On error, return the original text unchanged
    // The error message goes back to Kotlin as an exception,
    // which shows a Toast
    throw PlatformException(
      code: 'PROCESSING_ERROR',
      message: e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
