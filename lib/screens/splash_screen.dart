import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_bubbles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, Color(0xFF6FB1FC)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: FloatingBubbles(count: 18)),
            SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 88)),
                const SizedBox(height: 16),
                const Text(
                  'SafeZone Ultra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.bengali
                      ? 'শিশুদের নিরাপত্তা শিক্ষা'
                      : 'Child Safety Education, Gamified',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48),
                Text(
                  state.bengali ? 'ভাষা নির্বাচন করুন' : 'Choose your language',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LangButton(
                      label: 'English',
                      selected: !state.bengali,
                      onTap: () {
                        if (state.bengali) state.toggleLanguage();
                      },
                    ),
                    const SizedBox(width: 16),
                    _LangButton(
                      label: 'বাংলা',
                      selected: state.bengali,
                      onTap: () {
                        if (!state.bengali) state.toggleLanguage();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(state.bengali ? 'শুরু করুন' : 'Get Started'),
                  ),
                ),
              ],
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
