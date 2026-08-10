import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/firestore_repository.dart';

/// Firestore collection: quizzes/{quizId}
class QuizRepository extends FirestoreRepository<Quiz> {
  QuizRepository() : super('quizzes');

  @override
  Quiz fromMap(Map<String, dynamic> data, String id) => Quiz.fromMap(data, id);

  @override
  Map<String, dynamic> toMap(Quiz item) => item.toMap();
}
