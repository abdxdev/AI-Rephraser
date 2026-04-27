import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';
import '../models/text_action.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyKey = 'api_key';
  static const _modelKey = 'gemini_model';
  static const _actionsKey = 'actions';
  static const _historyKey = 'history';
  static const _clipboardBackupKey = 'clipboard_backup';
  static const _outputLanguageKey = 'output_language';
  static const _themeModeKey = 'theme_mode';
  static const _historyEnabledKey = 'history_enabled';
  static const _onboardingCompleteKey = 'onboarding_complete';

  // ---------- API Key (secure) ----------

  static Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  static Future<void> setApiKey(String key) async {
    await _secureStorage.write(key: _apiKeyKey, value: key);
  }

  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

  // ---------- Model ----------

  static Future<String> getModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modelKey) ?? 'gemini-2.5-flash';
  }

  static Future<void> setModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, model);
  }

  // ---------- Actions ----------

  static Future<List<TextAction>> getActions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_actionsKey);
    if (json == null) return TextAction.defaultActions;

    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => TextAction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return TextAction.defaultActions;
    }
  }

  static Future<void> saveActions(List<TextAction> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(actions.map((a) => a.toJson()).toList());
    await prefs.setString(_actionsKey, json);
  }

  // ---------- History ----------

  static Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_historyKey);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveHistory(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep only the last 50 entries
    final trimmed = entries.length > 50
        ? entries.sublist(entries.length - 50)
        : entries;
    final json = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, json);
  }

  static Future<void> addHistoryEntry(HistoryEntry entry) async {
    final entries = await getHistory();
    entries.add(entry);
    await saveHistory(entries);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ---------- Preferences ----------

  static Future<bool> getClipboardBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_clipboardBackupKey) ?? true;
  }

  static Future<void> setClipboardBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clipboardBackupKey, value);
  }

  static Future<String?> getOutputLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_outputLanguageKey);
  }

  static Future<void> setOutputLanguage(String? language) async {
    final prefs = await SharedPreferences.getInstance();
    if (language == null || language.isEmpty) {
      await prefs.remove(_outputLanguageKey);
    } else {
      await prefs.setString(_outputLanguageKey, language);
    }
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  static Future<bool> getHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_historyEnabledKey) ?? true;
  }

  static Future<void> setHistoryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_historyEnabledKey, value);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }
}
