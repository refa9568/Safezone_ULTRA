import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/models/models.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/screens/parent/notification_center_screen.dart';

class ParentShell extends StatelessWidget {
  const ParentShell({super.key});

  Future<void> _showAddChildDialog(
    BuildContext context,
    AppState state,
    bool t,
  ) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String sex = 'Female';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(t ? 'সন্তান যোগ করুন' : 'Add Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: t ? 'নাম' : 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t ? 'বয়স' : 'Age'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: sex,
                decoration: InputDecoration(labelText: t ? 'লিঙ্গ' : 'Sex'),
                items: [
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text(t ? 'নারী' : 'Female'),
                  ),
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text(t ? 'পুরুষ' : 'Male'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text(t ? 'অন্যান্য' : 'Other'),
                  ),
                ],
                onChanged: (v) => setState(() => sex = v ?? sex),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final age = int.tryParse(ageController.text.trim());
                if (name.isEmpty || age == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        t
                            ? 'নাম এবং বয়স সঠিকভাবে লিখুন'
                            : 'Enter a valid name and age',
                      ),
                    ),
                  );
                  return;
                }
                state.addChildProfile(name: name, age: age, sex: sex);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      t
                          ? '$name প্রোফাইল তৈরি হয়েছে'
                          : '$name profile created',
                    ),
                  ),
                );
              },
              child: Text(t ? 'সংরক্ষণ করুন' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

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
              MaterialPageRoute(
                builder: (_) => const NotificationCenterScreen(),
              ),
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
                    Text(
                      state.parent.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      state.parent.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_rounded),
                title: Text(
                  t ? 'শিশুদের স্ক্রিনে ফিরে যান' : 'Back to Kids Screen',
                ),
                onTap: () {
                  state.parentMode = false;
                  Navigator.pushReplacementNamed(context, '/profiles');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: Text(t ? 'সন্তান যোগ করুন' : 'Add Child'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddChildDialog(context, state, t);
                },
              ),
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
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (r) => false,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context, state, t),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(t ? 'সন্তান যোগ করুন' : 'Add Child'),
        backgroundColor: AppTheme.secondary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            t ? 'সন্তানদের অগ্রগতি' : "Children's Progress",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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

  Future<void> _confirmDelete(
    BuildContext context,
    AppState state,
    bool t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t ? 'সন্তান মুছবেন?' : 'Delete Child?'),
        content: Text(
          t
              ? '${child.name}-এর প্রোফাইল এবং সমস্ত অগ্রগতি স্থায়ীভাবে মুছে যাবে।'
              : "${child.name}'s profile and all progress will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t ? 'মুছুন' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      state.removeChildProfile(child.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t
                ? '${child.name} প্রোফাইল মুছে ফেলা হয়েছে'
                : "${child.name}'s profile deleted",
          ),
        ),
      );
    }
  }

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
        leading: CircleAvatar(
          radius: 24,
          child: Text(child.avatarEmoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          child.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${results.length} ${t ? "টি কুইজ" : "quizzes"} • ${badges.length} ${t ? "ব্যাজ" : "badges"} • $remaining ${t ? "মিনিট বাকি" : "min left"}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: t ? 'মুছুন' : 'Delete',
              onPressed: () => _confirmDelete(context, state, t),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.secondary,
              size: 28,
            ),
          ],
        ),
        onTap: () =>
            Navigator.pushNamed(context, '/child-progress', arguments: child),
      ),
    );
  }
}
