import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'child_home_screen.dart';
import 'lesson_list_screen.dart';
import 'safety_buddy_screen.dart';
import 'badge_collection_screen.dart';
import 'locked_screen.dart';

class ChildShell extends StatefulWidget {
  const ChildShell({super.key});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.activeChild;
    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.isLocked(child)) {
      return const LockedScreen();
    }
    final t = state.bengali;
    final pages = [
      const ChildHomeScreen(),
      const LessonListScreen(embedded: true),
      const SafetyBuddyScreen(),
      const BadgeCollectionScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: t ? 'হোম' : 'Home'),
          NavigationDestination(icon: const Icon(Icons.menu_book_rounded), label: t ? 'পাঠ' : 'Lessons'),
          NavigationDestination(icon: const Icon(Icons.smart_toy_rounded), label: t ? 'বাডি' : 'Buddy'),
          NavigationDestination(icon: const Icon(Icons.emoji_events_rounded), label: t ? 'ব্যাজ' : 'Badges'),
        ],
      ),
    );
  }
}
