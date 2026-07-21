import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
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
        title: Row(
          children: [
            Flexible(
              child: Text(
                '${t ? 'হ্যালো' : 'Hi'}, ${child.name} ${child.avatarEmoji}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            _SosBar(onTap: () => _handleSos(context, state, child, t), compact: true),
          ],
        ),
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
                onTap: () => Navigator.pushNamed(context, '/mind-game'),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t ? 'মেমরি গেম 🧠' : 'Mind Game 🧠',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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

  Future<void> _handleSos(BuildContext context, AppState state, Child child, bool t) async {
    state.triggerSos(child);
    final phone = state.parent.emergencyPhone;
    if (phone.isEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🆘', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                t ? 'তোমার অভিভাবককে জানানো হয়েছে!' : 'Your parent has been alerted!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                t
                    ? 'কোনো জরুরি নম্বর সেট করা নেই।'
                    : 'No emergency number has been set yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t ? 'ঠিক আছে' : 'OK'),
            ),
          ],
        ),
      );
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone));
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

class _SosBar extends StatefulWidget {
  final VoidCallback onTap;
  final bool compact;

  const _SosBar({required this.onTap, this.compact = false});

  @override
  State<_SosBar> createState() => _SosBarState();
}

class _SosBarState extends State<_SosBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.compact ? 12.0 : 20.0;
    final verticalPadding = widget.compact ? 6.0 : 12.0;
    final emojiSize = widget.compact ? 14.0 : 20.0;
    final fontSize = widget.compact ? 13.0 : 18.0;

    return ScaleTransition(
      scale: _pulse,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🆘', style: TextStyle(fontSize: emojiSize)),
                const SizedBox(width: 6),
                Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: fontSize,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
