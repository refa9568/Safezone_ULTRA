import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A round, high-contrast icon button used for navigation arrows that need
/// to stand out against busy/pastel backgrounds (e.g. a "back to home"
/// button on a tab that normally has no back arrow).
class PoppingArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const PoppingArrowButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppTheme.secondary,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}
