import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'safety_mascot.dart';

class CartoonInstructionCard extends StatefulWidget {
  final String emoji;
  final List<Color> skyColors;
  final Color groundColor;
  final int seed;

  const CartoonInstructionCard({
    super.key,
    required this.emoji,
    required this.skyColors,
    required this.groundColor,
    this.seed = 0,
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
  late final AnimationController _cloud1Squash;
  late final AnimationController _cloud2Squash;
  late final AnimationController _groundBounce;

  final List<_Burst> _bursts = [];
  final List<_CloudPoke> _cloudPokes = [];

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
    _cloud1Squash = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _cloud2Squash = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _groundBounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _idleController.dispose();
    _driftController.dispose();
    _cloud1Squash.dispose();
    _cloud2Squash.dispose();
    _groundBounce.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    if (!_bounceController.isAnimating) {
      _bounceController.forward(from: 0);
    }
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() => _bursts.add(_Burst(id)));
  }

  void _removeBurst(int id) {
    setState(() => _bursts.removeWhere((b) => b.id == id));
  }

  void _onCloudTap(int cloudIndex) {
    HapticFeedback.selectionClick();
    final controller = cloudIndex == 0 ? _cloud1Squash : _cloud2Squash;
    if (!controller.isAnimating) controller.forward(from: 0);
    final id = DateTime.now().microsecondsSinceEpoch;
    setState(() => _cloudPokes.add(_CloudPoke(id, cloudIndex)));
  }

  void _removeCloudPoke(int id) {
    setState(() => _cloudPokes.removeWhere((p) => p.id == id));
  }

  void _onGroundTap() {
    HapticFeedback.lightImpact();
    if (!_groundBounce.isAnimating) _groundBounce.forward(from: 0);
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
              // Drifting clouds (tappable)
              AnimatedBuilder(
                animation: Listenable.merge([_driftController, _cloud1Squash]),
                builder: (context, _) {
                  final dx = sin(_driftController.value * 2 * pi) * 10;
                  final squash = sin(pi * _cloud1Squash.value).clamp(0.0, 1.0);
                  return Positioned(
                    top: 18,
                    left: 20 + dx,
                    child: GestureDetector(
                      onTap: () => _onCloudTap(0),
                      child: Transform.scale(
                        scaleX: 1 + squash * 0.25,
                        scaleY: 1 - squash * 0.25,
                        child: const _Cloud(size: 46),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_driftController, _cloud2Squash]),
                builder: (context, _) {
                  final dx = sin(_driftController.value * 2 * pi + pi) * 8;
                  final squash = sin(pi * _cloud2Squash.value).clamp(0.0, 1.0);
                  return Positioned(
                    top: 34,
                    right: 24 - dx,
                    child: GestureDetector(
                      onTap: () => _onCloudTap(1),
                      child: Transform.scale(
                        scaleX: 1 + squash * 0.25,
                        scaleY: 1 - squash * 0.25,
                        child: const _Cloud(size: 34),
                      ),
                    ),
                  );
                },
              ),
              for (final poke in _cloudPokes)
                Positioned(
                  top: poke.cloudIndex == 0 ? 30 : 46,
                  left: poke.cloudIndex == 0 ? 44 : null,
                  right: poke.cloudIndex == 0 ? null : 42,
                  child: _ParticleBurst(key: ValueKey(poke.id), onDone: () => _removeCloudPoke(poke.id)),
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
              // Ground (tappable bounce)
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: _onGroundTap,
                  child: AnimatedBuilder(
                    animation: _groundBounce,
                    builder: (context, child) {
                      final squash = sin(pi * _groundBounce.value).clamp(0.0, 1.0);
                      return Transform.scale(
                        scaleY: 1 - squash * 0.12,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      );
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: widget.groundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                    ),
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
                    child: SafetyMascot(
                      bodyColor: mascotColorFrom(widget.groundColor),
                      emoji: widget.emoji,
                      seed: widget.seed,
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

class _CloudPoke {
  final int id;
  final int cloudIndex;
  _CloudPoke(this.id, this.cloudIndex);
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
