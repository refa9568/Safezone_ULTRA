import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/auth_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(bool t) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t ? 'ইমেইল ও পাসওয়ার্ড দিন' : 'Enter your email and password',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signIn(email, password);
      if (!mounted) return;
      // Reload before trusting emailVerified - the cached value on the
      // credential can be stale if verification just happened elsewhere.
      final verified = await _authService.isEmailVerified();
      if (!verified) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        }
        return;
      }
      final user = _authService.currentUser!;
      if (!mounted) return;
      await context.read<AppState>().initForUser(
        user.uid,
        name: user.displayName,
        email: user.email,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/profiles');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authService.friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    return Scaffold(
      appBar: AppBar(title: Text(t ? 'অভিভাবক লগইন' : 'Parent Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.family_restroom,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  t ? 'আপনার অ্যাকাউন্টে লগইন করুন' : 'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t ? 'ইমেইল' : 'Email',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t ? 'পাসওয়ার্ড' : 'Password',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : () => _login(t),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t ? 'লগইন' : 'Login'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    t
                        ? 'নতুন অ্যাকাউন্ট? নিবন্ধন করুন'
                        : "New here? Create an account",
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
