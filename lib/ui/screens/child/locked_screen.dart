import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';

String _formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final period = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

class LockedScreen extends StatelessWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final child = state.activeChild;
    final isScheduleLock =
        child != null && state.lockReason(child) == 'schedule';

    final title = isScheduleLock
        ? (t ? 'এখন খেলার সময় না!' : "It's not playtime right now!")
        : (t ? 'আজকের জন্য স্ক্রিন টাইম শেষ!' : "Today's screen time is up!");

    final subtitle = isScheduleLock
        ? (t
              ? 'তুমি ${_formatMinutes(child.scheduleStartMinutes)} থেকে ${_formatMinutes(child.scheduleEndMinutes)} এর মধ্যে খেলতে পারবে।'
              : 'You can play between ${_formatMinutes(child.scheduleStartMinutes)} and ${_formatMinutes(child.scheduleEndMinutes)}.')
        : (t ? 'আগামীকাল আবার খেলো।' : 'Come back and play again tomorrow.');

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isScheduleLock
                    ? Icons.schedule_rounded
                    : Icons.lock_clock_rounded,
                size: 72,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/profiles'),
                child: Text(t ? 'প্রোফাইল পরিবর্তন' : 'Switch Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
