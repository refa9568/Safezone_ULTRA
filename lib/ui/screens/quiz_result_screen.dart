import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
import '../theme/app_theme.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final quiz = args['quiz'] as Quiz;
    final correct = args['correct'] as int;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final total = quiz.questions.length;
    final score = ((correct / total) * 100).round();
    final newBadge = score == 100;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'ফলাফল' : 'Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(score >= 70 ? '🎉' : '💪', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text('$score%', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                t ? '$correct টি সঠিক $total টির মধ্যে' : '$correct correct out of $total',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  correct,
                  (_) => const Icon(Icons.star_rounded, color: Colors.amber, size: 32),
                ),
              ),
              if (newBadge) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Text(t ? 'নতুন ব্যাজ অর্জিত!' : 'New Badge Unlocked!'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/child')),
                  child: Text(t ? 'হোমে ফিরুন' : 'Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
