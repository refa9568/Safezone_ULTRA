import '../models/models.dart';

final LessonModule earthquakeModule = const LessonModule(
  id: 'm3',
  title: 'Earthquake Drill',
  titleBn: 'ভূমিকম্প মহড়া',
  category: HazardCategory.earthquake,
  summary: 'Practice Drop, Cover and Hold On during an earthquake.',
  summaryBn: 'ভূমিকম্পের সময় নত হও, ঢেকে রাখো এবং ধরে থাকো অনুশীলন করুন।',
);

const Quiz earthquakeMindGameQuiz = Quiz(
  id: 'q3',
  moduleId: 'm3',
  title: 'Earthquake Safety Mind Game',
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
    QuizQuestion(
      question: 'What is the safest place to stay during shaking?',
      questionBn: 'ঝাঁকুনির সময় সবচেয়ে নিরাপদে কোথায় থাকা উচিত?',
      options: [
        'Near a window',
        'Under a sturdy table',
        'On the stairs',
        'In the elevator',
      ],
      optionsBn: [
        'জানালার কাছে',
        'মজবুত টেবিলের নিচে',
        'সিঁড়ির ওপর',
        'লিফটে',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'After an earthquake, what should you avoid?',
      questionBn: 'ভূমিকম্পের পরে তোমার কী এড়িয়ে চলা উচিত?',
      options: [
        'Checking for cracks',
        'Going near damaged walls',
        'Listening to adults',
        'Moving to a safe open area',
      ],
      optionsBn: [
        'ফাটল পরীক্ষা করা',
        'ক্ষতিগ্রস্ত দেয়ালের কাছে যাওয়া',
        'বড়দের কথা শোনা',
        'নিরাপদ খোলা জায়গায় যাওয়া',
      ],
      correctIndex: 1,
    ),
    QuizQuestion(
      question: 'Which action best protects your head during an earthquake?',
      questionBn: 'ভূমিকম্পের সময় মাথা বাঁচাতে কোনটি সবচেয়ে ভালো?',
      options: [
        'Cover it with your arms and hold on',
        'Look out the window',
        'Run as fast as possible',
        'Stand on a chair',
      ],
      optionsBn: [
        'হাত দিয়ে ঢেকে ধরে থাকা',
        'জানালার বাইরে দেখা',
        'যত দ্রুত সম্ভব দৌড়ানো',
        'চেয়ারের ওপর দাঁড়ানো',
      ],
      correctIndex: 0,
    ),
  ],
);

final Quiz earthquakeQuiz = earthquakeMindGameQuiz;
