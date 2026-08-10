import 'package:flutter/material.dart';
import 'package:safezone_ultra/services/mock_data.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/backend/parent_repository.dart';
import 'package:safezone_ultra/backend/child_repository.dart';
import 'package:safezone_ultra/backend/quiz_result_repository.dart';
import 'package:safezone_ultra/backend/badge_repository.dart';
import 'package:safezone_ultra/backend/chat_message_repository.dart';
import 'package:safezone_ultra/backend/notification_repository.dart';

class AppState extends ChangeNotifier {
  bool bengali = false;

  /// True until [initForUser] has loaded this parent's real data from
  /// Firestore. Also true before any user has signed in.
  bool loading = true;

  final ParentRepository _parentRepo = ParentRepository();
  final ChildRepository _childRepo = ChildRepository();
  final QuizResultRepository _quizResultRepo = QuizResultRepository();
  final BadgeRepository _badgeRepo = BadgeRepository();
  final ChatMessageRepository _chatMessageRepo = ChatMessageRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();

  Parent parent = Parent(id: '', name: 'Parent', email: '');

  List<Child> children = [];
  Child? activeChild;
  bool parentMode = false;

  List<QuizResult> quizResults = [];
  List<EarnedBadge> badges = [];
  List<ChatMessage> chatMessages = [];
  List<AppNotification> notifications = [];

  /// Loads the signed-in parent's data from Firestore, keyed by their
  /// Firebase Auth [uid]. Creates the Parent document on first sign-in
  /// (using [name]/[email] if given — e.g. right after registration).
  /// Every mutating method below updates local state immediately (so the UI
  /// never waits on the network) and persists the change to Firestore in
  /// the background.
  Future<void> initForUser(String uid, {String? name, String? email}) async {
    loading = true;
    notifyListeners();

    final existingParent = await _parentRepo.getById(uid);
    parent =
        existingParent ??
        Parent(id: uid, name: name ?? 'Parent', email: email ?? '');
    if (existingParent == null) {
      await _parentRepo.set(uid, parent);
    }

    children = await _childRepo.streamForParent(parent.id).first;
    notifications = await _notificationRepo.streamForParent(parent.id).first;

    final childIds = children.map((c) => c.id).toList();
    quizResults = await _quizResultRepo
        .streamWhereIn('childId', childIds)
        .first;
    badges = await _badgeRepo.streamWhereIn('childId', childIds).first;
    chatMessages = await _chatMessageRepo
        .streamWhereIn('childId', childIds)
        .first;
    chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    loading = false;
    notifyListeners();
  }

  /// Clears cached data on sign-out so a different account signing in on
  /// this device never sees the previous parent's data.
  void reset() {
    parent = Parent(id: '', name: 'Parent', email: '');
    children = [];
    activeChild = null;
    parentMode = false;
    quizResults = [];
    badges = [];
    chatMessages = [];
    notifications = [];
    loading = true;
    notifyListeners();
  }

  /// Permanently deletes every Firestore document for this parent and all
  /// their children (quiz results, badges, chat messages, notifications,
  /// the children themselves, then the parent doc). Pair with
  /// AuthService.deleteAccount() to fully remove a user - this only clears
  /// Firestore, not the Firebase Auth account itself.
  Future<void> deleteAllData() async {
    for (final child in List<Child>.from(children)) {
      for (final r in quizResults.where((r) => r.childId == child.id)) {
        await _quizResultRepo.delete(r.id);
      }
      for (final b in badges.where((b) => b.childId == child.id)) {
        await _badgeRepo.delete(b.id);
      }
      for (final m in chatMessages.where((m) => m.childId == child.id)) {
        await _chatMessageRepo.delete(m.id);
      }
      await _childRepo.delete(child.id);
    }
    for (final n in List<AppNotification>.from(notifications)) {
      await _notificationRepo.delete(n.id);
    }
    await _parentRepo.delete(parent.id);
    reset();
  }

  String _tempId(String prefix) =>
      '$prefix${DateTime.now().microsecondsSinceEpoch}';

  String avatarForSex(String sex) {
    switch (sex.toLowerCase()) {
      case 'male':
        return '🦁';
      case 'other':
        return '🌟';
      default:
        return '🦊';
    }
  }

