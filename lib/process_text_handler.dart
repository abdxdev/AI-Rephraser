import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import 'models/history_entry.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';

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
    debugPrint('[ProcessText] Loading API key...');
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('[ProcessText] Error: API key not configured');
      throw Exception('API key not configured. Please open the app to set up.');
    }
    debugPrint('[ProcessText] API key loaded successfully');

    debugPrint('[ProcessText] Loading actions to find ID: $actionId');
    final actions = await StorageService.getActions();
    final action = actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action "$actionId" not found'),
    );
    debugPrint('[ProcessText] Action found: ${action.name}');

    debugPrint('[ProcessText] Loading settings...');
    final outputLanguage = await StorageService.getOutputLanguage();
    final clipboardBackup = await StorageService.getClipboardBackup();

    if (clipboardBackup) {
      debugPrint('[ProcessText] Attempting to backup to clipboard...');
      try {
        await Clipboard.setData(ClipboardData(text: text))
            .timeout(const Duration(milliseconds: 500));
        debugPrint('[ProcessText] Clipboard backup successful');
      } catch (e) {
        debugPrint('[ProcessText] Clipboard backup failed/timed out: $e');
      }
    }

    debugPrint('[ProcessText] Calling Gemini API...');
    final result = await GeminiService.processText(
      text: text,
      systemPrompt: action.effectivePrompt,
      apiKey: apiKey,
      outputLanguage: outputLanguage,
    );
    debugPrint('[ProcessText] Gemini API returned successfully');

    debugPrint('[ProcessText] Saving to history...');
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
      debugPrint('[ProcessText] Saved to history');
    }

    debugPrint('[ProcessText] Processing complete');
    return result;
  } catch (e) {
    debugPrint('[ProcessText] Error during processing: $e');
    throw PlatformException(
      code: 'PROCESSING_ERROR',
      message: e.toString().replaceFirst('Exception: ', ''),
    );
  }
}
