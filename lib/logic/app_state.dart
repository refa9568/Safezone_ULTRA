import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  bool bengali = false;

  final Parent parent = Parent(
    id: 'p1',
    name: 'Rahim Uddin',
    email: 'parent@example.com',
    screenTimeLimitMinutes: 45,
    emergencyPhone: '+8801700000000',
  );

  final List<Child> children = [
    Child(id: 'c1', parentId: 'p1', name: 'Adiba', age: 8, avatarEmoji: '🦊'),
    Child(id: 'c2', parentId: 'p1', name: 'Rafi', age: 6, avatarEmoji: '🐼'),
  ];

  Child? activeChild;
  bool parentMode = false;

  final List<QuizResult> quizResults = [];
  final List<EarnedBadge> badges = [];
  final List<ChatMessage> chatMessages = [];
  final List<AppNotification> notifications = [];

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

  Child addChildProfile({
    required String name,
    required int age,
    required String sex,
  }) {
    final child = Child(
      id: 'c${children.length + 1}',
      parentId: parent.id,
      name: name,
      age: age,
      avatarEmoji: avatarForSex(sex),
    );
    children.add(child);
    notifyListeners();
    return child;
  }

  void signInParent() {
    parentMode = true;
    activeChild = null;
    notifyListeners();
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
    notifications.insert(
      0,
      AppNotification(
        id: 'n${notifications.length + 1}',
        parentId: parent.id,
        childId: child.id,
        message: '${child.name} just opened SafeZone Ultra.',
        sentAt: DateTime.now(),
      ),
    );
  }

  int minutesRemaining(Child child) {
    final remaining = parent.screenTimeLimitMinutes - child.usedMinutesToday;
    return remaining < 0 ? 0 : remaining;
  }

  bool isLocked(Child child) => minutesRemaining(child) <= 0;

  void addUsageMinutes(Child child, int minutes) {
    child.usedMinutesToday += minutes;
    if (child.usedMinutesToday >= parent.screenTimeLimitMinutes) {
      notifications.insert(
        0,
        AppNotification(
          id: 'n${notifications.length + 1}',
          parentId: parent.id,
          childId: child.id,
          message: '${child.name} has reached the daily screen time limit.',
          sentAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void setScreenTimeLimit(int minutes) {
    parent.screenTimeLimitMinutes = minutes;
    notifyListeners();
  }

  void setEmergencyPhone(String phone) {
    parent.emergencyPhone = phone;
    notifyListeners();
  }

  bool verifyParentPin(String pin) => pin == parent.parentPin;

  void setParentPin(String pin) {
    parent.parentPin = pin;
    notifyListeners();
  }

  List<QuizResult> resultsForChild(String childId) =>
      quizResults.where((r) => r.childId == childId).toList();

  List<EarnedBadge> badgesForChild(String childId) =>
      badges.where((b) => b.childId == childId).toList();

  void submitQuizResult(Child child, Quiz quiz, int correctAnswers) {
    final stars = correctAnswers;
    final score = ((correctAnswers / quiz.questions.length) * 100).round();
    quizResults.add(
      QuizResult(
        id: 'r${quizResults.length + 1}',
        childId: child.id,
        quizId: quiz.id,
        score: score,
        stars: stars,
        attemptedAt: DateTime.now(),
      ),
    );
    if (score == 100) {
      final module = MockData.modules.firstWhere((m) => m.id == quiz.moduleId);
      final alreadyEarned = badges.any(
        (b) => b.childId == child.id && b.name == '${module.title} Master',
      );
      if (!alreadyEarned) {
        badges.add(
          EarnedBadge(
            id: 'b${badges.length + 1}',
            childId: child.id,
            name: '${module.title} Master',
            emoji: '🏅',
            earnedAt: DateTime.now(),
          ),
        );
      }
    }
    notifyListeners();
  }

  bool completeMindGame(Child child) {
    final alreadyEarned = badges.any(
      (b) => b.childId == child.id && b.name == 'Memory Master',
    );
    if (!alreadyEarned) {
      badges.add(
        EarnedBadge(
          id: 'b${badges.length + 1}',
          childId: child.id,
          name: 'Memory Master',
          emoji: '🧠',
          earnedAt: DateTime.now(),
        ),
      );
      notifyListeners();
    }
    return !alreadyEarned;
  }

  void askBuddy(Child child, String prompt) {
    final reply = MockData.chatbotReply(prompt);
    chatMessages.add(
      ChatMessage(
        id: 'msg${chatMessages.length + 1}',
        childId: child.id,
        prompt: prompt,
        response: '',
        createdAt: DateTime.now(),
        isUser: true,
      ),
    );
    chatMessages.add(
      ChatMessage(
        id: 'msg${chatMessages.length + 1}',
        childId: child.id,
        prompt: prompt,
        response: reply,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void triggerSos(Child child) {
    notifications.insert(
      0,
      AppNotification(
        id: 'n${notifications.length + 1}',
        parentId: parent.id,
        childId: child.id,
        message: '🆘 SOS! ${child.name} needs help right now!',
        sentAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final n = notifications.firstWhere((n) => n.id == id);
    n.isRead = true;
    notifyListeners();
  }
}
