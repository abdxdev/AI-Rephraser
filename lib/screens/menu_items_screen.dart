import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/text_action.dart';
import '../providers/app_provider.dart';

class MenuItemsScreen extends StatelessWidget {
  const MenuItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allActions = [...provider.builtInActions, ...provider.customActions];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Menu Items')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Toggle the actions that appear in the text selection context menu. '
                            'Tap an action to customize its prompt.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...allActions.map((action) => _ActionTile(action: action)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final TextAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            secondary: Container(
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
            title: Text(action.name),
            subtitle: Text(
              action.isBuiltIn ? 'Built-in' : 'Custom',
              style: theme.textTheme.bodySmall,
            ),
            value: action.isEnabled,
            onChanged: (val) => provider.toggleAction(action.id, val),
          ),
          ExpansionTile(
            title: Text(
              'Customize',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            children: [
              _PromptEditor(action: action),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptEditor extends StatefulWidget {
  final TextAction action;

  const _PromptEditor({required this.action});

  @override
  State<_PromptEditor> createState() => _PromptEditorState();
}

class _PromptEditorState extends State<_PromptEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.action.customPromptOverride ?? widget.action.systemPrompt,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Prompt', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter custom system prompt...',
            suffixIcon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  tooltip: 'Save prompt',
                  onPressed: () {
                    final text = _controller.text.trim();
                    provider.updateActionPrompt(
                      widget.action.id,
                      text == widget.action.systemPrompt ? null : text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Prompt saved')),
                    );
                  },
                ),
                if (widget.action.customPromptOverride != null)
                  IconButton(
                    icon: const Icon(Icons.restore, size: 20),
                    tooltip: 'Reset to default',
                    onPressed: () {
                      _controller.text = widget.action.systemPrompt;
                      provider.updateActionPrompt(widget.action.id, null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prompt reset')),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
