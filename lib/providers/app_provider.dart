import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../models/text_action.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';
import '../services/platform_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  List<TextAction> _actions = [];
  List<HistoryEntry> _history = [];
  String? _apiKey;
  bool _clipboardBackup = true;
  String? _outputLanguage;
  String _themeMode = 'system';
  bool _historyEnabled = true;
  bool _onboardingComplete = false;
  bool _isLoading = true;
  String? _connectionTestResult;
  bool _isTesting = false;

  List<TextAction> get actions => _actions;
  List<TextAction> get builtInActions =>
      _actions.where((a) => a.isBuiltIn).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  List<TextAction> get customActions =>
      _actions.where((a) => !a.isBuiltIn).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  List<TextAction> get enabledActions =>
      _actions.where((a) => a.isEnabled).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  List<HistoryEntry> get history => _history.reversed.toList();
  String? get apiKey => _apiKey;
  String get model => GeminiService.defaultModel;
  bool get clipboardBackup => _clipboardBackup;
  String? get outputLanguage => _outputLanguage;
  String get themeMode => _themeMode;
  bool get historyEnabled => _historyEnabled;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;
  bool get isApiConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  String? get connectionTestResult => _connectionTestResult;
  bool get isTesting => _isTesting;

  ThemeMode get themeModeEnum {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _apiKey = await StorageService.getApiKey();
    _actions = await StorageService.getActions();
    _history = await StorageService.getHistory();
    _clipboardBackup = await StorageService.getClipboardBackup();
    _outputLanguage = await StorageService.getOutputLanguage();
    _themeMode = await StorageService.getThemeMode();
    _historyEnabled = await StorageService.getHistoryEnabled();
    _onboardingComplete = await StorageService.isOnboardingComplete();

    await _syncHistoryIfLoggedIn();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncHistoryIfLoggedIn() async {
    if (AuthService.isLoggedIn && AuthService.userId != null) {
      final userId = AuthService.userId!;

      final remoteHistory = await FirestoreService.getHistory(userId);

      if (remoteHistory.isEmpty && _history.isNotEmpty) {
        await FirestoreService.syncLocalToCloud(userId, _history);
      } else if (remoteHistory.isNotEmpty) {
        _history = remoteHistory;
        await StorageService.saveHistory(_history);
      }
    }
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await StorageService.setApiKey(key);
    notifyListeners();
  }

  Future<void> testConnection() async {
    debugPrint('[AppProvider] Testing API connection...');
    if (!isApiConfigured) {
      debugPrint('[AppProvider] Test failed: API key not configured');
      _connectionTestResult = 'API key not configured';
      notifyListeners();
      return;
    }

    _isTesting = true;
    _connectionTestResult = null;
    notifyListeners();

    debugPrint('[AppProvider] Calling GeminiService.testConnection...');
    final error = await GeminiService.testConnection(
      apiKey: _apiKey!,
    );

    _isTesting = false;
    _connectionTestResult = error ?? 'Connected successfully!';
    debugPrint('[AppProvider] Connection test complete. Result: $_connectionTestResult');
    notifyListeners();
  }

  Future<void> toggleAction(String actionId, bool enabled) async {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    _actions[idx].isEnabled = enabled;
    await StorageService.saveActions(_actions);
    await PlatformService.setActionEnabled(actionId, enabled);
    notifyListeners();
  }

  Future<void> updateActionPrompt(String actionId, String? prompt) async {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    _actions[idx].customPromptOverride = prompt;
    await StorageService.saveActions(_actions);
    notifyListeners();
  }

  Future<void> updateActionModelOverride(
    String actionId,
    String? modelOverride,
  ) async {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;
    _actions[idx].modelOverride = modelOverride;
    await StorageService.saveActions(_actions);
    notifyListeners();
  }

  Future<void> reorderActions(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = _actions.removeAt(oldIndex);
    _actions.insert(newIndex, item);
    for (int i = 0; i < _actions.length; i++) {
      _actions[i].order = i;
    }
    await StorageService.saveActions(_actions);
    notifyListeners();
  }

  Future<void> addCustomAction({
    required String name,
    required String systemPrompt,
    String? modelOverride,
    String iconName = 'auto_fix_high',
  }) async {

    final usedSlots = _actions
        .where((a) => a.id.startsWith('custom_'))
        .map((a) => a.id)
        .toSet();
    String? slotId;
    for (int i = 1; i <= 5; i++) {
      final id = 'custom_$i';
      if (!usedSlots.contains(id)) {
        slotId = id;
        break;
      }
    }
    if (slotId == null) {
      throw Exception('Maximum 5 custom actions allowed');
    }

    final action = TextAction(
      id: slotId,
      name: name,
      systemPrompt: systemPrompt,
      isBuiltIn: false,
      isEnabled: true,
      order: _actions.length,
      modelOverride: modelOverride,
      iconName: iconName,
    );

    _actions.add(action);
    await StorageService.saveActions(_actions);
    await PlatformService.setActionEnabled(slotId, true);
    notifyListeners();
  }

  Future<void> editCustomAction({
    required String actionId,
    required String name,
    required String systemPrompt,
    String? modelOverride,
    String iconName = 'auto_fix_high',
  }) async {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx == -1) return;

    _actions[idx] = _actions[idx].copyWith(
      name: name,
      systemPrompt: systemPrompt,
      modelOverride: modelOverride,
      iconName: iconName,
    );

    await StorageService.saveActions(_actions);
    notifyListeners();
  }

  Future<void> deleteCustomAction(String actionId) async {
    _actions.removeWhere((a) => a.id == actionId);
    await StorageService.saveActions(_actions);
    await PlatformService.setActionEnabled(actionId, false);
    notifyListeners();
  }

  Future<void> reloadHistory() async {
    if (AuthService.isLoggedIn && AuthService.userId != null) {
      _history = await FirestoreService.getHistory(AuthService.userId!);
      await StorageService.saveHistory(_history);
    } else {
      _history = await StorageService.getHistory();
    }
    notifyListeners();
  }

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    if (!_historyEnabled) return;

    await StorageService.addHistoryEntry(entry);
    _history.add(entry);

    if (AuthService.isLoggedIn && AuthService.userId != null) {
      await FirestoreService.addHistoryEntry(AuthService.userId!, entry);
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await StorageService.clearHistory();
    if (AuthService.isLoggedIn && AuthService.userId != null) {
      await FirestoreService.clearHistory(AuthService.userId!);
    }
    notifyListeners();
  }

  Future<void> setClipboardBackup(bool value) async {
    _clipboardBackup = value;
    await StorageService.setClipboardBackup(value);
    notifyListeners();
  }

  Future<void> setOutputLanguage(String? language) async {
    _outputLanguage = language;
    await StorageService.setOutputLanguage(language);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await StorageService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setHistoryEnabled(bool value) async {
    _historyEnabled = value;
    await StorageService.setHistoryEnabled(value);
    notifyListeners();
  }

  Future<void> setOnboardingComplete() async {
    _onboardingComplete = true;
    await StorageService.setOnboardingComplete(true);
    notifyListeners();
  }
}
