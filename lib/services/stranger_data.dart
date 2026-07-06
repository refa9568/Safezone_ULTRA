import '../models/models.dart';

final LessonModule strangerModule = const LessonModule(
  id: 'm4',
  title: 'Stranger Danger',
  titleBn: 'অপরিচিত ব্যক্তি থেকে সাবধানতা',
  category: HazardCategory.stranger,
  summary: 'Learn safe rules for talking to people you don\'t know.',
  summaryBn: 'অপরিচিত মানুষের সাথে কথা বলার নিরাপদ নিয়ম শিখুন।',
);

final Quiz strangerQuiz = const Quiz(
  id: 'q4',
  moduleId: 'm4',
  title: 'Stranger Danger Quiz',
  difficulty: 'Easy',
  questions: [
    QuizQuestion(
      question: 'A stranger offers you candy to go with them. What do you do?',
      questionBn: 'একজন অপরিচিত ব্যক্তি তোমাকে মিষ্টি দিয়ে সাথে যেতে বলে। তুমি কী করবে?',
      options: [
        'Go with them',
        'Say no and tell a trusted adult',
        'Take the candy quietly',
        'Ignore and walk away alone',
      ],
      optionsBn: [
        'তাদের সাথে যাবে',
        'না বলবে এবং বিশ্বস্ত বড়দের জানাবে',
        'চুপচাপ মিষ্টি নেবে',
        'উপেক্ষা করে একা চলে যাবে',
      ],
      correctIndex: 1,
    ),
  ],
);
