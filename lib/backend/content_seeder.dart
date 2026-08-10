import 'package:safezone_ultra/backend/lesson_repository.dart';
import 'package:safezone_ultra/backend/quiz_repository.dart';
import 'package:safezone_ultra/services/mock_data.dart';

/// Uploads the lesson/quiz content bundled in lib/data (via [MockData]) to
/// Firestore the first time the app ever runs against this project, then
/// always loads [MockData.modules]/[MockData.quizzesByModule] from whatever
/// is actually stored in Firestore, so the app serves real database content
/// instead of the hardcoded copy.
class ContentSeeder {
  final LessonRepository _lessonRepo = LessonRepository();
  final QuizRepository _quizRepo = QuizRepository();

  Future<void> seedAndLoad() async {
    final existingLessons = await _lessonRepo.streamAll().first;

    if (existingLessons.isEmpty) {
      for (final module in MockData.modules) {
        await _lessonRepo.set(module.id, module);
      }
      for (final quiz in MockData.quizzesByModule.values) {
        await _quizRepo.set(quiz.id, quiz);
      }
    }

    final lessons = await _lessonRepo.streamAll().first;
    final quizzes = await _quizRepo.streamAll().first;

    if (lessons.isNotEmpty) {
      MockData.modules = lessons;
    }
    if (quizzes.isNotEmpty) {
      MockData.quizzesByModule = {for (final q in quizzes) q.moduleId: q};
    }
  }
}
