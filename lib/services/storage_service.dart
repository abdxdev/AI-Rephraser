import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';
import '../models/text_action.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyKey = 'api_key';
  static const _actionsKey = 'actions';
  static const _historyKey = 'history';
  static const _clipboardBackupKey = 'clipboard_backup';
  static const _outputLanguageKey = 'output_language';
  static const _themeModeKey = 'theme_mode';
  static const _historyEnabledKey = 'history_enabled';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const String _encryptionKey = 'gemini_api_key_secret_123!';

  static String _encrypt(String text) {
    if (text.isEmpty) return text;
    final textBytes = utf8.encode(text);
    final keyBytes = utf8.encode(_encryptionKey);
    final encryptedBytes = <int>[];
    for (int i = 0; i < textBytes.length; i++) {
      encryptedBytes.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return base64.encode(encryptedBytes);
  }

  static String _decrypt(String text) {
    if (text.isEmpty) return text;
    try {
      final encryptedBytes = base64.decode(text);
      final keyBytes = utf8.encode(_encryptionKey);
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return text;
    }
  }

  static Future<String?> getApiKey() async {
    final key = await _secureStorage.read(key: _apiKeyKey);
    if (key != null) {
      return _decrypt(key);
    }
    return null;
  }

  static Future<void> setApiKey(String key) async {
    final encryptedKey = _encrypt(key);
    await _secureStorage.write(key: _apiKeyKey, value: encryptedKey);
  }

  static Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

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
