import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/floating_bubbles.dart';

class SafetyBuddyScreen extends StatefulWidget {
  const SafetyBuddyScreen({super.key});

  @override
  State<SafetyBuddyScreen> createState() => _SafetyBuddyScreenState();
}

class _SafetyBuddyScreenState extends State<SafetyBuddyScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send(AppState state) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final child = state.activeChild!;
    state.askBuddy(child, text);
    _controller.clear();
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
    final messages = state.chatMessages.where((m) => m.childId == child.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'নিরাপত্তা বাডি 🤖' : 'Safety Buddy 🤖')),
      body: Stack(
        children: [
          if (messages.isEmpty) const Positioned.fill(child: FloatingBubbles(count: 10)),
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
                          Text(
                            t
                                ? 'আগুন, বন্যা, ভূমিকম্প বা অপরিচিত ব্যক্তি সম্পর্কে আমাকে জিজ্ঞাসা করো!'
                                : 'Ask me anything about fire, flood, earthquake, or strangers!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      return Align(
                        alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: m.isUser
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            m.isUser ? m.prompt : m.response,
                            style: TextStyle(color: m.isUser ? Colors.white : Colors.black87),
                          ),
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
                        hintText: t ? 'তোমার প্রশ্ন লেখো...' : 'Type your question...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _send(state),
                    ),
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
