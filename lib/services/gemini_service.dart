import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Process text using the Gemini API.
  ///
  /// Sends [text] with a [systemPrompt] to the specified [model].
  /// If [outputLanguage] is set, appends a language instruction.
  /// Returns the processed text or throws on error.
  static Future<String> processText({
    required String text,
    required String systemPrompt,
    required String apiKey,
    required String model,
    String? outputLanguage,
  }) async {
    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');

    // Build the effective system prompt
    String effectivePrompt = systemPrompt;
    if (outputLanguage != null && outputLanguage.isNotEmpty) {
      effectivePrompt +=
          '\n\nIMPORTANT: Always respond in $outputLanguage regardless of the input language.';
    }

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': effectivePrompt},
        ],
      },
      'contents': [
        {
          'parts': [
            {'text': text},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2048},
    });

    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response from AI model');
      }
      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Empty response from AI model');
      }
      return (parts[0]['text'] as String).trim();
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMsg =
          (errorData['error'] as Map<String, dynamic>?)?['message']
              as String? ??
          'API request failed (${response.statusCode})';
      throw Exception(errorMsg);
    }
  }

  /// Test connection to the Gemini API.
  /// Returns null on success, or an error message on failure.
  static Future<String?> testConnection({
    required String apiKey,
    required String model,
  }) async {
    try {
      final result = await processText(
        text: 'Hello',
        systemPrompt: 'Reply with exactly: Connection successful',
        apiKey: apiKey,
        model: model,
      );
      if (result.isNotEmpty) return null; // Success
      return 'Empty response from API';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Available Gemini models
  static const List<String> availableModels = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];
}
