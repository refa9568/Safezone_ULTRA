import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/data/earthquake_data.dart';
import 'package:safezone_ultra/data/fire_data.dart';
import 'package:safezone_ultra/data/flood_data.dart';
import 'package:safezone_ultra/data/stranger_data.dart';

class MockData {
  static final List<LessonModule> modules = [
    fireModule,
    floodModule,
    earthquakeModule,
    strangerModule,
  ];

  static final Map<String, Quiz> quizzesByModule = {
    fireModule.id: fireQuiz,
    floodModule.id: floodQuiz,
    earthquakeModule.id: earthquakeQuiz,
    strangerModule.id: strangerQuiz,
  };

  static const Map<String, String> chatbotAnswers = {
    'fire':
        'If you see fire, stay low, cover your mouth, and get out fast! Never hide from firefighters.',
    'flood':
        'During a flood, move to higher ground and avoid walking through moving water.',
    'earthquake': 'Remember: Drop, Cover, and Hold On! Stay away from windows.',
    'stranger':
        'Never go anywhere with someone you don\'t know, even if they seem nice. Always tell a trusted adult.',
  };

  static String chatbotReply(String prompt) {
    final lower = prompt.toLowerCase();
    for (final key in chatbotAnswers.keys) {
      if (lower.contains(key)) return chatbotAnswers[key]!;
    }
    return "That's a great question! Always remember to stay calm and tell a trusted adult if you feel unsafe.";
  }
}
