import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/services/mock_data.dart';
import 'package:safezone_ultra/ui/widgets/floating_bubbles.dart';

const Map<HazardCategory, List<Color>> _categoryBackdrop = {
  HazardCategory.fire: [Color(0xFFFFD59E), Color(0xFFFF9E7A)],
  HazardCategory.flood: [Color(0xFFAEE3FA), Color(0xFF6FC3EF)],
  HazardCategory.earthquake: [Color(0xFFE3D4B8), Color(0xFFC7A97C)],
  HazardCategory.stranger: [Color(0xFFFFE9A8), Color(0xFFFFCB6B)],
};

const Map<HazardCategory, Color> _categoryAccent = {
  HazardCategory.fire: Color(0xFFE8734A),
  HazardCategory.flood: Color(0xFF3E8FC7),
  HazardCategory.earthquake: Color(0xFF9C7B4F),
  HazardCategory.stranger: Color(0xFFE0A83A),
};

/// Lightens a color toward white so it reads as a soft page backdrop
/// rather than a saturated block of color.
Color _soften(Color c) => Color.lerp(c, Colors.white, 0.55)!;

const List<Map<String, String>> _encouragements = [
  {
    'en':
        "Good try! That's one way to think about it — take another look and try again.",
    'bn': 'চেষ্টা ভালো ছিল! এটাও একটা ভাবনা — আরেকটু চিন্তা করে আবার বেছে নাও।',
  },
  {
    'en':
        "Nice thinking! Not quite, but you're getting closer — try once more!",
    'bn': 'দারুণ চিন্তা! ঠিক না হলেও কাছাকাছি আছো — আরেকবার চেষ্টা করো!',
  },
  {
    'en':
        "That's a valid guess! Let's brainstorm a bit more before choosing again.",
    'bn': 'এটাও একটা যুক্তিসঙ্গত উত্তর! আরেকটু চিন্তা করে আবার বেছে নাও।',
  },
  {
    'en': "You're learning! Take a breath and think about it once more.",
    'bn': 'তুমি শিখছো! একটু থেমে আবার ভাবো।',
  },
  {
    'en': 'Almost there! Give it one more thought.',
    'bn': 'প্রায় হয়ে গেছে! আরেকবার ভাবো।',
  },
  {
    'en': 'Great effort! Every guess helps you learn — pick again.',
    'bn': 'দারুণ চেষ্টা! প্রতিটি উত্তরই তোমাকে শেখায় — আবার বেছে নাও।',
  },
];

