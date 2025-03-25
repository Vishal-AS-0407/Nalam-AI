import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String apiUrl = "https://api.sarvam.ai/translate";
  static const String apiKey = "44de06bc-2820-4709-9f01-b60acff28d0f";

  static Map<String, String> languageCodes = {
    "hi": "hi-IN",
    "bn": "bn-IN",
    "gu": "gu-IN",
    "kn": "kn-IN",
    "ml": "ml-IN",
    "mr": "mr-IN",
    "od": "od-IN",
    "pa": "pa-IN",
    "ta": "ta-IN",
    "te": "te-IN"
  };

  static Future<String?> translateText(String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'api-subscription-key': apiKey,
        },
        body: jsonEncode({
          "input": text,
          "source_language_code": "en-IN",
          "target_language_code": languageCodes[targetLang] ?? "hi-IN",
          "mode": "formal",
          "speaker_gender": "Female",
          "enable_preprocessing": false
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'];
      }
      return null;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }
}
