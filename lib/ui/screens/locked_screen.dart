import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/app_state.dart';

class LockedScreen extends StatelessWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock_rounded, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                t ? 'আজকের জন্য স্ক্রিন টাইম শেষ!' : "Today's screen time is up!",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t ? 'আগামীকাল আবার খেলো।' : 'Come back and play again tomorrow.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/profiles'),
                child: Text(t ? 'প্রোফাইল পরিবর্তন' : 'Switch Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
