import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/gemini_service.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late TextEditingController _apiKeyController;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    _apiKeyController = TextEditingController(text: provider.apiKey ?? '');
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('API Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Key Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.key, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Gemini API Key',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'API Key',
                      hintText: 'Enter your Gemini API key',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscureKey
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscureKey = !_obscureKey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.save),
                            onPressed: () async {
                              await provider.setApiKey(
                                _apiKeyController.text.trim(),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('API key saved'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get your API key from Google AI Studio: ai.google.dev',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Model Selection Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Model', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<String>(
                    groupValue: provider.model,
                    onChanged: (value) {
                      if (value != null) provider.setModel(value);
                    },
                    child: Column(
                      children: GeminiService.availableModels
                          .map(
                            (model) => RadioListTile<String>(
                              title: Text(model),
                              value: model,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Connection Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_tethering, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Test Connection',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: provider.isTesting
                          ? null
                          : provider.testConnection,
                      icon: provider.isTesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        provider.isTesting ? 'Testing...' : 'Test API',
                      ),
                    ),
                  ),
                  if (provider.connectionTestResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            provider.connectionTestResult ==
                                'Connected successfully!'
                            ? colorScheme.primaryContainer
                            : colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.connectionTestResult ==
                                    'Connected successfully!'
                                ? Icons.check_circle
                                : Icons.error,
                            size: 20,
                            color:
                                provider.connectionTestResult ==
                                    'Connected successfully!'
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.connectionTestResult!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    provider.connectionTestResult ==
                                        'Connected successfully!'
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
