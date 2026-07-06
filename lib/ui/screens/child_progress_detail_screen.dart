import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';

class ChildProgressDetailScreen extends StatelessWidget {
  const ChildProgressDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = ModalRoute.of(context)!.settings.arguments as Child;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final results = state.resultsForChild(child.id);
    final badges = state.badgesForChild(child.id);

    return Scaffold(
      appBar: AppBar(title: Text('${child.name} ${child.avatarEmoji}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t ? 'সম্পন্ন মডিউল' : 'Completed Modules', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (results.isEmpty)
            Text(t ? 'এখনও কোনো কুইজ সম্পন্ন হয়নি।' : 'No quizzes completed yet.', style: const TextStyle(color: Colors.grey))
          else
            for (final r in results)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(_moduleTitleForQuiz(r.quizId, t)),
                  subtitle: Text('${t ? "স্কোর" : "Score"}: ${r.score}% • ${r.stars} ⭐'),
                  trailing: Text('${r.attemptedAt.month}/${r.attemptedAt.day}'),
                ),
              ),
          const SizedBox(height: 20),
          Text(t ? 'অর্জিত ব্যাজ' : 'Badges Earned', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (badges.isEmpty)
            Text(t ? 'এখনও কোনো ব্যাজ অর্জিত হয়নি।' : 'No badges earned yet.', style: const TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final b in badges)
                  Chip(avatar: const Text('🏅'), label: Text(b.name)),
              ],
            ),
        ],
      ),
    );
  }

  String _moduleTitleForQuiz(String quizId, bool bengali) {
    final quiz = MockData.quizzesByModule.values.firstWhere((q) => q.id == quizId);
    final module = MockData.modules.firstWhere((m) => m.id == quiz.moduleId);
    return bengali ? module.titleBn : module.title;
  }
}
