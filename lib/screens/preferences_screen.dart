import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  static const _languages = [
    null, // Auto (no override)
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Russian',
    'Turkish',
    'Urdu',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.palette, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text('Appearance', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  RadioGroup<String>(
                    groupValue: provider.themeMode,
                    onChanged: (v) {
                      if (v != null) provider.setThemeMode(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('System'),
                          subtitle: const Text('Follow device theme'),
                          value: 'system',
                        ),
                        RadioListTile<String>(
                          title: const Text('Light'),
                          value: 'light',
                        ),
                        RadioListTile<String>(
                          title: const Text('Dark'),
                          value: 'dark',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Behavior Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.tune, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text('Behavior', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Clipboard Backup'),
                    subtitle: const Text(
                      'Copy original text to clipboard before replacing',
                    ),
                    value: provider.clipboardBackup,
                    onChanged: provider.setClipboardBackup,
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('History Logging'),
                    subtitle: const Text('Save a log of text transformations'),
                    value: provider.historyEnabled,
                    onChanged: provider.setHistoryEnabled,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Language Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Output Language',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Force AI to always respond in a specific language.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownMenu<String>(
                    initialSelection: provider.outputLanguage ?? '',
                    hintText: 'Auto-detect',
                    expandedInsets: EdgeInsets.zero,
                    onSelected: (value) => provider.setOutputLanguage(
                      value == null || value.isEmpty ? null : value,
                    ),
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(
                        value: '',
                        label: 'Auto-detect (no override)',
                      ),
                      ..._languages
                          .where((l) => l != null)
                          .map(
                            (lang) =>
                                DropdownMenuEntry(value: lang!, label: lang),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('About', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('AI Text'),
                    subtitle: const Text('v1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Text(
                    'AI-powered text processing via Android context menu. '
                    'Select text in any app and transform it with Gemini AI.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
