import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/logic/app_state.dart';

/// Read-only copy of a child's Safety Buddy chat, as seen by the parent.
class ChatTranscriptScreen extends StatelessWidget {
  const ChatTranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = ModalRoute.of(context)!.settings.arguments as Child;
    final state = context.watch<AppState>();
    final t = state.bengali;
    final messages = state.chatMessages
        .where((m) => m.childId == child.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t
              ? '${child.name}-এর চ্যাট 🤖'
              : "${child.name}'s Chat with Safety Buddy",
        ),
      ),
      body: messages.isEmpty
          ? Center(
              child: Text(
                t
                    ? 'এখনও কোনো চ্যাট বার্তা নেই।'
                    : 'No chat messages yet.',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final bubble = Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: m.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    m.isUser ? m.prompt : m.response,
                    style: TextStyle(
                      color: m.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                );
                return Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: bubble,
                );
              },
            ),
    );
  }
}
