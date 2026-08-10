import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:safezone_ultra/logic/app_state.dart';
import 'package:safezone_ultra/ui/theme/app_theme.dart';
import 'package:safezone_ultra/ui/widgets/child_avatar.dart';
import 'package:safezone_ultra/ui/widgets/floating_bubbles.dart';

class ChildOwnProfileScreen extends StatelessWidget {
  const ChildOwnProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context, AppState state) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    state.updateChildPhoto(state.activeChild!, base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final child = state.activeChild!;
    final t = state.bengali;
    final stars = state
        .resultsForChild(child.id)
        .fold<int>(0, (sum, r) => sum + r.stars);
    final badgeCount = state.badgesForChild(child.id).length;

    return Scaffold(
      appBar: AppBar(title: Text(t ? 'আমার প্রোফাইল' : 'My Profile')),
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles(count: 10)),
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    ChildAvatar(child: child, radius: 56),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => _changePhoto(context, state),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${t ? 'বয়স' : 'Age'} ${child.age}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      value: '$stars',
                      label: t ? 'তারা' : 'Stars',
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.emoji_events_rounded,
                      value: '$badgeCount',
                      label: t ? 'ব্যাজ' : 'Badges',
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/badges'),
                icon: const Icon(Icons.emoji_events_rounded),
                label: Text(t ? 'অর্জনসমূহ দেখো 🏆' : 'View My Achievements 🏆'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
