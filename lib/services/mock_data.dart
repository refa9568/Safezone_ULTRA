import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/data/earthquake_data.dart';
import 'package:safezone_ultra/data/fire_data.dart';
import 'package:safezone_ultra/data/flood_data.dart';
import 'package:safezone_ultra/data/stranger_data.dart';

class MockData {
  /// Default/seed content, also used as an offline fallback. Once
  /// [ContentSeeder] has synced with Firestore, these are overwritten with
  /// the data actually stored there — see lib/backend/content_seeder.dart.
  static List<LessonModule> modules = [
    fireModule,
    floodModule,
    earthquakeModule,
    strangerModule,
  ];

  static Map<String, Quiz> quizzesByModule = {
    fireModule.id: fireQuiz,
    floodModule.id: floodQuiz,
    earthquakeModule.id: earthquakeQuiz,
    strangerModule.id: strangerQuiz,
  };

  static const Map<HazardCategory, List<String>> _categoryKeywords = {
    HazardCategory.fire: ['fire', 'burn', 'smoke', 'আগুন', 'পুড়ে'],
    HazardCategory.flood: ['flood', 'water', 'বন্যা', 'পানি'],
    HazardCategory.earthquake: ['earthquake', 'shake', 'ভূমিকম্প', 'কম্পন'],
    HazardCategory.stranger: [
      'stranger',
      'unknown person',
      'অপরিচিত',
      'অজানা',
    ],
  };

  /// Offline fallback for the Safety Buddy chat: answers from the actual
  /// lesson content (title/summary/first step) instead of Gemini.
  static String chatbotReply(String prompt, {bool bengali = false}) {
    final lower = prompt.toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      if (entry.value.any((k) => lower.contains(k))) {
        final module = modules.firstWhere(
          (m) => m.category == entry.key,
          orElse: () => modules.first,
        );
        final summary = bengali ? module.summaryBn : module.summary;
        final steps = bengali ? module.stepsBn : module.steps;
        final firstStep = steps.isNotEmpty ? steps.first : null;
        if (firstStep == null) return summary;
        return bengali
            ? '$summary\n\nপ্রথম ধাপ: $firstStep'
            : '$summary\n\nFirst step: $firstStep';
      }
    }
    return bengali
        ? 'দারুণ প্রশ্ন! সবসময় শান্ত থাকো, আর অনিরাপদ মনে হলে বিশ্বস্ত কোনো বড়কে বলো।'
        : "That's a great question! Always remember to stay calm and tell a trusted adult if you feel unsafe.";
  }
}
