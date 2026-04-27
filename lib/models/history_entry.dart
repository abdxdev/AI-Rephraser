class HistoryEntry {
  final String id;
  final String actionName;
  final DateTime timestamp;
  final String originalText;
  final String resultText;

  HistoryEntry({
    required this.id,
    required this.actionName,
    required this.timestamp,
    required this.originalText,
    required this.resultText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'actionName': actionName,
    'timestamp': timestamp.toIso8601String(),
    'originalText': originalText,
    'resultText': resultText,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    actionName: json['actionName'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    originalText: json['originalText'] as String,
    resultText: json['resultText'] as String,
  );

  /// Preview of original text (first 80 chars)
  String get originalPreview => originalText.length > 80
      ? '${originalText.substring(0, 80)}…'
      : originalText;

  /// Preview of result text (first 80 chars)
  String get resultPreview =>
      resultText.length > 80 ? '${resultText.substring(0, 80)}…' : resultText;
}
