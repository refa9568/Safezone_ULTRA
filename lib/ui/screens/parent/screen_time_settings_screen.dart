import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/ui/widgets/child_avatar.dart';

class ScreenTimeSettingsScreen extends StatelessWidget {
  const ScreenTimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'স্ক্রিন টাইম সেটিংস' : 'Screen Time Settings'),
      ),
      body: state.children.isEmpty
          ? Center(
              child: Text(
                t ? 'কোনো সন্তান যোগ করা হয়নি' : 'No children added yet',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  t
                      ? 'প্রতিটি সন্তানের জন্য প্রতিদিনের সর্বোচ্চ ব্যবহারের সময় সেট করুন'
                      : "Set each child's daily maximum usage limit",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                for (final child in state.children)
                  _ChildScreenTimeCard(child: child),
              ],
            ),
    );
  }
}

class _ChildScreenTimeCard extends StatelessWidget {
  final Child child;
  const _ChildScreenTimeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final limit = child.screenTimeLimitMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ChildAvatar(child: child, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  state.isLocked(child)
                      ? (t ? 'লকড' : 'Locked')
                      : (t ? 'সক্রিয়' : 'Active'),
                  style: TextStyle(
                    color: state.isLocked(child) ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '$limit',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                t ? 'মিনিট / দিন' : 'minutes / day',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Slider(
              value: limit.toDouble(),
              min: 15,
              max: 180,
              divisions: 33,
              label: '$limit min',
              onChanged: (value) =>
                  state.setScreenTimeLimitForChild(child, value.round()),
            ),
            Text(
              '${child.usedMinutesToday} / $limit ${t ? "মিনিট ব্যবহৃত" : "min used today"}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
