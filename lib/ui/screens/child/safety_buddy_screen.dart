import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:safezone_ultra/backend/humanized_tts_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/widgets/floating_bubbles.dart';

class SafetyBuddyScreen extends StatefulWidget {
  const SafetyBuddyScreen({super.key});

  @override
  State<SafetyBuddyScreen> createState() => _SafetyBuddyScreenState();
}

class _SafetyBuddyScreenState extends State<SafetyBuddyScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final HumanizedTts _tts = HumanizedTts();
  final SpeechToText _speech = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _playingId;

  @override
  void initState() {
    super.initState();
    _tts.setOnComplete(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _playingId = null;
        });
      }
    });
    _speech
        .initialize(
          onStatus: (status) {
            if (status == 'notListening' || status == 'done') {
              if (mounted) setState(() => _isListening = false);
            }
          },
          onError: (_) {
            if (mounted) setState(() => _isListening = false);
          },
        )
        .then((available) {
          if (mounted) setState(() => _speechEnabled = available);
        });
  }

  @override
  void dispose() {
    _tts.stop();
    _tts.dispose();
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startListening(bool bengali) async {
    if (!_speechEnabled || _isListening) return;
    if (_isSpeaking) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
        _playingId = null;
      });
    }
    String? localeId;
    if (bengali) {
      final locales = await _speech.locales();
      final match = locales.where(
        (l) => l.localeId.toLowerCase().startsWith('bn'),
      );
      if (match.isNotEmpty) localeId = match.first.localeId;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() => _controller.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _isListening = false);
        }
      },
      listenOptions: SpeechListenOptions(localeId: localeId),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _toggleSpeak(String id, String text, bool bengali) async {
    if (_isSpeaking && _playingId == id) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
        _playingId = null;
      });
      return;
    }
    await _tts.stop();
    setState(() {
      _isSpeaking = true;
      _playingId = id;
    });
    await _tts.speak(text, bengali: bengali);
  }

  void _send(AppState state) {
    if (_isListening) _stopListening();
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final child = state.activeChild!;
    state.askBuddy(child, text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final child = state.activeChild!;
    final messages = state.chatMessages
        .where((m) => m.childId == child.id)
        .toList();
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(title: const Text('Safety Buddy 🤖')),
      body: Stack(
        children: [
          if (messages.isEmpty)
            const Positioned.fill(child: FloatingBubbles(count: 10)),
          Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🤖', style: TextStyle(fontSize: 64)),
                              const SizedBox(height: 12),
                              const Text(
                                'Ask me anything about fire, flood, earthquake, or strangers!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (state.buddyThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: SizedBox(
                                  width: 40,
                                  height: 24,
                                  child: Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          final m = messages[index];
                          final bubble = Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: m.isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              m.isUser ? m.prompt : m.response,
                              style: TextStyle(
                                color: m.isUser
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          );
                          if (m.isUser) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: bubble,
                            );
                          }
                          final playing =
                              _isSpeaking && _playingId == m.id;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(child: bubble),
                                IconButton(
                                  icon: Icon(
                                    playing
                                        ? Icons.stop_circle_rounded
                                        : Icons.volume_up_rounded,
                                    size: 20,
                                    color: playing
                                        ? Colors.red.shade600
                                        : Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                  ),
                                  tooltip: playing
                                      ? (t ? 'থামাও' : 'Stop')
                                      : (t ? 'শোনো' : 'Play'),
                                  onPressed: () =>
                                      _toggleSpeak(m.id, m.response, t),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? (t ? 'শুনছি...' : 'Listening...')
                                : (t
                                      ? 'তোমার প্রশ্ন লেখো...'
                                      : 'Type your question...'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          onSubmitted: (_) => _send(state),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        ),
                        style: _isListening
                            ? IconButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                              )
                            : null,
                        tooltip: _speechEnabled
                            ? (t ? 'বলে বলো' : 'Speak')
                            : (t ? 'মাইক্রোফোন নেই' : 'Mic unavailable'),
                        onPressed: _speechEnabled
                            ? () => _isListening
                                  ? _stopListening()
                                  : _startListening(t)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.send_rounded),
                        onPressed: () => _send(state),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
