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
  String emergencyPhone;
  String parentPin;
  bool parentPinSet;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    this.emergencyPhone = '',
    this.parentPin = '1234',
    this.parentPinSet = false,
  });
}

class Child {
  final String id;
  final String parentId;
  String name;
  int age;
  String avatarEmoji;
  String? photoBase64;
  String language; // 'en' or 'bn'
  String sex; // 'Male', 'Female', or 'Other'
  int usedMinutesToday;
  int screenTimeLimitMinutes;
  String lastUsageDate; // 'yyyy-MM-dd', local to the device
  bool scheduleEnabled;
  int scheduleStartMinutes; // minutes since midnight, e.g. 17:00 = 1020
  int scheduleEndMinutes;

  Child({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    required this.avatarEmoji,
    this.photoBase64,
    this.language = 'en',
    this.sex = 'Other',
    this.usedMinutesToday = 0,
    this.screenTimeLimitMinutes = 60,
    this.lastUsageDate = '',
    this.scheduleEnabled = false,
    this.scheduleStartMinutes = 0,
    this.scheduleEndMinutes = 1439,
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
  final List<String> stepImages;
  final List<String> stepVideos;

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
    this.stepImages = const [],
    this.stepVideos = const [],
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'titleBn': titleBn,
    'category': category.name,
    'summary': summary,
    'summaryBn': summaryBn,
    'scenario': scenario,
    'scenarioBn': scenarioBn,
    'steps': steps,
    'stepsBn': stepsBn,
    'stepIcons': stepIcons,
    'stepImages': stepImages,
    'stepVideos': stepVideos,
  };

  factory LessonModule.fromMap(Map<String, dynamic> data, String id) {
    List<String> strList(String key) =>
        (data[key] as List?)?.map((e) => e.toString()).toList() ?? const [];
    return LessonModule(
      id: id,
      title: data['title'] as String,
      titleBn: data['titleBn'] as String,
      category: HazardCategory.values.byName(data['category'] as String),
      summary: data['summary'] as String,
      summaryBn: data['summaryBn'] as String,
      scenario: data['scenario'] as String? ?? '',
      scenarioBn: data['scenarioBn'] as String? ?? '',
      steps: strList('steps'),
      stepsBn: strList('stepsBn'),
      stepIcons: strList('stepIcons'),
      stepImages: strList('stepImages'),
      stepVideos: strList('stepVideos'),
    );
  }

  /// Path (relative to the assets/ root, ready for audioplayers'
  /// AssetSource) of the pre-recorded narration for step [index], generated
  /// once via tool/export_lesson_audio_manifest.dart — see that file to
  /// regenerate after editing lesson text.
  String stepAudioAsset(int index, {required bool bengali}) =>
      'lessons/${category.name}/audio/step_${index + 1}_${bengali ? 'bn' : 'en'}.mp3';

  /// Path (relative to the assets/ root) of the pre-recorded narration for
  /// this module's summary.
  String summaryAudioAsset({required bool bengali}) =>
      'lessons/${category.name}/audio/summary_${bengali ? 'bn' : 'en'}.mp3';
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

  Map<String, dynamic> toMap() => {
    'question': question,
    'questionBn': questionBn,
    'options': options,
    'optionsBn': optionsBn,
    'correctIndex': correctIndex,
  };

  factory QuizQuestion.fromMap(Map<String, dynamic> data) => QuizQuestion(
    question: data['question'] as String,
    questionBn: data['questionBn'] as String,
    options: (data['options'] as List).map((e) => e.toString()).toList(),
    optionsBn: (data['optionsBn'] as List).map((e) => e.toString()).toList(),
    correctIndex: data['correctIndex'] as int,
  );
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

  Map<String, dynamic> toMap() => {
    'moduleId': moduleId,
    'title': title,
    'difficulty': difficulty,
    'questions': questions.map((q) => q.toMap()).toList(),
  };

  factory Quiz.fromMap(Map<String, dynamic> data, String id) => Quiz(
    id: id,
    moduleId: data['moduleId'] as String,
    title: data['title'] as String,
    difficulty: data['difficulty'] as String,
    questions: (data['questions'] as List)
        .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
        .toList(),
  );
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
