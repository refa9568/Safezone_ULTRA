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

const List<String> _neutralEmojis = ['🏎️', '🚓', '🚕', '🚙', '🚐', '🚌'];
const List<String> _maleEmojis = ['🏎️', '🚓', '🚑', '🚒', '🚕', '🚙', '🚐', '🚌'];
const List<String> _femaleEmojis = ['🪆', '👗', '🎀', '🦄', '👑', '🩰', '💃', '🧸'];

List<String> _carEmojisForSex(String? sex) {
  switch (sex?.toLowerCase()) {
    case 'male':
      return _maleEmojis;
    case 'female':
      return _femaleEmojis;
    default:
      return _neutralEmojis;
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

const int _maxAttempts = 3;

class _QuizScreenState extends State<QuizScreen> {
  late List<int> _queue;
  int _queuePos = 0;
  bool _initialized = false;
  late List<bool> _answered;
  late List<bool> _isCorrect;
  late List<int> _attempt;
  late List<int?> _wrongSelected;
  late List<List<int>> _optionOrder;
  bool _showEncouragement = false;
  int _encouragementIndex = 0;
  bool _celebrating = false;
  int _celebrationKey = 0;
  final GlobalKey<_CarSliderState> _carSliderKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
      final n = quiz.questions.length;
      _queue = List.generate(n, (i) => i)..shuffle(Random());
      _answered = List.filled(n, false);
      _isCorrect = List.filled(n, false);
      _attempt = List.filled(n, 1);
      _wrongSelected = List<int?>.filled(n, null);
      _optionOrder = List.generate(
        n,
        (i) => _shuffledOrder(quiz.questions[i].options.length, null),
      );
      _initialized = true;

      final appState = context.read<AppState>();
      final childId = appState.activeChild?.id;
      if (childId != null) {
        final saved = appState.quizProgressFor(childId, quiz.id);
        if (saved != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _offerResume(childId, quiz, saved);
          });
        }
      }
    }
  }

  /// Shown once, on entry, when this child left this exact quiz unfinished
  /// last time - lets them pick up where they stopped instead of always
  /// being forced back to question one.
  void _offerResume(String childId, Quiz quiz, QuizProgress saved) {
    final t = context.read<AppState>().bengali;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t ? 'আগের কুইজ চালিয়ে যাবে?' : 'Resume your quiz?'),
        content: Text(
          t
              ? 'তুমি আগে এই কুইজটা অসম্পূর্ণ রেখে বের হয়ে গিয়েছিলে। আগের জায়গা থেকে চালিয়ে যাবে, নাকি নতুন করে শুরু করবে?'
              : "You left this quiz unfinished last time. Continue where you left off, or start over?",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AppState>().clearQuizProgress(childId, quiz.id);
            },
            child: Text(t ? 'নতুন শুরু' : 'Start New'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _queue = List.of(saved.queue);
                _queuePos = saved.queuePos;
                _answered = List.of(saved.answered);
                _isCorrect = List.of(saved.isCorrect);
                _attempt = List.of(saved.attempt);
                _wrongSelected = List.of(saved.wrongSelected);
                _optionOrder = saved.optionOrder
                    .map((o) => List<int>.of(o))
                    .toList();
              });
            },
            child: Text(t ? 'চালিয়ে যাও' : 'Continue'),
          ),
        ],
      ),
    );
  }

  /// Saves the current in-progress state so it can be offered back if the
  /// child leaves before finishing this quiz.
  void _persistProgress(Quiz quiz) {
    final appState = context.read<AppState>();
    final childId = appState.activeChild?.id;
    if (childId == null) return;
    appState.saveQuizProgress(
      childId,
      quiz.id,
      QuizProgress(
        queue: List.of(_queue),
        queuePos: _queuePos,
        answered: List.of(_answered),
        isCorrect: List.of(_isCorrect),
        attempt: List.of(_attempt),
        wrongSelected: List.of(_wrongSelected),
        optionOrder: _optionOrder.map((o) => List<int>.of(o)).toList(),
      ),
    );
  }

  List<int> _shuffledOrder(int length, List<int>? avoid) {
    final rnd = Random();
    var order = List.generate(length, (i) => i);
    var tries = 0;
    do {
      order = List.generate(length, (i) => i)..shuffle(rnd);
      tries++;
    } while (avoid != null && _sameOrder(order, avoid) && tries < 5);
    return order;
  }

  bool _sameOrder(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final qIdx = _queue[_queuePos];
    final question = quiz.questions[qIdx];
    final options = t ? question.optionsBn : question.options;
    final order = _optionOrder[qIdx];
    final starCount = _isCorrect.where((c) => c).length;
    final carEmojis = _carEmojisForSex(state.activeChild?.sex);
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
          '${quiz.title} (${_queuePos + 1}/${quiz.questions.length})',
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
                  value: (_queuePos + 1) / quiz.questions.length,
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
                        for (int origIdx in order)
                          _buildOption(
                            context,
                            qIdx,
                            origIdx,
                            options[origIdx],
                            question,
                            accent,
                          ),
                        if (_wrongSelected[qIdx] != null &&
                            !_answered[qIdx]) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _tryAgain,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    t ? 'আবার চেষ্টা করো' : 'Try Again',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _skip,
                                  icon: const Icon(Icons.skip_next_rounded),
                                  label: Text(t ? 'বাদ দাও' : 'Skip'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                Padding(
                  // Lift the Previous/Next slider clear of the phone's
                  // on-screen navigation bar/gesture area, which otherwise
                  // overlaps taps near the bottom edge.
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: _CarSlider(
                    key: _carSliderKey,
                    canNext: _answered[qIdx],
                    canPrev: _queuePos > 0,
                    carEmoji: carEmojis[_queuePos % carEmojis.length],
                    onNext: _goNext,
                    onPrev: _goPrev,
                  ),
                ),
              ],
            ),
          ),
          if (_celebrating)
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: IgnorePointer(
                child: Center(
                  child: _CelebrationPopup(key: ValueKey(_celebrationKey)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    int qIdx,
    int origIdx,
    String label,
    QuizQuestion question,
    Color accent,
  ) {
    final answered = _answered[qIdx];
    final wrongSelected = _wrongSelected[qIdx];
    Color? color;
    if (answered && origIdx == question.correctIndex) {
      color = Colors.green.shade100;
    } else if (wrongSelected == origIdx) {
      color = Colors.amber.shade50;
    }
    final disabled = answered || wrongSelected != null;
    final borderColor = wrongSelected == origIdx
        ? Colors.amber.shade300
        : accent.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : () => _selectAnswer(qIdx, origIdx, question),
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
                if (wrongSelected == origIdx &&
                    !(answered && origIdx == question.correctIndex))
                  const Text('🤔', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int qIdx, int origIdx, QuizQuestion question) {
    if (_answered[qIdx] || _wrongSelected[qIdx] != null) return;
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;

    if (origIdx == question.correctIndex) {
      setState(() {
        _answered[qIdx] = true;
        _isCorrect[qIdx] = true;
        _showEncouragement = false;
        _celebrating = true;
        _celebrationKey++;
      });
      _persistProgress(quiz);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _celebrating = false);
      });
      _carSliderKey.currentState?.autoRun();
      return;
    }

    setState(() {
      _wrongSelected[qIdx] = origIdx;
      if (_attempt[qIdx] >= _maxAttempts) {
        // Out of attempts: reveal the correct answer, no more retries.
        _answered[qIdx] = true;
        _showEncouragement = false;
      } else {
        _encouragementIndex = Random().nextInt(_encouragements.length);
        _showEncouragement = true;
      }
    });
    _persistProgress(quiz);
  }

  void _tryAgain() {
    final qIdx = _queue[_queuePos];
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    final optionCount = quiz.questions[qIdx].options.length;
    setState(() {
      _attempt[qIdx]++;
      _optionOrder[qIdx] = _shuffledOrder(optionCount, _optionOrder[qIdx]);
      _wrongSelected[qIdx] = null;
      _showEncouragement = false;
    });
    _persistProgress(quiz);
  }

  void _skip() {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    setState(() {
      final current = _queue.removeAt(_queuePos);
      _queue.add(current);
      // Skipped questions come back fresh, as if seen for the first time.
      _attempt[current] = 1;
      _wrongSelected[current] = null;
      _optionOrder[current] = _shuffledOrder(
        quiz.questions[current].options.length,
        _optionOrder[current],
      );
      _showEncouragement = false;
    });
    _persistProgress(quiz);
  }

  void _goNext() {
    final qIdx = _queue[_queuePos];
    if (!_answered[qIdx]) return;
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    if (_queuePos == _queue.length - 1) {
      final state = context.read<AppState>();
      final child = state.activeChild!;
      final correctCount = _isCorrect.where((c) => c).length;
      state.submitQuizResult(child, quiz, correctCount);
      state.clearQuizProgress(child.id, quiz.id);
      Navigator.pushReplacementNamed(
        context,
        '/quiz-result',
        arguments: {'quiz': quiz, 'correct': correctCount},
      );
    } else {
      setState(() {
        _queuePos++;
        _showEncouragement = false;
      });
      _persistProgress(quiz);
    }
  }

  void _goPrev() {
    if (_queuePos == 0) return;
    setState(() {
      _queuePos--;
      _showEncouragement = false;
    });
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    _persistProgress(quiz);
  }
}

