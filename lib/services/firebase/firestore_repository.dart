import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for a Firestore-backed collection of [T].
///
/// Each concrete repository points at one top-level collection and knows
/// how to convert between a Firestore document and the model class.
abstract class FirestoreRepository<T> {
  FirestoreRepository(String collectionPath)
    : collection = FirebaseFirestore.instance.collection(collectionPath);

  final CollectionReference<Map<String, dynamic>> collection;

  T fromMap(Map<String, dynamic> data, String id);
  Map<String, dynamic> toMap(T item);

  /// Creates the document if [id] is new, or overwrites it if it exists.
  Future<void> set(String id, T item) => collection.doc(id).set(toMap(item));

  /// Adds a new document with an auto-generated id and returns that id.
  Future<String> add(T item) async {
    final ref = await collection.add(toMap(item));
    return ref.id;
  }

  Future<void> updateFields(String id, Map<String, dynamic> changes) =>
      collection.doc(id).update(changes);

  Future<void> delete(String id) => collection.doc(id).delete();

  Future<T?> getById(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return fromMap(doc.data()!, doc.id);
  }

  Stream<List<T>> streamAll() {
    return collection.snapshots().map(
      (snap) => snap.docs.map((d) => fromMap(d.data(), d.id)).toList(),
    );
  }

  Stream<List<T>> streamWhere(String field, dynamic isEqualTo) {
    return collection
        .where(field, isEqualTo: isEqualTo)
        .snapshots()
        .map((snap) => snap.docs.map((d) => fromMap(d.data(), d.id)).toList());
  }
}
