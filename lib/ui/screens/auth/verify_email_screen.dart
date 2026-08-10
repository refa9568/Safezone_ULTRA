import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/auth_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';

/// Shown right after signup (and to any signed-in-but-unverified user on
/// login). Firestore user data is only written once the parent confirms
/// their email — see [_checkStatus], which is the sole place that calls
/// AppState.initForUser() from this screen.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authService = AuthService();
  bool _checking = false;
  bool _resending = false;

  Future<void> _checkStatus(bool t) async {
    setState(() => _checking = true);
    try {
      final verified = await _authService.isEmailVerified();
      if (!verified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t
                    ? 'এখনো verify হয়নি। ইমেইলের লিংকে ক্লিক করো, তারপর আবার চেষ্টা করো।'
                    : "Not verified yet. Click the link in your email, then try again.",
              ),
            ),
          );
        }
        return;
      }

      final user = _authService.currentUser!;
      if (!mounted) return;
      // Only now - after verification is confirmed - does any user data
      // get written to Firestore.
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
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend(bool t) async {
    setState(() => _resending = true);
    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t
                  ? 'ভেরিফিকেশন ইমেইল আবার পাঠানো হয়েছে।'
                  : 'Verification email resent.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authService.friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final email = _authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'ইমেইল ভেরিফাই করো' : 'Verify Your Email'),
      ),
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
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  t
                      ? 'ভেরিফিকেশন ইমেইল পাঠানো হয়েছে'
                      : 'Verification email sent',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t
                      ? '$email ঠিকানায় একটা লিংক পাঠানো হয়েছে। লিংকে ক্লিক করে ইমেইল ভেরিফাই করো, তারপর নিচের বাটনে চাপো।'
                      : "We sent a link to $email. Click it to verify your email, then tap the button below.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checking ? null : () => _checkStatus(t),
                  child: _checking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          t
                              ? 'ভেরিফিকেশন স্ট্যাটাস চেক করো'
                              : 'Check Verification Status',
                        ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _resending ? null : () => _resend(t),
                  child: _resending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          t ? 'ইমেইল আবার পাঠাও' : 'Resend Verification Email',
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _signOut,
                  child: Text(
                    t ? 'ভুল ইমেইল? আবার শুরু করো' : 'Wrong email? Start over',
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
