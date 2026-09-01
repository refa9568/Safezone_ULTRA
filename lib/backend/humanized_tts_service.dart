import 'package:flutter_tts/flutter_tts.dart';
import 'package:safezone_ultra/backend/cloud_tts_service.dart';

/// Drop-in narration voice for lesson steps and Safety Buddy replies.
/// Prefers Google Cloud TTS's natural neural voice; silently falls back to
/// the on-device voice when offline or unconfigured, so narration never
/// just breaks.
class HumanizedTts {
  HumanizedTts() {
    _cloud.onComplete.listen((_) => _onComplete?.call());
    _device.setSpeechRate(0.42);
    _device.setPitch(1.05);
    _device.setCompletionHandler(() => _onComplete?.call());
    _device.setCancelHandler(() => _onComplete?.call());
  }

  final CloudTtsService _cloud = CloudTtsService();
  final FlutterTts _device = FlutterTts();
  void Function()? _onComplete;

  void setOnComplete(void Function() callback) => _onComplete = callback;

  Future<void> speak(String text, {required bool bengali}) async {
    final startedOnCloud = await _cloud.speak(text, bengali: bengali);
    if (startedOnCloud) return;
    await _device.setLanguage(bengali ? 'bn-BD' : 'en-US');
    await _device.speak(text);
  }

  Future<void> stop() async {
    await _cloud.stop();
    await _device.stop();
  }

  void dispose() => _cloud.dispose();
}
