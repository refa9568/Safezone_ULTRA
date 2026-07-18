import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
import '../widgets/cartoon_instruction_card.dart';
import '../widgets/floating_bubbles.dart';

const Map<HazardCategory, List<Color>> _skyColors = {
  HazardCategory.fire: [Color(0xFFFFD59E), Color(0xFFFF9E7A)],
  HazardCategory.flood: [Color(0xFFAEE3FA), Color(0xFF6FC3EF)],
  HazardCategory.earthquake: [Color(0xFFE3D4B8), Color(0xFFC7A97C)],
  HazardCategory.stranger: [Color(0xFFFFE9A8), Color(0xFFFFCB6B)],
};

const Map<HazardCategory, Color> _groundColors = {
  HazardCategory.fire: Color(0xFFE8734A),
  HazardCategory.flood: Color(0xFF3E8FC7),
  HazardCategory.earthquake: Color(0xFF9C7B4F),
  HazardCategory.stranger: Color(0xFFE0A83A),
};

const Map<HazardCategory, List<String>> _pageBubbles = {
  HazardCategory.fire: ['🔥', '🧯', '🚒', '✨', '⭐', '💛'],
  HazardCategory.flood: ['🌊', '💧', '🐟', '☂️', '⭐', '🫧'],
  HazardCategory.earthquake: ['🌍', '📦', '🏠', '⭐', '✨', '🪨'],
  HazardCategory.stranger: ['🚸', '🎈', '⭐', '🧸', '✨', '🛡️'],
};

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _tts = FlutterTts();
  int _page = 0;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.42);
    _tts.setPitch(1.05);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text, bool bengali) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    await _tts.setLanguage(bengali ? 'bn-BD' : 'en-US');
    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final module = ModalRoute.of(context)!.settings.arguments as LessonModule;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final hasQuiz = MockData.quizzesByModule.containsKey(module.id);
    final steps = t ? module.stepsBn : module.steps;
    final hasSteps = steps.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? module.titleBn : module.title),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: state.toggleLanguage),
        ],
      ),
      body: hasSteps
          ? Stack(
              children: [
                Positioned.fill(
                  child: FloatingBubbles(count: 10, emojis: _pageBubbles[module.category]!),
                ),
                Column(
              children: [
                LinearProgressIndicator(value: (_page + 1) / steps.length),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    t ? 'নির্দেশনা ${_page + 1} / ${steps.length}' : 'Instruction ${_page + 1} of ${steps.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: steps.length,
                    onPageChanged: (i) {
                      _tts.stop();
                      setState(() {
                        _page = i;
                        _isSpeaking = false;
                      });
                    },
                    itemBuilder: (context, i) {
                      final icon = i < module.stepIcons.length ? module.stepIcons[i] : _emoji(module.category);
                      return SingleChildScrollView(
                        key: ValueKey('step-$i'),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CartoonInstructionCard(
                              emoji: icon,
                              skyColors: _skyColors[module.category]!,
                              groundColor: _groundColors[module.category]!,
                              seed: i,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              steps[i],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 19, height: 1.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _speak(steps[i], t),
                              icon: Icon(_isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                              label: Text(
                                _isSpeaking
                                    ? (t ? 'থামাও' : 'Stop')
                                    : (t ? '🔊 শুনুন' : '🔊 Listen'),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _page == 0
                              ? null
                              : () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  ),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: Text(t ? 'আগের' : 'Previous'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _page == steps.length - 1
                            ? (hasQuiz
                                ? ElevatedButton.icon(
                                    icon: const Icon(Icons.quiz_rounded),
                                    label: Text(t ? 'কুইজ শুরু করুন' : 'Take the Quiz'),
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/quiz',
                                      arguments: MockData.quizzesByModule[module.id],
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(t ? 'সম্পন্ন' : 'Done'),
                                  ))
                            : ElevatedButton.icon(
                                onPressed: () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(t ? 'পরবর্তী' : 'Next'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CartoonInstructionCard(
                    emoji: _emoji(module.category),
                    skyColors: _skyColors[module.category]!,
                    groundColor: _groundColors[module.category]!,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t ? module.summaryBn : module.summary,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _speak(t ? module.summaryBn : module.summary, t),
                      icon: Icon(_isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded),
                      label: Text(
                        _isSpeaking
                            ? (t ? 'থামাও' : 'Stop')
                            : (t ? '🔊 শুনুন' : '🔊 Listen'),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasQuiz)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.quiz_rounded),
                      label: Text(t ? 'কুইজ শুরু করুন' : 'Take the Quiz'),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/quiz',
                        arguments: MockData.quizzesByModule[module.id],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _emoji(HazardCategory category) {
    switch (category) {
      case HazardCategory.fire:
        return '🔥';
      case HazardCategory.flood:
        return '🌊';
      case HazardCategory.earthquake:
        return '🌍';
      case HazardCategory.stranger:
        return '🚸';
    }
  }
}
