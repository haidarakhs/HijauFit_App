import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServices {
  // TODO: Pindahkan API key ini ke tempat aman seperti .env (jangan hardcode di produksi!)
  static const String _apiKey = 'AIzaSyCfh2S84ZeB2rtushHR6ANrIMXNPYlDzz8';

  static final _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 1,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 8192,
      responseMimeType: 'text/plain',
    ),
  );

  static Future<Map<String, dynamic>> generateRecipe(List<Map<String, dynamic>> recipes) async {
    final prompt = _buildPrompt(recipes);

    final chat = _model.startChat(history: [
      Content.multi([
        TextPart(
          'Kamu adalah AI ahli makanan. Saat pengguna menyebutkan nama makanan dan harga, buatkan resep dalam format **JSON valid** berikut:\n\n'
          '```json\n'
          '{\n'
          '  "nama_resep": "<nama_resep>",\n'
          '  "ingredients": ["<bahan 1>", "<bahan 2>"],\n'
          '  "steps": ["<langkah 1>", "<langkah 2>"],\n'
          '  "price": "<harga>"\n'
          '}\n'
          '```\n'
          '⚠️ Jangan tambahkan teks apapun selain JSON.',
        ),
      ]),
    ]);

    try {
      final response = await chat.sendMessage(Content.text(prompt));
      final parts = response.candidates.first.content.parts;

      final responseText = parts.isNotEmpty && parts.first is TextPart
          ? (parts.first as TextPart).text
          : '';

      print('[DEBUG] API Response:\n$responseText');

      if (responseText.isEmpty) {
        return {"error": "Gagal menghasilkan resep: Respons kosong dari API"};
      }

      // Ambil bagian JSON yang valid (jika dibungkus dalam ```json ... ```)
      final jsonMatch = RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(responseText);
      final jsonString = jsonMatch != null ? jsonMatch.group(1) : responseText;

      return _validateJson(jsonString!);
    } catch (e) {
      print('[ERROR] Terjadi kesalahan saat generate recipe: $e');
      return {"error": "Terjadi kesalahan: $e"};
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> recipes) {
    return recipes.map((recipe) {
      final nama = recipe['nama_resep'] ?? 'Tidak diketahui';
      final harga = recipe['price'] ?? 'Tidak disebutkan';
      return "Nama resep: $nama, Harga: $harga";
    }).join("\n");
  }

  static Map<String, dynamic> _validateJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr);
    } catch (e) {
      print('[ERROR] Format JSON tidak valid: $e');
      return {"error": "Format JSON tidak valid: $e"};
    }
  }
}