  void addChildProfile({
    required String name,
    required int age,
    required String sex,
    int screenTimeLimitMinutes = 60,
  }) {
    final tempId = _tempId('c');
    final child = Child(
      id: tempId,
      parentId: parent.id,
      name: name,
      age: age,
      avatarEmoji: avatarForSex(sex),
      screenTimeLimitMinutes: screenTimeLimitMinutes,
    );
    children.add(child);
    notifyListeners();
    _childRepo
        .add(child)
        .then((firestoreId) {
          final idx = children.indexWhere((c) => c.id == tempId);
          if (idx == -1) return;
          children[idx] = Child(
            id: firestoreId,
            parentId: child.parentId,
            name: child.name,
            age: child.age,
            avatarEmoji: child.avatarEmoji,
            language: child.language,
            usedMinutesToday: child.usedMinutesToday,
            screenTimeLimitMinutes: child.screenTimeLimitMinutes,
          );
          notifyListeners();
        })
        .catchError((_) {});
  }

  void removeChildProfile(String childId) {
    final resultIds = quizResults
        .where((r) => r.childId == childId)
        .map((r) => r.id)
        .toList();
    final badgeIds = badges
        .where((b) => b.childId == childId)
        .map((b) => b.id)
        .toList();
    final chatIds = chatMessages
        .where((m) => m.childId == childId)
        .map((m) => m.id)
        .toList();
    final notifIds = notifications
        .where((n) => n.childId == childId)
        .map((n) => n.id)
        .toList();

    children.removeWhere((c) => c.id == childId);
    quizResults.removeWhere((r) => r.childId == childId);
    badges.removeWhere((b) => b.childId == childId);
    chatMessages.removeWhere((m) => m.childId == childId);
    notifications.removeWhere((n) => n.childId == childId);
    if (activeChild?.id == childId) {
      activeChild = null;
    }
    notifyListeners();

    _childRepo.delete(childId).catchError((_) {});
    for (final id in resultIds) {
      _quizResultRepo.delete(id).catchError((_) {});
    }
    for (final id in badgeIds) {
      _badgeRepo.delete(id).catchError((_) {});
    }
    for (final id in chatIds) {
      _chatMessageRepo.delete(id).catchError((_) {});
    }
    for (final id in notifIds) {
      _notificationRepo.delete(id).catchError((_) {});
    }
  }

  void toggleLanguage() {
    bengali = !bengali;
    notifyListeners();
  }

  void selectChild(Child child) {
    activeChild = child;
    parentMode = false;
    _pushLaunchNotification(child);
    notifyListeners();
  }

  void enterParentMode() {
    parentMode = true;
    activeChild = null;
    notifyListeners();
  }

  void _pushLaunchNotification(Child child) {
    _addNotification(
      childId: child.id,
      message: '${child.name} just opened SafeZone Ultra.',
    );
  }

  void _addNotification({required String childId, required String message}) {
    final tempId = _tempId('n');
    final notification = AppNotification(
      id: tempId,
      parentId: parent.id,
      childId: childId,
      message: message,
      sentAt: DateTime.now(),
    );
    notifications.insert(0, notification);
    notifyListeners();
    _notificationRepo
        .add(notification)
        .then((firestoreId) {
          final idx = notifications.indexWhere((n) => n.id == tempId);
          if (idx == -1) return;
          notifications[idx] = AppNotification(
            id: firestoreId,
            parentId: notification.parentId,
            childId: notification.childId,
            message: notification.message,
            isRead: notification.isRead,
            sentAt: notification.sentAt,
          );
          notifyListeners();
        })
        .catchError((_) {});
  }

  int minutesRemaining(Child child) {
    final remaining = child.screenTimeLimitMinutes - child.usedMinutesToday;
    return remaining < 0 ? 0 : remaining;
  }

  bool isLocked(Child child) => minutesRemaining(child) <= 0;

  void addUsageMinutes(Child child, int minutes) {
    child.usedMinutesToday += minutes;
    notifyListeners();
    _childRepo
        .updateFields(child.id, {'usedMinutesToday': child.usedMinutesToday})
        .catchError((_) {});
    if (child.usedMinutesToday >= child.screenTimeLimitMinutes) {
      _addNotification(
        childId: child.id,
        message: '${child.name} has reached the daily screen time limit.',
      );
    }
  }

