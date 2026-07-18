import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';

class LessonListScreen extends StatelessWidget {
  final bool embedded;
  const LessonListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'পাঠ মডিউল' : 'Lesson Modules'),
        automaticallyImplyLeading: !embedded,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.modules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final module = MockData.modules[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 26,
                child: Text(_emoji(module.category), style: const TextStyle(fontSize: 24)),
              ),
              title: Text(t ? module.titleBn : module.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(t ? module.summaryBn : module.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/lesson-player', arguments: module),
            ),
          );
        },
      ),
    );
  }

  String _emoji(HazardCategory category) {
    switch (category) {
      case HazardCategory.fire:
        return '🔥';
      case HazardCategory.flood:
        return '🌊';
      case HazardCategory.earthquake:
        return '🌍';
      case HazardCategory.stranger:
        return '🚸';
    }
  }
}
