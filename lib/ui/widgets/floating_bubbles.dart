import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBubbles extends StatefulWidget {
  final int count;
  final List<String> emojis;

  const FloatingBubbles({
    super.key,
    this.count = 14,
    this.emojis = const ['🎈', '🫧', '⭐', '✨', '🌟', '🧸', '🎉', '🐟', '🦋', '🌈'],
  });

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _Bubble {
  final double startX;
  final double size;
  final double speed;
  double phase;
  final String emoji;
  final double sway;

  _Bubble({
    required this.startX,
    required this.size,
    required this.speed,
    required this.phase,
    required this.emoji,
    required this.sway,
  });
}

class _Pop {
  final int id;
  final double x;
  final double y;
  _Pop(this.id, this.x, this.y);
}

class _FloatingBubblesState extends State<FloatingBubbles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;
  final List<_Pop> _pops = [];

  @override
  void initState() {
    super.initState();
    final random = Random(7);
    _bubbles = List.generate(widget.count, (i) {
      return _Bubble(
        startX: random.nextDouble(),
        size: 22 + random.nextDouble() * 30,
        speed: 0.4 + random.nextDouble() * 0.6,
        phase: random.nextDouble(),
        emoji: widget.emojis[random.nextInt(widget.emojis.length)],
        sway: 12 + random.nextDouble() * 24,
      );
    });
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _popBubble(_Bubble b, double x, double y) {
    HapticFeedback.selectionClick();
    // Jump the bubble just past the end of its cycle so it vanishes now
    // and quietly restarts its rise from the bottom on the next loop.
    final t = (_controller.value * b.speed + b.phase) % 1.0;
    b.phase = (b.phase + (0.995 - t)) % 1.0;
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() => _pops.add(_Pop(id, x, y)));
  }

  void _removePop(int id) {
    setState(() => _pops.removeWhere((p) => p.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;
              return Stack(
                children: [
                  for (final b in _bubbles)
                    Builder(builder: (_) {
                      final t = (_controller.value * b.speed + b.phase) % 1.0;
                      final y = h * (1 - t);
                      final x = b.startX * w + sin(t * 2 * pi) * b.sway;
                      final opacity = (sin(t * pi)).clamp(0.0, 1.0);
                      return Positioned(
                        left: x,
                        top: y,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _popBubble(b, x, y),
                          child: Opacity(
                            opacity: opacity * 0.55,
                            child: Text(b.emoji, style: TextStyle(fontSize: b.size)),
                          ),
                        ),
                      );
                    }),
                  for (final pop in _pops)
                    Positioned(
                      left: pop.x - 30,
                      top: pop.y - 30,
                      width: 60,
                      height: 60,
                      child: _PopBurst(onDone: () => _removePop(pop.id)),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PopBurst extends StatefulWidget {
  final VoidCallback onDone;
  const _PopBurst({required this.onDone});

  @override
  State<_PopBurst> createState() => _PopBurstState();
}

class _PopBurstState extends State<_PopBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
      ..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + t * 1.2,
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 26))),
          ),
        );
      },
    );
  }
}
