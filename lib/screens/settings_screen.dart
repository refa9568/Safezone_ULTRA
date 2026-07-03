import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'সেটিংস' : 'Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(t ? 'বাংলা ভাষা' : 'Bengali Language'),
            subtitle: Text(t ? 'পুরো অ্যাপে বাংলা দেখান' : 'Show the app in Bengali'),
            value: state.bengali,
            onChanged: (_) => state.toggleLanguage(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(t ? 'অ্যাকাউন্ট পরিচালনা' : 'Account Management'),
            subtitle: Text(state.parent.email),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(t ? 'বিজ্ঞপ্তি পছন্দ' : 'Notification Preferences'),
            subtitle: Text(t ? 'অ্যাপ চালু হলে সতর্ক করুন' : 'Alert on app launch'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t ? 'সম্পর্কে' : 'About'),
            subtitle: const Text('SafeZone Ultra v1.0.0'),
          ),
        ],
      ),
    );
  }
}
