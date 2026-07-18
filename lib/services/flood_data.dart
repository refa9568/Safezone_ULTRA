import '../models/models.dart';

final LessonModule floodModule = const LessonModule(
  id: 'm2',
  title: 'Flood Preparedness',
  titleBn: 'বন্যা প্রস্তুতি',
  category: HazardCategory.flood,
  summary: 'Understand how to stay safe before and during a flood.',
  summaryBn: 'বন্যার আগে ও সময়ে নিরাপদ থাকার উপায় জানুন।',
);

final Quiz floodQuiz = const Quiz(
  id: 'q2',
  moduleId: 'm2',
  title: 'Flood Safety Quiz',
  difficulty: 'Easy',
  questions: [
    QuizQuestion(
      question: 'Where should you go during a flood warning?',
      questionBn: 'বন্যার সতর্কতার সময় তোমার কোথায় যাওয়া উচিত?',
      options: ['Higher ground', 'Basement', 'Riverside', 'Stay outside'],
      optionsBn: ['উঁচু জায়গায়', 'বেসমেন্টে', 'নদীর ধারে', 'বাইরে থাকো'],
      correctIndex: 0,
    ),
  ],
);
