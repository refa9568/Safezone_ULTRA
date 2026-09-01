import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:safezone_ultra/services/mock_data.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/widgets/cartoon_instruction_card.dart';
import 'package:safezone_ultra/ui/widgets/floating_bubbles.dart';

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

/// Lightens a color toward white so it reads as a soft page backdrop
/// rather than a saturated block of color.
Color _soften(Color c) => Color.lerp(c, Colors.white, 0.55)!;

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  final PageController _pageController = PageController();
  final AudioPlayer _player = AudioPlayer();
  int _page = 0;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Plays the pre-recorded narration at [assetPath] (relative to assets/,
  /// see LessonModule.stepAudioAsset / summaryAudioAsset).
  Future<void> _speak(String assetPath) async {
    if (_isSpeaking) {
      await _player.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await _player.play(AssetSource(assetPath));
  }

  @override
  Widget build(BuildContext context) {
    final module = ModalRoute.of(context)!.settings.arguments as LessonModule;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final hasQuiz = MockData.quizzesByModule.containsKey(module.id);
    final steps = t ? module.stepsBn : module.steps;
    final hasSteps = steps.isNotEmpty;

    final pageBackground = _skyColors[module.category]!
        .map<Color>(_soften)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? module.titleBn : module.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: state.toggleLanguage,
          ),
        ],
      ),
      body: hasSteps
          ? Stack(
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
                Positioned.fill(
                  child: FloatingBubbles(
                    count: 10,
                    emojis: _pageBubbles[module.category]!,
                  ),
                ),
                Column(
                  children: [
                    LinearProgressIndicator(value: (_page + 1) / steps.length),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        t
                            ? 'নির্দেশনা ${_page + 1} / ${steps.length}'
                            : 'Instruction ${_page + 1} of ${steps.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: steps.length,
                        onPageChanged: (i) {
                          _player.stop();
                          setState(() {
                            _page = i;
                            _isSpeaking = false;
                          });
                        },
                        itemBuilder: (context, i) {
                          final icon = i < module.stepIcons.length
                              ? module.stepIcons[i]
                              : _emoji(module.category);
                          final hasVideo =
                              i < module.stepVideos.length &&
                              module.stepVideos[i].isNotEmpty;
                          final hasImage =
                              !hasVideo &&
                              i < module.stepImages.length &&
                              module.stepImages[i].isNotEmpty;
                          return SingleChildScrollView(
                            key: ValueKey('step-$i'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                hasVideo
                                    ? _StepVideo(
                                        assetPath: module.stepVideos[i],
                                      )
                                    : hasImage
                                    ? Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.04,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.asset(
                                          module.stepImages[i],
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : CartoonInstructionCard(
                                        emoji: icon,
                                        skyColors: _skyColors[module.category]!,
                                        groundColor:
                                            _groundColors[module.category]!,
                                        seed: i,
                                      ),
                                const SizedBox(height: 24),
                                Text(
                                  steps[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () => _speak(
                                    module.stepAudioAsset(i, bengali: t),
                                  ),
                                  icon: Icon(
                                    _isSpeaking
                                        ? Icons.stop_circle_rounded
                                        : Icons.volume_up_rounded,
                                  ),
                                  label: Text(
                                    _isSpeaking
                                        ? (t ? 'থামাও' : 'Stop')
                                        : (t ? '🔊 শুনুন' : '🔊 Listen'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      // Lift the Previous/Next buttons clear of the phone's
                      // on-screen navigation bar/gesture area, which
                      // otherwise overlaps taps near the bottom edge.
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        20 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _page == 0
                                  ? null
                                  : () => _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeOut,
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.secondary,
                                side: const BorderSide(
                                  color: AppTheme.secondary,
                                  width: 2,
                                ),
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
                                          label: Text(
                                            t
                                                ? 'কুইজ শুরু করুন'
                                                : 'Take the Quiz',
                                          ),
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            '/quiz',
                                            arguments: MockData
                                                .quizzesByModule[module.id],
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(t ? 'সম্পন্ন' : 'Done'),
                                        ))
                                : ElevatedButton.icon(
                                    onPressed: () => _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeOut,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
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
          : Stack(
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
                Padding(
                  // Lift the Take-the-Quiz button clear of the phone's
                  // on-screen navigation bar/gesture area, which otherwise
                  // overlaps taps near the bottom edge.
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _speak(
                                    module.summaryAudioAsset(bengali: t),
                                  ),
                                  icon: Icon(
                                    _isSpeaking
                                        ? Icons.stop_circle_rounded
                                        : Icons.volume_up_rounded,
                                  ),
                                  label: Text(
                                    _isSpeaking
                                        ? (t ? 'থামাও' : 'Stop')
                                        : (t ? '🔊 শুনুন' : '🔊 Listen'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
              ],
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

class _StepVideo extends StatefulWidget {
  final String assetPath;
  const _StepVideo({required this.assetPath});

  @override
  State<_StepVideo> createState() => _StepVideoState();
}

class _StepVideoState extends State<_StepVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: !_ready
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _controller.value.isPlaying ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
