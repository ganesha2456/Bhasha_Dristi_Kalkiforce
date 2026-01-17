import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OCRService {
  // ⚠️ Change this IP if backend changes
  static const String baseUrl = "http://10.170.195.28:8000";

  // ✅ Endpoints EXACTLY as backend
  static const String ocrEndpoint = "$baseUrl/ocr";
  static const String textEndpoint = "$baseUrl/text-transliterate";
  static const String voiceEndpoint = "$baseUrl/voice-transliterate";

  // ---------------- LANGUAGE NORMALIZER ----------------
  static String normalizeLanguage(String lang) {
    const mapping = {
      "Hindi": "Devanagari",
      "Hindi (Devanagari)": "Devanagari",
      "English": "Latin",
      "English (Latin)": "Latin",
      "Bengali": "Bengali",
      "Odia": "Odia",
      "Tamil": "Tamil",
      "Telugu": "Telugu",
      "Punjabi": "Gurmukhi",
      "Punjabi (Gurmukhi)": "Gurmukhi",
      "Gujarati": "Gujarati",
      "Kannada": "Kannada",
      "Malayalam": "Malayalam",
    };

    return mapping[lang] ?? lang;
  }

  // ---------------- LANGUAGE JOIN HELPER ----------------
  // ✅ Converts ["Hindi","English"] → "Hindi, English"
  static String joinLanguages(dynamic langs) {
    if (langs is List && langs.isNotEmpty) {
      return langs.join(", ");
    }
    return "Unknown";
  }

  // ================= IMAGE OCR =================
  static Future<Map<String, dynamic>> processImage(
    String filePath,
    String targetLang,
  ) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(ocrEndpoint),
      );

      // Backend expects: target_script
      request.fields["target_script"] = normalizeLanguage(targetLang);

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          filePath,
          filename: "scan.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      print("📩 OCR RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);
      final langs = json["language_per_line"];

      return {
        "extracted_text": json["extracted_text"] ?? "",
        "language_per_line": langs ?? [],
        "language": joinLanguages(langs), // ✅ safe display string
        "target_script": json["target_script"] ?? "",
        "transliterated": json["transliterated"] ?? "",
      };
    } catch (e) {
      print("❌ OCR Error: $e");
      return {"error": e.toString()};
    }
  }

  // ================= TEXT TRANSLITERATION =================
  static Future<Map<String, dynamic>> processText(
    String text,
    String targetLang,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(textEndpoint),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "text": text,
              "target_script": normalizeLanguage(targetLang),
            }),
          )
          .timeout(const Duration(seconds: 30));

      print("📩 TEXT RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return {
        "language": json["language"] ?? "",
        "transliterated": json["transliterated_text"] ??
            json["transliterated"] ??
            "",
      };
    } catch (e) {
      print("❌ Text Error: $e");
      return {"error": e.toString()};
    }
  }

  // ================= VOICE TRANSLITERATION =================
  static Future<Map<String, dynamic>> processVoice(
    String audioPath,
    String targetLang,
  ) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse(voiceEndpoint),
      );

      // ⚠️ Backend expects: target_lang (not target_language)
      request.fields["target_lang"] = normalizeLanguage(targetLang);

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          audioPath,
          filename: "voice.wav",
          contentType: MediaType("audio", "wav"),
        ),
      );

      final streamed =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);

      print("📩 VOICE RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw "Server error ${response.statusCode}: ${response.body}";
      }

      final json = jsonDecode(response.body);

      return {
        "transliterated_text":
            json["transliterated_text"] ?? json["transliterated"] ?? "",
        "target_language": json["target_language"] ?? "",
      };
    } catch (e) {
      print("❌ Voice Error: $e");
      return {"error": e.toString()};
    }
  }
}
