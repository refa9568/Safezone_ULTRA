import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/backend/auth_service.dart';
import 'package:safezone_ultra/logic/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _deleting = false;

  Future<void> _editEmergencyPhone(
    BuildContext context,
    AppState state,
    bool t,
  ) async {
    final controller = TextEditingController(text: state.parent.emergencyPhone);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t ? 'জরুরি ফোন নম্বর' : 'Emergency Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+8801XXXXXXXXX',
            labelText: t ? 'ফোন নম্বর' : 'Phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(t ? 'সংরক্ষণ করুন' : 'Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      state.setEmergencyPhone(result);
    }
  }

  Future<void> _editParentPin(
    BuildContext context,
    AppState state,
    bool t,
  ) async {
    final controller = TextEditingController(text: state.parent.parentPin);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t ? 'অভিভাবক পিন পরিবর্তন করুন' : 'Change Parent PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(labelText: t ? 'নতুন পিন' : 'New PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(t ? 'সংরক্ষণ করুন' : 'Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      state.setParentPin(result);
    }
  }

  Future<void> _deleteAccount(AppState state, bool t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t ? 'অ্যাকাউন্ট মুছবেন?' : 'Delete Account?'),
        content: Text(
          t
              ? 'তোমার অ্যাকাউন্ট, সব সন্তানের প্রোফাইল এবং তাদের সব progress স্থায়ীভাবে মুছে যাবে। এটা আর ফিরিয়ে আনা যাবে না।'
              : 'Your account, all child profiles, and all their progress will be permanently deleted. This cannot be undone.',
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
    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      // Wipe Firestore first, then the Auth account itself.
      await state.deleteAllData();
      await _authService.deleteAccount();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authService.friendlyError(e))));
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

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
            subtitle: Text(
              t ? 'পুরো অ্যাপে বাংলা দেখান' : 'Show the app in Bengali',
            ),
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
            leading: const Icon(Icons.lock_outline),
            title: Text(t ? 'অভিভাবক পিন' : 'Parent PIN'),
            subtitle: Text(
              t
                  ? 'ড্যাশবোর্ডে প্রবেশের পিন পরিবর্তন করুন'
                  : 'Change the PIN required to enter this dashboard',
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editParentPin(context, state, t),
          ),
          ListTile(
            leading: const Icon(Icons.sos_rounded, color: Colors.red),
            title: Text(
              t ? 'জরুরি ফোন নম্বর (SOS)' : 'Emergency Phone Number (SOS)',
            ),
            subtitle: Text(
              state.parent.emergencyPhone.isEmpty
                  ? (t ? 'সেট করা হয়নি' : 'Not set')
                  : state.parent.emergencyPhone,
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editEmergencyPhone(context, state, t),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(t ? 'বিজ্ঞপ্তি পছন্দ' : 'Notification Preferences'),
            subtitle: Text(
              t ? 'অ্যাপ চালু হলে সতর্ক করুন' : 'Alert on app launch',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(t ? 'সম্পর্কে' : 'About'),
            subtitle: const Text('SafeZone Ultra v1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: _deleting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              t ? 'অ্যাকাউন্ট মুছে ফেলুন' : 'Delete Account',
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              t
                  ? 'অ্যাকাউন্ট ও সব ডেটা স্থায়ীভাবে মুছে দিন'
                  : 'Permanently delete your account and all data',
            ),
            onTap: _deleting ? null : () => _deleteAccount(state, t),
          ),
        ],
      ),
    );
  }
}
