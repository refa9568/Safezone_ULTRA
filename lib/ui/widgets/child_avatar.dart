import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:safezone_ultra/models/models.dart';

/// Shows the child's uploaded photo when available, falling back to their
/// emoji avatar otherwise.
class ChildAvatar extends StatelessWidget {
  final Child child;
  final double radius;

  const ChildAvatar({super.key, required this.child, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final photo = child.photoBase64;
    if (photo != null && photo.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(base64Decode(photo)),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        child.avatarEmoji,
        style: TextStyle(fontSize: radius * 0.9),
      ),
    );
  }
}
