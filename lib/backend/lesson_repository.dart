import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/firestore_repository.dart';

/// Firestore collection: lessons/{lessonId}
class LessonRepository extends FirestoreRepository<LessonModule> {
  LessonRepository() : super('lessons');

  @override
  LessonModule fromMap(Map<String, dynamic> data, String id) =>
      LessonModule.fromMap(data, id);

  @override
  Map<String, dynamic> toMap(LessonModule item) => item.toMap();
}
