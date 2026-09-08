import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/firestore_repository.dart';

/// Firestore collection: parents/{parentId}
class ParentRepository extends FirestoreRepository<Parent> {
  ParentRepository() : super('parents');

  @override
  Parent fromMap(Map<String, dynamic> data, String id) => Parent(
    id: id,
    name: data['name'] as String,
    email: data['email'] as String,
    emergencyPhone: data['emergencyPhone'] as String? ?? '',
    parentPin: data['parentPin'] as String? ?? '',
    parentPinSet: data['parentPinSet'] as bool? ?? false,
  );

  @override
  Map<String, dynamic> toMap(Parent item) => {
    'name': item.name,
    'email': item.email,
    'emergencyPhone': item.emergencyPhone,
    'parentPin': item.parentPin,
    'parentPinSet': item.parentPinSet,
  };
}
