import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/services/firebase/firestore_repository.dart';

/// Firestore collection: chat_messages/{messageId}
class ChatMessageRepository extends FirestoreRepository<ChatMessage> {
  ChatMessageRepository() : super('chat_messages');

  @override
  ChatMessage fromMap(Map<String, dynamic> data, String id) => ChatMessage(
    id: id,
    childId: data['childId'] as String,
    prompt: data['prompt'] as String,
    response: data['response'] as String,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    isUser: data['isUser'] as bool? ?? false,
  );

  @override
  Map<String, dynamic> toMap(ChatMessage item) => {
    'childId': item.childId,
    'prompt': item.prompt,
    'response': item.response,
    'createdAt': Timestamp.fromDate(item.createdAt),
    'isUser': item.isUser,
  };

  /// All chat messages for one child, in the order they were sent.
  Stream<List<ChatMessage>> streamForChild(String childId) {
    return collection
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => fromMap(d.data(), d.id)).toList());
  }
}
