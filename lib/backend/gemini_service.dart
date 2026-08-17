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
      // gemini-flash-latest currently aliases to a newer preview model that
      // was returning frequent 503 "high demand" errors. gemini-flash-lite
      // is the stable, lightweight variant - it spends far less of its
      // budget on internal "thinking" (fitting for short kid-friendly
      // answers) and is far less prone to overload.
      model: 'gemini-flash-lite-latest',
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
      generationConfig: GenerationConfig(maxOutputTokens: 512),
    );
    return _model;
  }

  /// Returns Gemini's reply, or null if the call failed after retries
  /// (caller should fall back to the offline lesson-based answer).
  Future<String?> ask(String prompt, {required bool bengali}) async {
    final model = _getModel(bengali);
    if (model == null) return null;
    final languageNote = bengali
        ? 'Respond in Bengali (বাংলা).'
        : 'Respond in English.';

    // Gemini's "high demand" 503s and stray connection resets are usually
    // transient, so a couple of quick retries recover most of them instead
    // of silently dropping to the offline canned reply.
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await model
            .generateContent([
              Content.text('$languageNote\n\nChild asks: $prompt'),
            ])
            .timeout(const Duration(seconds: 20));
        final text = response.text?.trim();
        return (text == null || text.isEmpty) ? null : text;
      } catch (e) {
        final retryable =
            e is GenerativeAIException && e.message.contains('503') ||
            e.toString().contains('Software caused connection abort');
        if (!retryable || attempt == maxAttempts) return null;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    return null;
  }
}
