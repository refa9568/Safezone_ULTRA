import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/ui/widgets/child_avatar.dart';

String _formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  final period = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}

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
                      ? 'প্রতিটি সন্তানের জন্য প্রতিদিনের সময়সীমা ও ব্যবহারের সময়সূচি সেট করুন'
                      : "Set each child's daily time limit and allowed schedule",
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

  Future<void> _pickTime(
    BuildContext context,
    AppState state,
    bool isStart,
  ) async {
    final initial = isStart
        ? child.scheduleStartMinutes
        : child.scheduleEndMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    state.setScheduleForChild(
      child,
      enabled: child.scheduleEnabled,
      startMinutes: isStart ? minutes : child.scheduleStartMinutes,
      endMinutes: isStart ? child.scheduleEndMinutes : minutes,
    );
  }

  // Turning the switch on with no window picked would default to
  // 12:00 AM - 11:59 PM (the whole day), which never actually blocks
  // anything. So flipping it on immediately asks for real start/end times
  // instead of silently enabling a no-op schedule.
  Future<void> _enableSchedule(BuildContext context, AppState state) async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (start == null) return;
    if (!context.mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (end == null) return;
    state.setScheduleForChild(
      child,
      enabled: true,
      startMinutes: start.hour * 60 + start.minute,
      endMinutes: end.hour * 60 + end.minute,
    );
  }

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
            const Divider(height: 28),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                t
                    ? 'নির্দিষ্ট সময়সূচি চালু করুন'
                    : 'Restrict to a time window',
              ),
              subtitle: Text(
                t
                    ? 'এই সময়ের বাইরে অ্যাপ ব্যবহার করা যাবে না'
                    : "App can't be used outside this window",
                style: const TextStyle(fontSize: 12),
              ),
              value: child.scheduleEnabled,
              onChanged: (enabled) {
                if (!enabled) {
                  state.setScheduleForChild(
                    child,
                    enabled: false,
                    startMinutes: child.scheduleStartMinutes,
                    endMinutes: child.scheduleEndMinutes,
                  );
                  return;
                }
                _enableSchedule(context, state);
              },
            ),
            if (child.scheduleEnabled)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(context, state, true),
                      child: Text(
                        '${t ? "শুরু" : "Start"}: ${_formatMinutes(child.scheduleStartMinutes)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickTime(context, state, false),
                      child: Text(
                        '${t ? "শেষ" : "End"}: ${_formatMinutes(child.scheduleEndMinutes)}',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
