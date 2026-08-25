import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/widgets/child_avatar.dart';

/// Entry point for the parent's chat history feature. With a single child
/// it jumps straight to that child's transcript; with more than one it lets
/// the parent pick which child's chat to view.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final children = state.children;

    if (children.length == 1 && !_redirected) {
      _redirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/chat-transcript',
          arguments: children.first,
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'চ্যাট হিস্ট্রি' : 'Chat History')),
      body: children.isEmpty
          ? Center(
              child: Text(
                t ? 'এখনও কোনো সন্তান যোগ করা হয়নি।' : 'No children added yet.',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          : children.length == 1
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  t
                      ? 'কোন সন্তানের চ্যাট দেখতে চান?'
                      : "Whose chat would you like to see?",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final child in children)
                  Card(
                    child: ListTile(
                      leading: ChildAvatar(child: child, radius: 22),
                      title: Text(child.name),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/chat-transcript',
                        arguments: child,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
