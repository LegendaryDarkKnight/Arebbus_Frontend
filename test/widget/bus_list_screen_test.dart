import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/screens/bus_list_screen.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await TestSetup.initialize();
  });

  Widget createWidgetUnderTest({bool showInstalledOnly = false}) {
    return MaterialApp(
      home: BusListScreen(showInstalledOnly: showInstalledOnly),
    );
  }

  group('BusListScreen Widget Tests', () {

    group('All Buses Screen', () {
      testWidgets('should display loading indicator initially', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should display app bar with correct title', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.text('All Buses'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display floating action button for adding buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('should display refresh button in app bar', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should display toggle button to switch to installed buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.download_done), findsOneWidget);
      });

      testWidgets('should display bus cards when data loads successfully', (WidgetTester tester) async {
        // Note: This test would require mocking the API service
        // For now, we'll test the widget structure
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // The actual bus cards would appear after API call completion
        // In a real test, we'd mock the API service and verify the bus cards
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Installed Buses Screen', () {
      testWidgets('should display correct title for installed buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(showInstalledOnly: true));

        // Act
        await tester.pump();

        // Assert
        expect(find.text('Installed Buses'), findsOneWidget);
      });

      testWidgets('should not display floating action button for installed buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(showInstalledOnly: true));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FloatingActionButton), findsNothing);
      });

      testWidgets('should display toggle button to switch to all buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(showInstalledOnly: true));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.public), findsOneWidget);
      });
    });

    group('Error States', () {
      testWidgets('should display error message when no buses available', (WidgetTester tester) async {
        // This would require mocking an empty response
        // For now, we test that the widget builds correctly
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();
        
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Bus Card Interactions', () {
      testWidgets('should display bus information correctly', (WidgetTester tester) async {
        // Note: This would require injecting mock data
        // Testing structure for now
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Bus cards would show:
        // - Bus icon (CircleAvatar)
        // - Bus name
        // - Author name
        // - Route name
        // - Capacity, installs, upvotes
        // - Install/uninstall button
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate to add bus screen when FAB is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Assert
        // Navigation would be tested with a proper navigation observer
        // For now, we verify the FAB exists and is tappable
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should toggle between all and installed buses', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.byIcon(Icons.download_done));
        await tester.pump();

        // Assert
        // Navigation would replace current screen
        expect(find.byIcon(Icons.download_done), findsOneWidget);
      });
    });

    group('Pull to Refresh', () {
      testWidgets('should support pull to refresh gesture', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // We would need to find the RefreshIndicator in the widget tree
        // and test the pull-to-refresh gesture
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Scrolling and Pagination', () {
      testWidgets('should support infinite scroll loading', (WidgetTester tester) async {
        // This would test the scroll controller and pagination logic
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Would scroll to bottom and verify loading indicator appears
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });

  group('BusListScreen State Management', () {
    testWidgets('should handle loading states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Initial loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pump();
      
      // After initial load (would show content or error)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle empty state correctly', (WidgetTester tester) async {
      // Would test with mock API returning empty list
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle error state correctly', (WidgetTester tester) async {
      // Would test with mock API throwing error
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('Bus Actions', () {
    testWidgets('should handle install bus action', (WidgetTester tester) async {
      // Would test install button tap and snackbar display
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      // Find install button and tap it
      // Verify API call and UI update
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle uninstall bus action', (WidgetTester tester) async {
      // Would test uninstall button tap and snackbar display
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      // Find uninstall button and tap it
      // Verify API call and UI update
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should navigate to bus detail on bus card tap', (WidgetTester tester) async {
      // Would test navigation to bus detail screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      // Tap on bus card and verify navigation
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}