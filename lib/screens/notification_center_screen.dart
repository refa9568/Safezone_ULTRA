import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    final notifications = state.notifications;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'বিজ্ঞপ্তি কেন্দ্র' : 'Notification Center')),
      body: notifications.isEmpty
          ? Center(child: Text(t ? 'কোনো বিজ্ঞপ্তি নেই' : 'No notifications yet', style: const TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: Icon(
                    n.isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: n.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(n.message),
                  subtitle: Text('${n.sentAt.hour}:${n.sentAt.minute.toString().padLeft(2, '0')}'),
                  onTap: () => state.markNotificationRead(n.id),
                );
              },
            ),
    );
  }
}
