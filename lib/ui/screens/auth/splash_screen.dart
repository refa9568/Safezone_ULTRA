import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/auth_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/widgets/floating_bubbles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _checkingSession = false;

  Future<void> _getStarted() async {
    final state = context.read<AppState>();
    final authService = AuthService();
    final user = authService.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    setState(() => _checkingSession = true);
    final verified = await authService.isEmailVerified();
    if (!verified) {
      if (mounted) Navigator.pushReplacementNamed(context, '/verify-email');
      return;
    }
    await state.initForUser(
      user.uid,
      name: user.displayName,
      email: user.email,
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/profiles');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 140,
                      height: 140,
                    ),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      state.bengali
                          ? 'ভাষা নির্বাচন করুন'
                          : 'Choose your language',
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
                        onPressed: _checkingSession ? null : _getStarted,
                        child: _checkingSession
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(state.bengali ? 'শুরু করুন' : 'Get Started'),
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

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
