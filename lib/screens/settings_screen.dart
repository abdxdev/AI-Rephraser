import 'package:flutter/material.dart';

import 'api_settings_screen.dart';
import 'menu_items_screen.dart';
import 'preferences_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                _SettingsTile(
                  icon: Icons.key,
                  title: 'API Settings',
                  subtitle: 'Gemini API key and fixed model',
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.onPrimaryContainer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApiSettingsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.menu,
                  title: 'Menu Items',
                  subtitle: 'Toggle & customize context menu actions',
                  color: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MenuItemsScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.tune,
                  title: 'Preferences',
                  subtitle: 'Theme, language, clipboard backup',
                  color: colorScheme.tertiaryContainer,
                  iconColor: colorScheme.onTertiaryContainer,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PreferencesScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
