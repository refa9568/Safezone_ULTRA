import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:safezone_ultra/backend/gemini_config.dart';

/// Talks to Gemini for the in-app "Safety Buddy" chat. Only used when the
/// device is online; offline questions fall back to lesson content instead
/// (see MockData.chatbotReply).
class GeminiService {
  GenerativeModel? _model;

  GenerativeModel? _getModel(bool bengali) {
    if (geminiApiKey.isEmpty || geminiApiKey == 'PUT_YOUR_GEMINI_API_KEY_HERE') {
      return null;
    }
    _model ??= GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: geminiApiKey,
      systemInstruction: Content.system(
        'You are Safety Buddy, a friendly chatbot inside a child-safety '
        'education app called SafeZone Ultra. You ONLY talk about child '
        'safety: fire safety, flood safety, earthquake safety, and '
        'stranger danger. Answer in short, simple, encouraging sentences '
        'a 6-12 year old can understand (max 3-4 sentences). If asked '
        'about anything unrelated to safety, gently steer the '
        'conversation back to safety topics instead of answering it. '
        'Never share personal contact info, addresses, or unsafe advice.',
      ),
      // gemini-flash-latest is a "thinking" model that spends part of the
      // token budget on internal reasoning before the visible answer, so
      // this needs real headroom or replies get cut off mid-sentence.
      generationConfig: GenerationConfig(maxOutputTokens: 1024),
    );
    return _model;
  }

  /// Returns Gemini's reply, or null if the call failed (caller should
  /// fall back to the offline lesson-based answer).
  Future<String?> ask(String prompt, {required bool bengali}) async {
    final model = _getModel(bengali);
    if (model == null) return null;
    try {
      final languageNote = bengali
          ? 'Respond in Bengali (বাংলা).'
          : 'Respond in English.';
      final response = await model
          .generateContent([
            Content.text('$languageNote\n\nChild asks: $prompt'),
          ])
          .timeout(const Duration(seconds: 25));
      final text = response.text?.trim();
      return (text == null || text.isEmpty) ? null : text;
    } catch (_) {
      return null;
    }
  }
}
