import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// A stable id for this device's parent account, generated once and
/// persisted locally. Used as the Firestore document id for the Parent
/// (and as the parentId on every Child/Notification), so the same
/// household's data is found again on every app launch without needing
/// a full login system yet.
class LocalIdentity {
  static const _key = 'parent_id';

  static Future<String> parentId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null) return existing;
    final id = _generateId();
    await prefs.setString(_key, id);
    return id;
  }

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
