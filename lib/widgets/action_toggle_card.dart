import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/text_action.dart';
import '../providers/app_provider.dart';

class ActionToggleCard extends StatelessWidget {
  final TextAction action;

  const ActionToggleCard({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: action.isEnabled ? 1 : 0,
      color: action.isEnabled
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: action.isEnabled
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            action.icon,
            size: 20,
            color: action.isEnabled
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          action.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: action.isEnabled
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          action.isBuiltIn ? 'Built-in' : 'Custom',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch.adaptive(
          value: action.isEnabled,
          onChanged: (val) => provider.toggleAction(action.id, val),
        ),
      ),
    );
  }
}
