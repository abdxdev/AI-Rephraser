import 'package:flutter/material.dart';

class TextAction {
  final String id;
  final String name;
  final String systemPrompt;
  final bool isBuiltIn;
  bool isEnabled;
  int order;
  String? modelOverride;
  String? customPromptOverride;
  String iconName;

  TextAction({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.isBuiltIn,
    this.isEnabled = true,
    this.order = 0,
    this.modelOverride,
    this.customPromptOverride,
    this.iconName = 'auto_fix_high',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'systemPrompt': systemPrompt,
    'isBuiltIn': isBuiltIn,
    'isEnabled': isEnabled,
    'order': order,
    'modelOverride': modelOverride,
    'customPromptOverride': customPromptOverride,
    'iconName': iconName,
  };

  factory TextAction.fromJson(Map<String, dynamic> json) => TextAction(
    id: json['id'] as String,
    name: json['name'] as String,
    systemPrompt: json['systemPrompt'] as String,
    isBuiltIn: json['isBuiltIn'] as bool,
    isEnabled: (json['isEnabled'] as bool?) ?? true,
    order: (json['order'] as int?) ?? 0,
    modelOverride: json['modelOverride'] as String?,
    customPromptOverride: json['customPromptOverride'] as String?,
    iconName: (json['iconName'] as String?) ?? 'auto_fix_high',
  );

  TextAction copyWith({
    String? id,
    String? name,
    String? systemPrompt,
    bool? isBuiltIn,
    bool? isEnabled,
    int? order,
    String? modelOverride,
    String? customPromptOverride,
    String? iconName,
  }) {
    return TextAction(
      id: id ?? this.id,
      name: name ?? this.name,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      modelOverride: modelOverride ?? this.modelOverride,
      customPromptOverride: customPromptOverride ?? this.customPromptOverride,
      iconName: iconName ?? this.iconName,
    );
  }

  /// Get the effective prompt (custom override or default)
  String get effectivePrompt => customPromptOverride ?? systemPrompt;

  /// Resolve icon from name
  IconData get icon => iconMap[iconName] ?? Icons.auto_fix_high;

  static List<TextAction> get defaultActions => [
    TextAction(
      id: 'rephrase',
      name: 'Rephrase',
      systemPrompt:
          'Rephrase the following text while preserving its original meaning. Return only the rephrased text, nothing else.',
      isBuiltIn: true,
      order: 0,
      iconName: 'edit',
    ),
    TextAction(
      id: 'fix_grammar',
      name: 'Fix Grammar',
      systemPrompt:
          'Fix all grammar, punctuation, and spelling errors in the following text. Return only the corrected text, nothing else.',
      isBuiltIn: true,
      order: 1,
      iconName: 'spellcheck',
    ),
    TextAction(
      id: 'shorten',
      name: 'Shorten',
      systemPrompt:
          'Make the following text more concise while preserving the key meaning. Return only the shortened text, nothing else.',
      isBuiltIn: true,
      order: 2,
      iconName: 'compress',
    ),
    TextAction(
      id: 'expand',
      name: 'Expand',
      systemPrompt:
          'Expand the following text with more detail and elaboration while maintaining the original meaning. Return only the expanded text, nothing else.',
      isBuiltIn: true,
      order: 3,
      iconName: 'expand',
    ),
    TextAction(
      id: 'formal',
      name: 'Formal Tone',
      systemPrompt:
          'Rewrite the following text in a professional, formal tone. Return only the rewritten text, nothing else.',
      isBuiltIn: true,
      order: 4,
      iconName: 'business_center',
    ),
    TextAction(
      id: 'casual',
      name: 'Casual Tone',
      systemPrompt:
          'Rewrite the following text in a relaxed, conversational tone. Return only the rewritten text, nothing else.',
      isBuiltIn: true,
      order: 5,
      iconName: 'emoji_emotions',
    ),
    TextAction(
      id: 'summarize',
      name: 'Summarize',
      systemPrompt:
          'Summarize the following text into a concise summary. Return only the summary, nothing else.',
      isBuiltIn: true,
      order: 6,
      iconName: 'summarize',
    ),
  ];

  static const Map<String, IconData> iconMap = {
    'edit': Icons.edit,
    'spellcheck': Icons.spellcheck,
    'compress': Icons.compress,
    'expand': Icons.expand,
    'business_center': Icons.business_center,
    'emoji_emotions': Icons.emoji_emotions,
    'summarize': Icons.summarize,
    'auto_fix_high': Icons.auto_fix_high,
    'text_fields': Icons.text_fields,
    'translate': Icons.translate,
    'format_list_bulleted': Icons.format_list_bulleted,
    'code': Icons.code,
    'short_text': Icons.short_text,
    'notes': Icons.notes,
    'psychology': Icons.psychology,
    'lightbulb': Icons.lightbulb,
    'question_answer': Icons.question_answer,
    'format_quote': Icons.format_quote,
    'title': Icons.title,
    'abc': Icons.abc,
    'checklist': Icons.checklist,
    'bolt': Icons.bolt,
    'star': Icons.star,
    'favorite': Icons.favorite,
  };
}
