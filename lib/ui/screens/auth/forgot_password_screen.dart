import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/auth_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink(bool t) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t ? 'ইমেইল দিন' : 'Enter your email')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
    } on Object catch (e) {
      // Don't reveal whether the email exists - show success either way
      // except for a genuinely malformed address.
      final isInvalidEmail = _authService.friendlyError(e).contains('invalid');
      if (isInvalidEmail) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authService.friendlyError(e))),
          );
          setState(() => _loading = false);
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    return Scaffold(
      appBar: AppBar(title: Text(t ? 'পাসওয়ার্ড রিসেট' : 'Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sent
                  ? [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t ? 'রিসেট লিংক পাঠানো হয়েছে' : 'Reset link sent',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t
                            ? 'যদি ${_emailController.text.trim()} দিয়ে একটি অ্যাকাউন্ট থাকে, একটি পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে। লিংকে গিয়ে নতুন পাসওয়ার্ড সেট করুন।'
                            : 'If an account exists for ${_emailController.text.trim()}, a password reset link has been sent. Open it to set a new password.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t ? 'লগইনে ফিরে যান' : 'Back to Login'),
                      ),
                    ]
                  : [
                      Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t
                            ? 'আপনার ইমেইল দিন, আমরা একটি রিসেট লিংক পাঠাবো'
                            : "Enter your email and we'll send a reset link",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
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
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : () => _sendResetLink(t),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(t ? 'রিসেট লিংক পাঠান' : 'Send Reset Link'),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
