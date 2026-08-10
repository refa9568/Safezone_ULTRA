import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/firestore_repository.dart';

/// Firestore collection: children/{childId}
class ChildRepository extends FirestoreRepository<Child> {
  ChildRepository() : super('children');

  @override
  Child fromMap(Map<String, dynamic> data, String id) => Child(
    id: id,
    parentId: data['parentId'] as String,
    name: data['name'] as String,
    age: data['age'] as int,
    avatarEmoji: data['avatarEmoji'] as String,
    photoBase64: data['photoBase64'] as String?,
    language: data['language'] as String? ?? 'en',
    usedMinutesToday: data['usedMinutesToday'] as int? ?? 0,
    screenTimeLimitMinutes: data['screenTimeLimitMinutes'] as int? ?? 60,
  );

  @override
  Map<String, dynamic> toMap(Child item) => {
    'parentId': item.parentId,
    'name': item.name,
    'age': item.age,
    'avatarEmoji': item.avatarEmoji,
    'photoBase64': item.photoBase64,
    'language': item.language,
    'usedMinutesToday': item.usedMinutesToday,
    'screenTimeLimitMinutes': item.screenTimeLimitMinutes,
  };

  /// All children belonging to one parent.
  Stream<List<Child>> streamForParent(String parentId) =>
      streamWhere('parentId', parentId);
}