const List<String> _carEmojis = ['🏎️', '🚓', '🚕', '🚙', '🚐', '🚌'];

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  bool _initialized = false;
  late List<bool> _answered;
  late List<bool> _isCorrect;
  late List<Set<int>> _triedWrong;
  bool _showEncouragement = false;
  int _encouragementIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
      final n = quiz.questions.length;
      _answered = List.filled(n, false);
      _isCorrect = List.filled(n, false);
      _triedWrong = List.generate(n, (_) => <int>{});
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final question = quiz.questions[_questionIndex];
    final options = t ? question.optionsBn : question.options;
    final starCount = _isCorrect.where((c) => c).length;
    final category = MockData.modules
        .firstWhere((m) => m.id == quiz.moduleId)
        .category;
    final accent = _categoryAccent[category]!;
    final pageBackground = _categoryBackdrop[category]!
        .map<Color>(_soften)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${quiz.title} (${_questionIndex + 1}/${quiz.questions.length})',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    '$starCount',
                    key: ValueKey(starCount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: pageBackground,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: FloatingBubbles(
              count: 10,
              emojis: ['🎈', '✨', '⭐', '🌟', '🧩'],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_questionIndex + 1) / quiz.questions.length,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            t ? question.questionBn : question.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (int i = 0; i < options.length; i++)
                          _buildOption(
                            context,
                            i,
                            options[i],
                            question,
                            accent,
                          ),
                        if (_showEncouragement) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🌟',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t
                                        ? _encouragements[_encouragementIndex]['bn']!
                                        : _encouragements[_encouragementIndex]['en']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _CarSlider(
                  canNext: _answered[_questionIndex],
                  canPrev: _questionIndex > 0,
                  carEmoji:
                      _carEmojis[(_questionIndex ~/ 3) % _carEmojis.length],
                  onNext: _goNext,
                  onPrev: _goPrev,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    int i,
    String label,
    QuizQuestion question,
    Color accent,
  ) {
    final answered = _answered[_questionIndex];
    final triedWrong = _triedWrong[_questionIndex];
    Color? color;
    if (answered && i == question.correctIndex) {
      color = Colors.green.shade100;
    } else if (triedWrong.contains(i)) {
      color = Colors.amber.shade50;
    }
    final disabled = answered || triedWrong.contains(i);
    final borderColor = triedWrong.contains(i)
        ? Colors.amber.shade300
        : accent.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : () => _selectAnswer(i, question),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (triedWrong.contains(i) &&
                    !(answered && i == question.correctIndex))
                  const Text('🤔', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int i, QuizQuestion question) {
    if (_answered[_questionIndex]) return;

    if (i == question.correctIndex) {
      setState(() {
        _answered[_questionIndex] = true;
        _isCorrect[_questionIndex] = true;
        _showEncouragement = false;
      });
      return;
    }

    setState(() {
      _triedWrong[_questionIndex].add(i);
      if (_triedWrong[_questionIndex].length >= question.options.length - 1) {
        _answered[_questionIndex] = true;
        _showEncouragement = false;
      } else {
        _encouragementIndex = Random().nextInt(_encouragements.length);
        _showEncouragement = true;
      }
    });
  }

  void _goNext() {
    if (!_answered[_questionIndex]) return;
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    if (_questionIndex == quiz.questions.length - 1) {
      final state = context.read<AppState>();
      final child = state.activeChild!;
      final correctCount = _isCorrect.where((c) => c).length;
      state.submitQuizResult(child, quiz, correctCount);
      Navigator.pushReplacementNamed(
        context,
        '/quiz-result',
        arguments: {'quiz': quiz, 'correct': correctCount},
      );
    } else {
      setState(() {
        _questionIndex++;
        _showEncouragement = false;
      });
    }
  }

  void _goPrev() {
    if (_questionIndex == 0) return;
    setState(() {
      _questionIndex--;
      _showEncouragement = false;
    });
  }
}

class _CarSlider extends StatefulWidget {
  final bool canNext;
  final bool canPrev;
  final String carEmoji;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _CarSlider({
    required this.canNext,
    required this.canPrev,
    required this.carEmoji,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<_CarSlider> createState() => _CarSliderState();
}

class _CarSliderState extends State<_CarSlider> {
  static const double _carSize = 60;
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxOffset = (constraints.maxWidth - _carSize) / 2 - 6;
        final dragClamped = _drag.clamp(-maxOffset, maxOffset);
        return Container(
          height: 84,
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: Colors.brown.shade200),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Opacity(
                    opacity: widget.canPrev ? 1 : 0.25,
                    child: const Text('⬅️', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Opacity(
                    opacity: widget.canNext ? 1 : 0.25,
                    child: const Text('➡️', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() => _drag += details.delta.dx);
                },
                onHorizontalDragEnd: (details) {
                  final threshold = maxOffset * 0.5;
                  if (dragClamped > threshold && widget.canNext) {
                    widget.onNext();
                  } else if (dragClamped < -threshold && widget.canPrev) {
                    widget.onPrev();
                  }
                  setState(() => _drag = 0);
                },
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 180),
                  offset: Offset(dragClamped / _carSize, 0),
                  child: Text(
                    widget.carEmoji,
                    style: const TextStyle(fontSize: _carSize),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
