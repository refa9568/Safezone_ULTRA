import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_data.dart';
import '../../logic/app_state.dart';

class OfflineContentScreen extends StatefulWidget {
  const OfflineContentScreen({super.key});

  @override
  State<OfflineContentScreen> createState() => _OfflineContentScreenState();
}

class _OfflineContentScreenState extends State<OfflineContentScreen> {
  final Set<String> _downloaded = {'m1', 'm3'};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'অফলাইন কনটেন্ট' : 'Offline Content Manager')),
      body: ListView(
        children: [
          for (final module in MockData.modules)
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(t ? module.titleBn : module.title),
              subtitle: Text(
                _downloaded.contains(module.id)
                    ? (t ? 'অফলাইনে উপলব্ধ' : 'Available offline')
                    : (t ? 'শুধু অনলাইন' : 'Online only'),
              ),
              trailing: IconButton(
                icon: Icon(
                  _downloaded.contains(module.id) ? Icons.delete_outline : Icons.download_rounded,
                ),
                onPressed: () => setState(() {
                  if (_downloaded.contains(module.id)) {
                    _downloaded.remove(module.id);
                  } else {
                    _downloaded.add(module.id);
                  }
                }),
              ),
            ),
        ],
      ),
    );
  }
}
