import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/services/firebase/firestore_repository.dart';

/// Firestore collection: notifications/{notificationId}
class NotificationRepository extends FirestoreRepository<AppNotification> {
  NotificationRepository() : super('notifications');

  @override
  AppNotification fromMap(Map<String, dynamic> data, String id) =>
      AppNotification(
        id: id,
        parentId: data['parentId'] as String,
        childId: data['childId'] as String,
        message: data['message'] as String,
        isRead: data['isRead'] as bool? ?? false,
        sentAt: (data['sentAt'] as Timestamp).toDate(),
      );

  @override
  Map<String, dynamic> toMap(AppNotification item) => {
    'parentId': item.parentId,
    'childId': item.childId,
    'message': item.message,
    'isRead': item.isRead,
    'sentAt': Timestamp.fromDate(item.sentAt),
  };

  /// All notifications for one parent, newest first.
  Stream<List<AppNotification>> streamForParent(String parentId) {
    return collection
        .where('parentId', isEqualTo: parentId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => fromMap(d.data(), d.id)).toList());
  }
}
