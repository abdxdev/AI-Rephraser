import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'notification_service.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String defaultModel = 'gemini-2.5-flash';

  static Future<String> processText({
    required String text,
    required String systemPrompt,
    required String apiKey,
    String? outputLanguage,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/$defaultModel:generateContent?key=$apiKey',
    );

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
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    debugPrint('[GeminiService] Sending POST request to $_baseUrl/$defaultModel...');
    final response = await http
        .post(url, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 45));
    
    debugPrint('[GeminiService] Received response with status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('[GeminiService] Error: No candidates in response');
        throw Exception('No response from AI model');
      }
      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        debugPrint('[GeminiService] Error: Empty parts in response');
        throw Exception('Empty response from AI model');
      }
      
      final resultText = (parts[0]['text'] as String).trim();
      debugPrint('[GeminiService] Successfully parsed response text (length: ${resultText.length})');
      return resultText;
    } else {
      debugPrint('[GeminiService] HTTP Error: ${response.body}');
      
      if (response.statusCode == 429) {
        // Trigger notification for rate limit / quota exceeded
        NotificationService.showApiLimitNotification();
      }
      
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMsg =
          (errorData['error'] as Map<String, dynamic>?)?['message']
              as String? ??
          'API request failed (${response.statusCode})';
      throw Exception(errorMsg);
    }
  }

  static Future<String?> testConnection({required String apiKey}) async {
    try {
      final result = await processText(
        text: 'Hello',
        systemPrompt: 'Reply with exactly: Connection successful',
        apiKey: apiKey,
      );
      if (result.isNotEmpty) return null; // Success
      return 'Empty response from API';
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
