// Dev-only script: dumps every lesson line (English + Bengali) that needs
// pre-recorded narration audio, as JSON, so a separate script can synthesize
// each one exactly once and bundle it as a static asset. Not shipped in the
// app. Run with: dart run tool/export_lesson_audio_manifest.dart
import 'dart:convert';
import 'dart:io';

import 'package:safezone_ultra/data/earthquake_data.dart';
import 'package:safezone_ultra/data/fire_data.dart';
import 'package:safezone_ultra/data/flood_data.dart';
import 'package:safezone_ultra/data/stranger_data.dart';

void main() {
  final modules = [fireModule, floodModule, earthquakeModule, strangerModule];
  final entries = <Map<String, String>>[];

  for (final m in modules) {
    final cat = m.category.name;
    for (var i = 0; i < m.steps.length; i++) {
      entries.add({
        'path': 'lessons/$cat/audio/step_${i + 1}_en.mp3',
        'text': m.steps[i],
        'lang': 'en',
      });
    }
    for (var i = 0; i < m.stepsBn.length; i++) {
      entries.add({
        'path': 'lessons/$cat/audio/step_${i + 1}_bn.mp3',
        'text': m.stepsBn[i],
        'lang': 'bn',
      });
    }
    entries.add({
      'path': 'lessons/$cat/audio/summary_en.mp3',
      'text': m.summary,
      'lang': 'en',
    });
    entries.add({
      'path': 'lessons/$cat/audio/summary_bn.mp3',
      'text': m.summaryBn,
      'lang': 'bn',
    });
  }

  File(
    'lesson_audio_manifest.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(entries));
  stderr.writeln('Wrote ${entries.length} entries.');
}
