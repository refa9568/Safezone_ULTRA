import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/firestore_repository.dart';

/// Firestore collection: quiz_results/{resultId}
class QuizResultRepository extends FirestoreRepository<QuizResult> {
  QuizResultRepository() : super('quiz_results');

  @override
  QuizResult fromMap(Map<String, dynamic> data, String id) => QuizResult(
    id: id,
    childId: data['childId'] as String,
    quizId: data['quizId'] as String,
    score: data['score'] as int,
    stars: data['stars'] as int,
    attemptedAt: (data['attemptedAt'] as Timestamp).toDate(),
  );

  @override
  Map<String, dynamic> toMap(QuizResult item) => {
    'childId': item.childId,
    'quizId': item.quizId,
    'score': item.score,
    'stars': item.stars,
    'attemptedAt': Timestamp.fromDate(item.attemptedAt),
  };

  /// All quiz results for one child.
  Stream<List<QuizResult>> streamForChild(String childId) =>
      streamWhere('childId', childId);
}
