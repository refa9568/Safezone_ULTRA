import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/content_seeder.dart';
import 'package:safezone_ultra/services/mock_data.dart';
import 'package:safezone_ultra/logic/app_state.dart';

class OfflineContentScreen extends StatefulWidget {
  const OfflineContentScreen({super.key});

  @override
  State<OfflineContentScreen> createState() => _OfflineContentScreenState();
}

class _OfflineContentScreenState extends State<OfflineContentScreen> {
  bool _syncing = false;
  String? _lastSyncError;

  Future<void> _sync(bool t) async {
    setState(() {
      _syncing = true;
      _lastSyncError = null;
    });
    try {
      await ContentSeeder().seedAndLoad();
    } catch (_) {
      _lastSyncError = t
          ? 'সিঙ্ক করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করো।'
          : "Couldn't sync. Check your internet connection.";
    }
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;

    return Scaffold(
      appBar: AppBar(
        title: Text(t ? 'অফলাইন কনটেন্ট' : 'Offline Content Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t
                      ? 'সব পাঠের ছবি ও ভিডিও অ্যাপের সাথেই থাকে, তাই ইন্টারনেট ছাড়াও সবসময় দেখা যায়। শুধু নতুন আপডেট আনতে সিঙ্ক করো।'
                      : "Every lesson's photos and videos are bundled inside the app, so they always work without internet. Sync only pulls in new updates.",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _syncing ? null : () => _sync(t),
                  icon: _syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(
                    _syncing
                        ? (t ? 'সিঙ্ক হচ্ছে...' : 'Syncing...')
                        : (t
                              ? 'সর্বশেষ কনটেন্ট সিঙ্ক করো'
                              : 'Sync Latest Content'),
                  ),
                ),
                if (_lastSyncError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _lastSyncError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                for (final module in MockData.modules)
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(t ? module.titleBn : module.title),
                    subtitle: Text(t ? 'অফলাইনে উপলব্ধ' : 'Available offline'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
