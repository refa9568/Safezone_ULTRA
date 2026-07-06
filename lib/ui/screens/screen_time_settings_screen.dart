import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/app_state.dart';

class ScreenTimeSettingsScreen extends StatelessWidget {
  const ScreenTimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final limit = state.parent.screenTimeLimitMinutes;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'স্ক্রিন টাইম সেটিংস' : 'Screen Time Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t ? 'প্রতিদিনের সর্বোচ্চ ব্যবহারের সময় সেট করুন' : 'Set the daily maximum usage limit',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text('$limit', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold)),
            ),
            Center(child: Text(t ? 'মিনিট / দিন' : 'minutes / day', style: const TextStyle(color: Colors.grey))),
            Slider(
              value: limit.toDouble(),
              min: 15,
              max: 180,
              divisions: 33,
              label: '$limit min',
              onChanged: (value) => state.setScreenTimeLimit(value.round()),
            ),
            const SizedBox(height: 24),
            for (final child in state.children)
              Card(
                child: ListTile(
                  leading: Text(child.avatarEmoji, style: const TextStyle(fontSize: 24)),
                  title: Text(child.name),
                  subtitle: Text('${child.usedMinutesToday} / $limit ${t ? "মিনিট ব্যবহৃত" : "min used today"}'),
                  trailing: Text(
                    state.isLocked(child) ? (t ? 'লকড' : 'Locked') : (t ? 'সক্রিয়' : 'Active'),
                    style: TextStyle(
                      color: state.isLocked(child) ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
