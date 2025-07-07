import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/screens/bus_list_screen.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await TestSetup.initialize();
  });

  group('BusListScreen Basic Widget Tests', () {
    testWidgets('should build without errors', (WidgetTester tester) async {
      // Ensure proper test setup
      await tester.pumpWithSetup(
        const MaterialApp(
          home: BusListScreen(),
        ),
      );

      // Just verify the widget builds
      expect(find.byType(BusListScreen), findsOneWidget);
    });

    testWidgets('should display app bar', (WidgetTester tester) async {
      await tester.pumpWithSetup(
        const MaterialApp(
          home: BusListScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}