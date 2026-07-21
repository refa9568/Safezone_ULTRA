import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../logic/app_state.dart';
import '../widgets/floating_bubbles.dart';

const List<List<Color>> _kidCardColors = [
  [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
  [Color(0xFFB2EBF2), Color(0xFF80DEEA)],
  [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
  [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
];

class ChildProfileSelectScreen extends StatelessWidget {
  const ChildProfileSelectScreen({super.key});

  Future<void> _requestParentAccess(BuildContext context, AppState state, bool t) async {
    final controller = TextEditingController();
    String? errorText;

    final unlocked = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(t ? 'অভিভাবক পিন দিন' : 'Enter Parent PIN'),
          content: TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: t ? 'পিন' : 'PIN',
              errorText: errorText,
            ),
            onSubmitted: (_) {
              if (state.verifyParentPin(controller.text.trim())) {
                Navigator.pop(dialogContext, true);
              } else {
                setDialogState(() => errorText = t ? 'ভুল পিন' : 'Incorrect PIN');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (state.verifyParentPin(controller.text.trim())) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setDialogState(() => errorText = t ? 'ভুল পিন' : 'Incorrect PIN');
                }
              },
              child: Text(t ? 'প্রবেশ করুন' : 'Enter'),
            ),
          ],
        ),
      ),
    );

    if (unlocked == true && context.mounted) {
      state.enterParentMode();
      Navigator.pushReplacementNamed(context, '/parent');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.bengali;
    return Scaffold(
      appBar: AppBar(title: Text(t ? 'কে খেলছে? 🎮' : 'Who\'s Playing? 🎮')),
      body: Stack(
        children: [
          const Positioned.fill(child: FloatingBubbles(count: 12)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      for (int i = 0; i < state.children.length; i++)
                        _ChildCard(
                          child: state.children[i],
                          colors: _kidCardColors[i % _kidCardColors.length],
                          onTap: () {
                            state.selectChild(state.children[i]);
                            Navigator.pushReplacementNamed(context, '/child');
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _requestParentAccess(context, state, t),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: Text(t ? 'অভিভাবক ড্যাশবোর্ড' : 'Parent Dashboard'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatefulWidget {
  final Child child;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ChildCard({required this.child, required this.colors, required this.onTap});

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.child.avatarEmoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Text(
                widget.child.name,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text('Age ${widget.child.age}', style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}
