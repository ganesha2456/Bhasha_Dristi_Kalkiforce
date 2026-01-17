import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OCRService {
  // ⚠️ Change IP if needed
  static const String baseUrl = "http://10.170.195.103:8000";

  static const String ocrEndpoint = "$baseUrl/ocr";
  static const String textEndpoint = "$baseUrl/text_transliterate";
  static const String voiceEndpoint = "$baseUrl/voice-transliterate";

  // ---------------- LANGUAGE NORMALIZER ----------------
  static String normalizeLanguage(String lang) {
    const mapping = {
      "Hindi/Devanagari": "Devanagari",
      "English": "Latin",
      "Bengali": "Bengali",
      "Odia": "Odia",
      "Tamil": "Tamil",
      "Telugu": "Telugu",
      "Punjabi": "Punjabi",
      "Gujarati": "Gujarati",
      "Kannada": "Kannada",
      "Malayalam": "Malayalam",
    };

    return mapping[lang] ?? lang;
  }

  // ---------------- IMAGE OCR ----------------
  static Future<Map<String, dynamic>> processImage(
      String filePath, String targetLang) async {
    try {
      final request = http.MultipartRequest("POST", Uri.parse(ocrEndpoint));

      // Python expects: target_script
      request.fields["target_script"] = normalizeLanguage(targetLang);

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          filePath,
          filename: "scan.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📩 OCR SERVER RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return {
        "extracted_text": json["extracted_text"] ?? "",
        "language": json["language"] ?? "",
        "target_script": json["target_script"] ?? "",
        "transliterated": json["transliterated"] ?? "",
      };
    } catch (e) {
      print("❌ OCR Error: $e");
      return {"error": e.toString()};
    }
  }

  // ---------------- TEXT TRANSLITERATION ----------------
  static Future<Map<String, dynamic>> processText(
      String text, String targetLang) async {
    try {
      final response = await http.post(
        Uri.parse(textEndpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": text,
          "target_script": normalizeLanguage(targetLang),
        }),
      );

      print("📩 TEXT SERVER RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return {
        "language": json["language"] ?? "",
        "target_script": json["target_script"] ?? "",
        "transliterated": json["transliterated_text"] ?? "",
      };
    } catch (e) {
      print("❌ Text Transliteration Error: $e");
      return {"error": e.toString()};
    }
  }

  // ---------------- VOICE TRANSLITERATION ----------------
  static Future<Map<String, dynamic>> processVoice(
      String audioPath, String targetLang) async {
    try {
      final request =
          http.MultipartRequest("POST", Uri.parse(voiceEndpoint));

      request.fields["target_lang"] = normalizeLanguage(targetLang);

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          audioPath,
          filename: "voice.wav",
          contentType: MediaType("audio", "wav"),
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📩 VOICE SERVER RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return {
        "transliterated": json["transliterated_text"] ?? "",
        "target_language": json["target_language"] ?? "",
      };
    } catch (e) {
      print("❌ Voice Transliteration Error: $e");
      return {"error": e.toString()};
    }
  }
}
