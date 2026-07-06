import '../models/models.dart';

final LessonModule earthquakeModule = const LessonModule(
  id: 'm3',
  title: 'Earthquake Drill',
  titleBn: 'ভূমিকম্প মহড়া',
  category: HazardCategory.earthquake,
  summary: 'Practice Drop, Cover and Hold On during an earthquake.',
  summaryBn: 'ভূমিকম্পের সময় নত হও, ঢেকে রাখো এবং ধরে থাকো অনুশীলন করুন।',
);

final Quiz earthquakeQuiz = const Quiz(
  id: 'q3',
  moduleId: 'm3',
  title: 'Earthquake Safety Quiz',
  difficulty: 'Medium',
  questions: [
    QuizQuestion(
      question: 'What should you do during an earthquake indoors?',
      questionBn: 'ঘরের ভেতরে ভূমিকম্পের সময় তোমার কী করা উচিত?',
      options: [
        'Run outside immediately',
        'Drop, Cover and Hold On',
        'Stand near a window',
        'Use the elevator',
      ],
      optionsBn: [
        'সাথে সাথে বাইরে দৌড়াও',
        'নত হও, ঢেকে রাখো এবং ধরে থাকো',
        'জানালার কাছে দাঁড়াও',
        'লিফট ব্যবহার করো',
      ],
      correctIndex: 1,
    ),
  ],
);
