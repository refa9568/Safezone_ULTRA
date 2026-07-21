import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
import 'notification_center_screen.dart';

class ParentShell extends StatelessWidget {
  const ParentShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final unread = state.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'অভিভাবক ড্যাশবোর্ড' : 'Parental Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: t ? 'শিশুদের স্ক্রিনে ফিরে যান' : 'Back to Kids Screen',
            onPressed: () {
              state.parentMode = false;
              Navigator.pushReplacementNamed(context, '/profiles');
            },
          ),
          IconButton(
            icon: Badge(
              label: Text('$unread'),
              isLabelVisible: unread > 0,
              child: const Icon(Icons.notifications_rounded),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                    const SizedBox(height: 8),
                    Text(state.parent.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(state.parent.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(t ? 'শিশুদের স্ক্রিনে ফিরে যান' : 'Back to Kids Screen'),
                onTap: () {
                  state.parentMode = false;
                  Navigator.pushReplacementNamed(context, '/profiles');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(t ? 'স্ক্রিন টাইম সেটিংস' : 'Screen Time Settings'),
                onTap: () => Navigator.pushNamed(context, '/screen-time'),
              ),
              ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: Text(t ? 'অফলাইন কনটেন্ট' : 'Offline Content Manager'),
                onTap: () => Navigator.pushNamed(context, '/offline'),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(t ? 'সেটিংস' : 'Settings'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t ? 'লগআউট' : 'Log Out'),
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t ? 'সন্তানদের অগ্রগতি' : "Children's Progress", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final child in state.children) _ChildProgressCard(child: child),
        ],
      ),
    );
  }
}

class _ChildProgressCard extends StatelessWidget {
  final Child child;
  const _ChildProgressCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final results = state.resultsForChild(child.id);
    final badges = state.badgesForChild(child.id);
    final remaining = state.minutesRemaining(child);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(radius: 24, child: Text(child.avatarEmoji, style: const TextStyle(fontSize: 22))),
        title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${results.length} ${t ? "টি কুইজ" : "quizzes"} • ${badges.length} ${t ? "ব্যাজ" : "badges"} • $remaining ${t ? "মিনিট বাকি" : "min left"}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/child-progress', arguments: child),
      ),
    );
  }
}
