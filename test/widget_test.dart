import 'package:flutter_test/flutter_test.dart';

import 'package:safezone_ultra/main.dart';

void main() {
  testWidgets('App launches to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeZoneUltraApp());
    expect(find.text('SafeZone Ultra'), findsOneWidget);
  });
}
