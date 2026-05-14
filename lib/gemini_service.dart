import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static Future<String> getRecommendations({
    required String city,
    required String days,
    required String budget,
  }) async {
    final apiKey = dotenv.env['ROTAM_GEMINI_API_KEY'];

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
    );

    final prompt = '''
Ben bir gezi planlıyorum.
Gitmek istediğim şehir: $city
Kalmayı planladığım gün sayısı: $days
Bütçem: $budget TL

Bu bilgiler ışığında bana bu şehirde gezebileceğim 3 farklı yeri öner. Her bir yer için başlık + kısa açıklama şeklinde öneri ver.
''';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      return "AI önerisi alınamadı: ${response.statusCode}";
    }
  }
}
