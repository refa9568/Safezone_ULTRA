import 'dart:math';
import 'package:flutter/material.dart';

/// A cute hand-drawn mascot character (drawn with [CustomPainter]) that
/// wears the step's emoji as a chest badge. Used to replace plain bare
/// emoji icons across lesson cards with a friendlier illustrated look.
///
/// [seed] picks one of several distinct body shapes/faces/poses so that
/// consecutive steps don't all render the same blob in a different color.
class SafetyMascot extends StatelessWidget {
  final Color bodyColor;
  final String emoji;
  final int seed;
  final double width;
  final double height;

  const SafetyMascot({
    super.key,
    required this.bodyColor,
    required this.emoji,
    this.seed = 0,
    this.width = 148,
    this.height = 166,
  });

  @override
  Widget build(BuildContext context) {
    final variant = seed % MascotVariant.values.length;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _SafetyMascotPainter(bodyColor: bodyColor, variant: MascotVariant.values[variant]),
          ),
          Positioned(
            top: height * 0.42,
            child: Container(
              width: width * 0.5,
              height: width * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: width * 0.26)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MascotVariant { blob, robot, star, cloud, shield }

class _SafetyMascotPainter extends CustomPainter {
  final Color bodyColor;
  final MascotVariant variant;
  _SafetyMascotPainter({required this.bodyColor, required this.variant});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()..color = bodyColor;
    final darkOutline = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final armPaint = Paint()..color = bodyColor;
    final footPaint = Paint()..color = bodyColor.withValues(alpha: 0.85);

    // Feet
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.36, h * 0.94), width: w * 0.22, height: h * 0.07), footPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.64, h * 0.94), width: w * 0.22, height: h * 0.07), footPaint);

    // Arms — tilt differs per variant so poses read as distinct
    final armTilt = switch (variant) {
      MascotVariant.blob => 0.5,
      MascotVariant.robot => 0.15,
      MascotVariant.star => 0.75,
      MascotVariant.cloud => 0.3,
      MascotVariant.shield => 0.05,
    };
    canvas.save();
    canvas.translate(w * 0.09, h * 0.58);
    canvas.rotate(-armTilt);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.34, height: w * 0.15), armPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(w * 0.91, h * 0.58);
    canvas.rotate(armTilt);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.34, height: w * 0.15), armPaint);
    canvas.restore();

    // Body silhouette
    final body = _bodyPath(variant, w, h);
    canvas.drawPath(body, bodyPaint);
    canvas.drawPath(body, darkOutline);

    // Accessory (drawn on top of body, behind face)
    _drawAccessory(canvas, variant, w, h);

    // Soft highlight
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.32, h * 0.22), width: w * 0.28, height: h * 0.16), highlight);

    _drawFace(canvas, variant, w, h);
  }

  Path _bodyPath(MascotVariant variant, double w, double h) {
    switch (variant) {
      case MascotVariant.blob:
        return Path()
          ..moveTo(w * 0.5, h * 0.02)
          ..cubicTo(w * 0.86, h * 0.02, w * 0.98, h * 0.34, w * 0.94, h * 0.6)
          ..cubicTo(w * 0.90, h * 0.92, w * 0.72, h * 1.0, w * 0.5, h * 1.0)
          ..cubicTo(w * 0.28, h * 1.0, w * 0.10, h * 0.92, w * 0.06, h * 0.6)
          ..cubicTo(w * 0.02, h * 0.34, w * 0.14, h * 0.02, w * 0.5, h * 0.02)
          ..close();
      case MascotVariant.robot:
        final rect = Rect.fromLTRB(w * 0.08, h * 0.10, w * 0.92, h * 1.0);
        return Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(w * 0.22)));
      case MascotVariant.star:
        return _starPath(w, h);
      case MascotVariant.cloud:
        final path = Path();
        path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.66), width: w * 0.92, height: h * 0.62));
        path.addOval(Rect.fromCenter(center: Offset(w * 0.30, h * 0.30), width: w * 0.5, height: h * 0.42));
        path.addOval(Rect.fromCenter(center: Offset(w * 0.70, h * 0.30), width: w * 0.5, height: h * 0.42));
        path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.18), width: w * 0.56, height: h * 0.38));
        return Path.combine(PathOperation.union, path, Path());
      case MascotVariant.shield:
        return Path()
          ..moveTo(w * 0.5, h * 0.02)
          ..lineTo(w * 0.90, h * 0.14)
          ..cubicTo(w * 0.92, h * 0.5, w * 0.84, h * 0.82, w * 0.5, h * 1.0)
          ..cubicTo(w * 0.16, h * 0.82, w * 0.08, h * 0.5, w * 0.10, h * 0.14)
          ..close();
    }
  }

  Path _starPath(double w, double h) {
    final cx = w * 0.5;
    final cy = h * 0.52;
    final outerR = w * 0.48;
    final innerR = w * 0.24;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = -pi / 2 + i * pi / 5;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle) * (h / w) * 0.9;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawAccessory(Canvas canvas, MascotVariant variant, double w, double h) {
    switch (variant) {
      case MascotVariant.robot:
        final antennaPaint = Paint()
          ..color = bodyColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawLine(Offset(w * 0.5, h * 0.10), Offset(w * 0.5, h * 0.0), antennaPaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.0), w * 0.035, Paint()..color = const Color(0xFFFFD54F));
      case MascotVariant.shield:
        final chevron = Path()
          ..moveTo(w * 0.38, h * 0.62)
          ..lineTo(w * 0.5, h * 0.72)
          ..lineTo(w * 0.62, h * 0.62);
        canvas.drawPath(
          chevron,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      case MascotVariant.blob:
      case MascotVariant.star:
      case MascotVariant.cloud:
        break;
    }
  }

  void _drawFace(Canvas canvas, MascotVariant variant, double w, double h) {
    final eyeCenterY = variant == MascotVariant.star ? h * 0.34 : h * 0.22;
    final pupil = Paint()..color = const Color(0xFF2B2B2B);
    final eyeShine = Paint()..color = Colors.white;
    final blush = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55);
    final linePaint = Paint()
      ..color = const Color(0xFF2B2B2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    switch (variant) {
      case MascotVariant.blob:
      case MascotVariant.star:
      case MascotVariant.shield:
        // Round open eyes with shine
        final eyeWhite = Paint()..color = Colors.white;
        for (final dx in [-1.0, 1.0]) {
          final center = Offset(w * 0.5 + dx * w * 0.14, eyeCenterY);
          canvas.drawOval(Rect.fromCenter(center: center, width: w * 0.15, height: h * 0.12), eyeWhite);
          canvas.drawCircle(Offset(center.dx + dx * 1.5, center.dy + 1.5), w * 0.035, pupil);
          canvas.drawCircle(Offset(center.dx + dx * 1.5 - 1.5, center.dy - 1.5), w * 0.012, eyeShine);
        }
      case MascotVariant.robot:
        // Rounded-square visor eyes
        final visor = Paint()..color = Colors.white;
        for (final dx in [-1.0, 1.0]) {
          final center = Offset(w * 0.5 + dx * w * 0.14, eyeCenterY);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: w * 0.13, height: h * 0.1), const Radius.circular(4)),
            visor,
          );
          canvas.drawCircle(center, w * 0.03, pupil);
        }
      case MascotVariant.cloud:
        // Sleepy happy closed-eye arcs (^^)
        for (final dx in [-1.0, 1.0]) {
          final center = Offset(w * 0.5 + dx * w * 0.14, eyeCenterY);
          final arc = Path()
            ..moveTo(center.dx - w * 0.06, center.dy)
            ..quadraticBezierTo(center.dx, center.dy - h * 0.05, center.dx + w * 0.06, center.dy);
          canvas.drawPath(arc, linePaint);
        }
    }

    // Blush cheeks (shift down slightly for star/shield whose eyes sit lower/higher)
    final blushY = eyeCenterY + h * 0.08;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.28, blushY), width: w * 0.13, height: h * 0.06), blush);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, blushY), width: w * 0.13, height: h * 0.06), blush);

    // Mouth
    final mouthY = eyeCenterY + h * 0.12;
    switch (variant) {
      case MascotVariant.star:
        // Wide open cheerful smile
        final smile = Path()
          ..moveTo(w * 0.40, mouthY)
          ..quadraticBezierTo(w * 0.5, mouthY + h * 0.09, w * 0.60, mouthY)
          ..quadraticBezierTo(w * 0.5, mouthY + h * 0.05, w * 0.40, mouthY);
        canvas.drawPath(smile, Paint()..color = const Color(0xFF2B2B2B));
      case MascotVariant.shield:
        // Confident asymmetric smirk
        final smirk = Path()
          ..moveTo(w * 0.42, mouthY)
          ..quadraticBezierTo(w * 0.54, mouthY + h * 0.05, w * 0.62, mouthY - h * 0.01);
        canvas.drawPath(smirk, linePaint);
      case MascotVariant.robot:
        // Flat neutral mouth
        canvas.drawLine(Offset(w * 0.44, mouthY), Offset(w * 0.56, mouthY), linePaint);
      case MascotVariant.blob:
      case MascotVariant.cloud:
        final smile = Path()
          ..moveTo(w * 0.42, mouthY)
          ..quadraticBezierTo(w * 0.5, mouthY + h * 0.06, w * 0.58, mouthY);
        canvas.drawPath(smile, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SafetyMascotPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor || oldDelegate.variant != variant;
}

/// Lightens [base] toward white so the mascot body reads as a friendly
/// pastel tint of the scene's ground color rather than a clashing hue.
Color mascotColorFrom(Color base) {
  return Color.lerp(base, Colors.white, 0.35)!;
}
