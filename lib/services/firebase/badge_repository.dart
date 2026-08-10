import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/services/firebase/firestore_repository.dart';

/// Firestore collection: badges/{badgeId}
class BadgeRepository extends FirestoreRepository<EarnedBadge> {
  BadgeRepository() : super('badges');

  @override
  EarnedBadge fromMap(Map<String, dynamic> data, String id) => EarnedBadge(
    id: id,
    childId: data['childId'] as String,
    name: data['name'] as String,
    emoji: data['emoji'] as String,
    earnedAt: (data['earnedAt'] as Timestamp).toDate(),
  );

  @override
  Map<String, dynamic> toMap(EarnedBadge item) => {
    'childId': item.childId,
    'name': item.name,
    'emoji': item.emoji,
    'earnedAt': Timestamp.fromDate(item.earnedAt),
  };

  /// All badges earned by one child.
  Stream<List<EarnedBadge>> streamForChild(String childId) =>
      streamWhere('childId', childId);
}
