import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_bubbles.dart';

const Map<HazardCategory, List<Color>> _categoryColors = {
  HazardCategory.fire: [Color(0xFFFFCCBC), Color(0xFFFFAB91)],
  HazardCategory.flood: [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
  HazardCategory.earthquake: [Color(0xFFD7CCC8), Color(0xFFBCAAA4)],
  HazardCategory.stranger: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
};

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.activeChild!;
    final t = state.bengali;
    final stars = state.resultsForChild(child.id).fold<int>(0, (sum, r) => sum + r.stars);
    final badgeCount = state.badgesForChild(child.id).length;
    final remaining = state.minutesRemaining(child);

    return Scaffold(
      appBar: AppBar(
        title: Text('${t ? 'হ্যালো' : 'Hi'}, ${child.name} ${child.avatarEmoji}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: state.toggleLanguage,
            tooltip: 'EN / বাংলা',
          ),
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: () => Navigator.pushReplacementNamed(context, '/profiles'),
            tooltip: t ? 'প্রোফাইল পরিবর্তন' : 'Switch profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles(count: 8)),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _StatChip(icon: Icons.star_rounded, label: '$stars', sub: t ? 'তারা' : 'Stars', color: Colors.amber)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatChip(icon: Icons.emoji_events_rounded, label: '$badgeCount', sub: t ? 'ব্যাজ' : 'Badges', color: AppTheme.secondary)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatChip(icon: Icons.timer_rounded, label: '$remaining', sub: t ? 'মিনিট বাকি' : 'Min Left', color: AppTheme.success)),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                t ? 'পাঠ বিভাগসমূহ 🎨' : 'Lesson Categories 🎨',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  for (final module in MockData.modules)
                    _CategoryCard(
                      emoji: _emojiFor(module.category),
                      title: t ? module.titleBn : module.title,
                      colors: _categoryColors[module.category]!,
                      onTap: () => Navigator.pushNamed(context, '/lesson-player', arguments: module),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showQuizOptions(context, t),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t ? 'কুইজ 🧩' : 'Quiz 🧩',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuizOptions(BuildContext context, bool t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t ? 'একটি কুইজ বেছে নিন' : 'Choose a Quiz',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (final module in MockData.modules)
                if (MockData.quizzesByModule.containsKey(module.id))
                  ListTile(
                    leading: Text(_emojiFor(module.category), style: const TextStyle(fontSize: 24)),
                    title: Text(t ? module.titleBn : module.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(
                        context,
                        '/quiz',
                        arguments: MockData.quizzesByModule[module.id],
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  String _emojiFor(HazardCategory category) {
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String emoji;
  final String title;
  final List<Color> colors;
  final VoidCallback onTap;

  const _CategoryCard({required this.emoji, required this.title, required this.colors, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
