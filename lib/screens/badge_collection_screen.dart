import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../widgets/floating_bubbles.dart';

class BadgeCollectionScreen extends StatelessWidget {
  const BadgeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final child = state.activeChild!;
    final earned = state.badgesForChild(child.id);
    final earnedNames = earned.map((b) => b.name).toSet();
    final possibleBadges = MockData.modules.map((m) => '${m.title} Master').toList();

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'ব্যাজ সংগ্রহ 🏆' : 'Badge Collection 🏆')),
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles(count: 10)),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: possibleBadges.length,
            itemBuilder: (context, index) {
              final name = possibleBadges[index];
              final isEarned = earnedNames.contains(name);
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isEarned
                      ? const LinearGradient(colors: [Color(0xFFFFF3C4), Color(0xFFFFE082)])
                      : null,
                  color: isEarned ? null : Colors.grey.shade200,
                  boxShadow: isEarned
                      ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: isEarned ? 1 : 0.3,
                        child: const Text('🏅', style: TextStyle(fontSize: 44)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isEarned ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      if (!isEarned)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(t ? 'লকড' : 'Locked', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