class _CarSlider extends StatefulWidget {
  final bool canNext;
  final bool canPrev;
  final String carEmoji;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _CarSlider({
    super.key,
    required this.canNext,
    required this.canPrev,
    required this.carEmoji,
    required this.onNext,
    required this.onPrev,
  });

  @override
  State<_CarSlider> createState() => _CarSliderState();
}

class _CarSliderState extends State<_CarSlider>
    with SingleTickerProviderStateMixin {
  static const double _carSize = 60;
  double _drag = 0;
  double _lastMaxOffset = 0;
  late final AnimationController _autoController;

  @override
  void initState() {
    super.initState();
    _autoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
      setState(() => _drag = _autoController.value * _lastMaxOffset);
    });
    _autoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onNext();
        _autoController.value = 0;
        setState(() => _drag = 0);
      }
    });
  }

  void autoRun() {
    if (_lastMaxOffset > 0) {
      _autoController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _autoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxOffset = (constraints.maxWidth - _carSize) / 2 - 6;
        _lastMaxOffset = maxOffset;
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

class _CelebrationPopup extends StatefulWidget {
  const _CelebrationPopup({super.key});

  @override
  State<_CelebrationPopup> createState() => _CelebrationPopupState();
}

class _CelebrationPopupState extends State<_CelebrationPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rise;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _rise = Tween<double>(begin: 40, end: -30).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _rise.value),
          child: child,
        ),
      ),
      child: const Text('🎉', style: TextStyle(fontSize: 64)),
    );
  }
}
