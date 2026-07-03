import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final question = quiz.questions[_questionIndex];
    final options = t ? question.optionsBn : question.options;

    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} (${_questionIndex + 1}/${quiz.questions.length})'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_questionIndex + 1) / quiz.questions.length),
            const SizedBox(height: 24),
            Text(
              t ? question.questionBn : question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < options.length; i++) _buildOption(context, i, options[i], question),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _next,
                child: Text(
                  _questionIndex == quiz.questions.length - 1
                      ? (t ? 'ফলাফল দেখুন' : 'See Results')
                      : (t ? 'পরবর্তী' : 'Next'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, int i, String label, QuizQuestion question) {
    Color? color;
    if (_answered) {
      if (i == question.correctIndex) {
        color = Colors.green.shade100;
      } else if (i == _selected) {
        color = Colors.red.shade100;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _answered ? null : () => _selectAnswer(i, question),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  void _selectAnswer(int i, QuizQuestion question) {
    setState(() {
      _selected = i;
      _answered = true;
      if (i == question.correctIndex) _correct++;
    });
  }

  void _next() {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    if (_questionIndex == quiz.questions.length - 1) {
      final state = context.read<AppState>();
      final child = state.activeChild!;
      state.submitQuizResult(child, quiz, _correct);
      Navigator.pushReplacementNamed(
        context,
        '/quiz-result',
        arguments: {'quiz': quiz, 'correct': _correct},
      );
    } else {
      setState(() {
        _questionIndex++;
        _selected = null;
        _answered = false;
      });
    }
  }
}
