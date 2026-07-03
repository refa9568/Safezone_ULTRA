import 'dart:math';
import 'package:flutter/material.dart';

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
  final double phase;
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

class _FloatingBubblesState extends State<FloatingBubbles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bubble> _bubbles;

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

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
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
                          child: Opacity(
                            opacity: opacity * 0.55,
                            child: Text(b.emoji, style: TextStyle(fontSize: b.size)),
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
