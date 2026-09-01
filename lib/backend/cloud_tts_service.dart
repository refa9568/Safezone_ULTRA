import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:safezone_ultra/backend/cloud_tts_config.dart';

/// Speaks text with Google Cloud Text-to-Speech's neural voices (WaveNet /
/// Neural2), which sound far more human than the on-device TTS engine.
/// Only used when the device is online and a real API key is configured;
/// callers should fall back to on-device TTS when [speak] returns false.
class CloudTtsService {
  final AudioPlayer _player = AudioPlayer();

  // Same text/voice pair is asked for over and over (kids replay lessons),
  // so cache the synthesized audio in memory instead of re-billing/re-fetching.
  final Map<String, Uint8List> _cache = {};

  static const _englishVoice = 'en-US-Neural2-F';
  static const _bengaliVoice = 'bn-IN-Wavenet-A';

  bool get isConfigured =>
      cloudTtsApiKey.isNotEmpty &&
      cloudTtsApiKey != 'PUT_YOUR_CLOUD_TTS_API_KEY_HERE';

  Stream<void> get onComplete => _player.onPlayerComplete;

  /// Returns true if the cloud voice started playing; false if it couldn't
  /// (not configured, offline, or the request failed) so the caller can
  /// fall back to the on-device voice instead.
  Future<bool> speak(String text, {required bool bengali}) async {
    if (!isConfigured) return false;
    final voice = bengali ? _bengaliVoice : _englishVoice;
    final cacheKey = '$voice::$text';

    try {
      var bytes = _cache[cacheKey];
      if (bytes == null) {
        final response = await http
            .post(
              Uri.parse(
                'https://texttospeech.googleapis.com/v1/text:synthesize'
                '?key=$cloudTtsApiKey',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'input': {'text': text},
                'voice': {
                  'languageCode': bengali ? 'bn-IN' : 'en-US',
                  'name': voice,
                },
                'audioConfig': {
                  'audioEncoding': 'MP3',
                  'speakingRate': 0.95,
                },
              }),
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) return false;
        final audioContent =
            jsonDecode(response.body)['audioContent'] as String?;
        if (audioContent == null) return false;
        bytes = base64Decode(audioContent);
        _cache[cacheKey] = bytes;
      }
      await _player.play(BytesSource(bytes));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
