import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/text_action.dart';
import '../providers/app_provider.dart';

class CustomActionSheet extends StatefulWidget {
  final TextAction? editAction;

  const CustomActionSheet({super.key, this.editAction});

  @override
  State<CustomActionSheet> createState() => _CustomActionSheetState();
}

class _CustomActionSheetState extends State<CustomActionSheet> {
  late TextEditingController _nameController;
  late TextEditingController _promptController;
  String _selectedIcon = 'auto_fix_high';
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.editAction != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editAction?.name ?? '',
    );
    _promptController = TextEditingController(
      text: widget.editAction?.systemPrompt ?? '',
    );
    _selectedIcon = widget.editAction?.iconName ?? 'auto_fix_high';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [

                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  isEditing ? 'Edit Action' : 'New Custom Action',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Action Name',
                    hintText: 'e.g., Convert to Bullet Points',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _promptController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'System Prompt',
                    hintText:
                        'e.g., Convert the following text into bullet points...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Prompt is required'
                      : null,
                ),
                const SizedBox(height: 24),

                Text('Icon', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TextAction.iconMap.entries.map((entry) {
                    final isSelected = entry.key == _selectedIcon;
                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: Icon(entry.value, size: 18),
                      label: const SizedBox.shrink(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) {
                        setState(() => _selectedIcon = entry.key);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(isEditing ? 'Save' : 'Create'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final name = _nameController.text.trim();
    final prompt = _promptController.text.trim();

    if (isEditing) {
      provider.editCustomAction(
        actionId: widget.editAction!.id,
        name: name,
        systemPrompt: prompt,
        iconName: _selectedIcon,
      );
    } else {
      provider.addCustomAction(
        name: name,
        systemPrompt: prompt,
        iconName: _selectedIcon,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditing ? 'Action updated' : 'Action created')),
    );
  }
}