  void setScreenTimeLimitForChild(Child child, int minutes) {
    child.screenTimeLimitMinutes = minutes;
    notifyListeners();
    _childRepo
        .updateFields(child.id, {'screenTimeLimitMinutes': minutes})
        .catchError((_) {});
  }

  void setEmergencyPhone(String phone) {
    parent.emergencyPhone = phone;
    notifyListeners();
    _parentRepo
        .updateFields(parent.id, {'emergencyPhone': phone})
        .catchError((_) {});
  }

  bool verifyParentPin(String pin) => pin == parent.parentPin;

  void setParentPin(String pin) {
    parent.parentPin = pin;
    notifyListeners();
    _parentRepo.updateFields(parent.id, {'parentPin': pin}).catchError((_) {});
  }

  List<QuizResult> resultsForChild(String childId) =>
      quizResults.where((r) => r.childId == childId).toList();

  List<EarnedBadge> badgesForChild(String childId) =>
      badges.where((b) => b.childId == childId).toList();

  void submitQuizResult(Child child, Quiz quiz, int correctAnswers) {
    final stars = correctAnswers;
    final score = ((correctAnswers / quiz.questions.length) * 100).round();
    final result = QuizResult(
      id: _tempId('r'),
      childId: child.id,
      quizId: quiz.id,
      score: score,
      stars: stars,
      attemptedAt: DateTime.now(),
    );
    quizResults.add(result);
    _quizResultRepo.add(result).catchError((_) => '');

    if (score == 100) {
      final module = MockData.modules.firstWhere((m) => m.id == quiz.moduleId);
      final alreadyEarned = badges.any(
        (b) => b.childId == child.id && b.name == '${module.title} Master',
      );
      if (!alreadyEarned) {
        final badge = EarnedBadge(
          id: _tempId('b'),
          childId: child.id,
          name: '${module.title} Master',
          emoji: '🏅',
          earnedAt: DateTime.now(),
        );
        badges.add(badge);
        _badgeRepo.add(badge).catchError((_) => '');
      }
    }
    notifyListeners();
  }

  bool completeMindGame(Child child) {
    final alreadyEarned = badges.any(
      (b) => b.childId == child.id && b.name == 'Memory Master',
    );
    if (!alreadyEarned) {
      final badge = EarnedBadge(
        id: _tempId('b'),
        childId: child.id,
        name: 'Memory Master',
        emoji: '🧠',
        earnedAt: DateTime.now(),
      );
      badges.add(badge);
      _badgeRepo.add(badge).catchError((_) => '');
      notifyListeners();
    }
    return !alreadyEarned;
  }

  bool completeMazeGame(Child child) {
    final alreadyEarned = badges.any(
      (b) => b.childId == child.id && b.name == 'Maze Master',
    );
    if (!alreadyEarned) {
      final badge = EarnedBadge(
        id: _tempId('b'),
        childId: child.id,
        name: 'Maze Master',
        emoji: '🧩',
        earnedAt: DateTime.now(),
      );
      badges.add(badge);
      _badgeRepo.add(badge).catchError((_) => '');
      notifyListeners();
    }
    return !alreadyEarned;
  }

  void askBuddy(Child child, String prompt) {
    final reply = MockData.chatbotReply(prompt);
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: _tempId('msgu'),
      childId: child.id,
      prompt: prompt,
      response: '',
      createdAt: now,
      isUser: true,
    );
    final botMsg = ChatMessage(
      id: _tempId('msgb'),
      childId: child.id,
      prompt: prompt,
      response: reply,
      createdAt: now.add(const Duration(milliseconds: 1)),
    );
    chatMessages.add(userMsg);
    chatMessages.add(botMsg);
    notifyListeners();
    _chatMessageRepo.add(userMsg).catchError((_) => '');
    _chatMessageRepo.add(botMsg).catchError((_) => '');
  }

  void triggerSos(Child child) {
    _addNotification(
      childId: child.id,
      message: '🆘 SOS! ${child.name} needs help right now!',
    );
  }

  void markNotificationRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id);
    n.isRead = true;
    notifyListeners();
    _notificationRepo.updateFields(id, {'isRead': true}).catchError((_) {});
  }
}
