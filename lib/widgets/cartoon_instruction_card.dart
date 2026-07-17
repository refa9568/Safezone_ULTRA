import 'dart:math';
import 'package:flutter/material.dart';

class CartoonInstructionCard extends StatefulWidget {
  final String emoji;
  final List<Color> skyColors;
  final Color groundColor;

  const CartoonInstructionCard({
    super.key,
    required this.emoji,
    required this.skyColors,
    required this.groundColor,
  });

  @override
  State<CartoonInstructionCard> createState() => _CartoonInstructionCardState();
}

class _CartoonInstructionCardState extends State<CartoonInstructionCard>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounce;
  late final AnimationController _idleController;
  late final AnimationController _driftController;

  final List<_Burst> _bursts = [];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.18, end: 0.14), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.14, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _idleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _driftController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _idleController.dispose();
    _driftController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_bounceController.isAnimating) {
      _bounceController.forward(from: 0);
    }
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() => _bursts.add(_Burst(id)));
  }

  void _removeBurst(int id) {
    setState(() => _bursts.removeWhere((b) => b.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.85 + 0.15 * value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.skyColors,
                  ),
                ),
              ),
              // Drifting clouds
              AnimatedBuilder(
                animation: _driftController,
                builder: (context, _) {
                  final dx = sin(_driftController.value * 2 * pi) * 10;
                  return Positioned(top: 18, left: 20 + dx, child: const _Cloud(size: 46));
                },
              ),
              AnimatedBuilder(
                animation: _driftController,
                builder: (context, _) {
                  final dx = sin(_driftController.value * 2 * pi + pi) * 8;
                  return Positioned(top: 34, right: 24 - dx, child: const _Cloud(size: 34));
                },
              ),
              // Twinkling sparkle
              AnimatedBuilder(
                animation: _idleController,
                builder: (context, _) => Positioned(
                  top: 14,
                  right: 60,
                  child: Opacity(
                    opacity: 0.5 + 0.5 * _idleController.value,
                    child: const Text('✨', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _idleController,
                builder: (context, _) => Positioned(
                  bottom: 90,
                  left: 18,
                  child: Opacity(
                    opacity: 1 - 0.5 * _idleController.value,
                    child: const Text('⭐', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              // Ground
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.groundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                ),
              ),
              // Particle bursts
              for (final burst in _bursts)
                Center(child: _ParticleBurst(key: ValueKey(burst.id), onDone: () => _removeBurst(burst.id))),
              // Main interactive icon
              Center(
                child: GestureDetector(
                  onTap: _onTap,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_bounce, _idleController]),
                    builder: (context, child) {
                      final bob = sin(_idleController.value * pi) * 6;
                      return Transform.translate(
                        offset: Offset(0, -bob),
                        child: Transform.rotate(angle: _bounce.value, child: child),
                      );
                    },
                    child: Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 6),
                      ),
                      child: Center(
                        child: Text(widget.emoji, style: const TextStyle(fontSize: 68)),
                      ),
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 62,
                right: 0,
                left: 0,
                child: Text('👆 Tap me!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Burst {
  final int id;
  _Burst(this.id);
}

class _ParticleBurst extends StatefulWidget {
  final VoidCallback onDone;
  const _ParticleBurst({super.key, required this.onDone});

  @override
  State<_ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<_ParticleBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<String> _emojis = ['⭐', '✨', '🎉', '💫'];
  late final List<double> _angles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _angles = List.generate(6, (i) => (i / 6) * 2 * pi + _random.nextDouble() * 0.4);
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
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
        return Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < _angles.length; i++)
              Transform.translate(
                offset: Offset(cos(_angles[i]) * 70 * t, sin(_angles[i]) * 70 * t),
                child: Opacity(
                  opacity: (1 - t).clamp(0, 1),
                  child: Text(_emojis[i % _emojis.length], style: const TextStyle(fontSize: 22)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Cloud extends StatelessWidget {
  final double size;
  const _Cloud({required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.cloud_rounded, size: size, color: Colors.white.withValues(alpha: 0.85));
  }
}
