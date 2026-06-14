import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static Future<String> getRecommendations({
    required String city,
    required String district,
    required String days,
    required String stayType,
  }) async {
    final apiKey = dotenv.env['ROTAM_GEMINI_API_KEY'];

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
    );

    final prompt =
        "Türkiye'de $city şehrinin $district ilçesine bir seyahat planlıyorum. $days gün kalacağım ve konaklama tercihim kesinlikle '$stayType' olacak. "
        "Bana bu seyahat için kullanıcının kalacağı $days güne göre gün gün planlanmış (Örn: 1. Gün, 2. Gün...) en popüler ve nokta atışı aktiviteleri veya lokasyonları başlık ve kısa açıklama olarak döndür. "
        "Yanıt formatı her gün için tam olarak aşağıdaki gibi olmalıdır:\n\n"
        "1. Gün: [Aktivite/Başlık]\n"
        "[Kısa Açıklama]\n\n"
        "2. Gün: [Aktivite/Başlık]\n"
        "[Kısa Açıklama]\n\n"
        "... Lütfen başka hiçbir açıklayıcı giriş veya çıkış metni ekleme, sadece yukarıdaki şablona sadık kalarak gün gün önerileri listele.";

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
