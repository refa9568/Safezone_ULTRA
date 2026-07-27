import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
import '../../services/mock_data.dart';
import '../theme/app_theme.dart';

const Map<HazardCategory, List<Color>> _categoryBackdrop = {
  HazardCategory.fire: [Color(0xFFFFD59E), Color(0xFFFF9E7A)],
  HazardCategory.flood: [Color(0xFFAEE3FA), Color(0xFF6FC3EF)],
  HazardCategory.earthquake: [Color(0xFFE3D4B8), Color(0xFFC7A97C)],
  HazardCategory.stranger: [Color(0xFFFFE9A8), Color(0xFFFFCB6B)],
};

/// Lightens a color toward white so it reads as a soft page backdrop
/// rather than a saturated block of color.
Color _soften(Color c) => Color.lerp(c, Colors.white, 0.55)!;

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
    final category = MockData.modules
        .firstWhere((m) => m.id == quiz.moduleId)
        .category;
    final pageBackground = _categoryBackdrop[category]!
        .map<Color>(_soften)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'ফলাফল' : 'Quiz Result')),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: pageBackground,
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          score >= 70 ? '🎉' : '💪',
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$score%',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t
                              ? '$correct টি সঠিক $total টির মধ্যে'
                              : '$correct correct out of $total',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            correct,
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 32,
                            ),
                          ),
                        ),
                        if (newBadge) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.secondary,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🏅',
                                  style: TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  t
                                      ? 'নতুন ব্যাজ অর্জিত!'
                                      : 'New Badge Unlocked!',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.popUntil(
                              context,
                              ModalRoute.withName('/child'),
                            ),
                            child: Text(t ? 'হোমে ফিরুন' : 'Back to Home'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
