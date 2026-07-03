enum HazardCategory { fire, flood, earthquake, stranger }

extension HazardCategoryX on HazardCategory {
  String label(bool bengali) {
    switch (this) {
      case HazardCategory.fire:
        return bengali ? 'আগুন' : 'Fire';
      case HazardCategory.flood:
        return bengali ? 'বন্যা' : 'Flood';
      case HazardCategory.earthquake:
        return bengali ? 'ভূমিকম্প' : 'Earthquake';
      case HazardCategory.stranger:
        return bengali ? 'অপরিচিত ব্যক্তি' : 'Stranger Danger';
    }
  }
}

class Parent {
  final String id;
  final String name;
  final String email;
  int screenTimeLimitMinutes;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    this.screenTimeLimitMinutes = 60,
  });
}

class Child {
  final String id;
  final String parentId;
  String name;
  int age;
  String avatarEmoji;
  String language; // 'en' or 'bn'
  int usedMinutesToday;

  Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.avatarEmoji,
    this.language = 'en',
    this.usedMinutesToday = 0,
  });
}

class LessonModule {
  final String id;
  final String title;
  final String titleBn;
  final HazardCategory category;
  final String summary;
  final String summaryBn;
  final String scenario;
  final String scenarioBn;
  final List<String> steps;
  final List<String> stepsBn;
  final List<String> stepIcons;

  const LessonModule({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.category,
    required this.summary,
    required this.summaryBn,
    this.scenario = '',
    this.scenarioBn = '',
    this.steps = const [],
    this.stepsBn = const [],
    this.stepIcons = const [],
  });
}

class QuizQuestion {
  final String question;
  final String questionBn;
  final List<String> options;
  final List<String> optionsBn;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.questionBn,
    required this.options,
    required this.optionsBn,
    required this.correctIndex,
  });
}

class Quiz {
  final String id;
  final String moduleId;
  final String title;
  final String difficulty;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.difficulty,
    required this.questions,
  });
}

class QuizResult {
  final String id;
  final String childId;
  final String quizId;
  final int score;
  final int stars;
  final DateTime attemptedAt;

  QuizResult({
    required this.id,
    required this.childId,
    required this.quizId,
    required this.score,
    required this.stars,
    required this.attemptedAt,
  });
}

class EarnedBadge {
  final String id;
  final String childId;
  final String name;
  final String emoji;
  final DateTime earnedAt;

  EarnedBadge({
    required this.id,
    required this.childId,
    required this.name,
    required this.emoji,
    required this.earnedAt,
  });
}

class ChatMessage {
  final String id;
  final String childId;
  final String prompt;
  final String response;
  final DateTime createdAt;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.childId,
    required this.prompt,
    required this.response,
    required this.createdAt,
    this.isUser = false,
  });
}

class AppNotification {
  final String id;
  final String parentId;
  final String childId;
  final String message;
  bool isRead;
  final DateTime sentAt;

  AppNotification({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.message,
    this.isRead = false,
    required this.sentAt,
  });
}
