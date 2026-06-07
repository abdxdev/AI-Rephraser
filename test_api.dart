import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  const apiKey = 'AIzaSyDh9ySixwAnd2l9rBayJSouN1P1Gv9HdrE';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey');
  
  final body = jsonEncode({
    'contents': [
      {'parts': [{'text': 'Hello'}]}
    ]
  });

  final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
  print(response.statusCode);
  print(response.body);
}