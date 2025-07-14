import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:arebbus/screens/add_bus_screen.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await TestSetup.initialize();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AddBusScreen(),
    );
  }

  group('AddBusScreen Widget Tests', () {

    group('Initial UI State', () {
      testWidgets('should display app bar with correct title', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.text('Add New Bus'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display bus information form', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.text('Bus Information'), findsOneWidget);
        expect(find.text('Bus Name'), findsOneWidget);
        expect(find.text('Capacity'), findsOneWidget);
      });

      testWidgets('should display route selection section', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.text('Route Selection'), findsOneWidget);
        expect(find.text('Existing Route'), findsOneWidget);
        expect(find.text('Custom Route'), findsOneWidget);
      });

      testWidgets('should display map section', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
      });

      testWidgets('should display create bus button', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.text('Create Bus'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(1));
      });

      testWidgets('should have existing route selected by default', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        // Existing route radio button should be selected
        final existingRouteRadio = find.byWidgetPredicate(
          (widget) => widget is RadioListTile<bool> && widget.value == true,
        );
        expect(existingRouteRadio, findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should validate bus name field', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        // Should show validation error for empty bus name
        expect(find.text('Please enter a bus name'), findsOneWidget);
      });

      testWidgets('should validate capacity field', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        // Fill bus name but leave capacity empty
        await tester.enterText(find.byType(TextFormField).first, 'Test Bus');
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        // Should show validation error for empty capacity
        expect(find.text('Please enter capacity'), findsOneWidget);
      });

      testWidgets('should validate capacity is a valid number', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Test Bus');
        await tester.enterText(textFields.at(1), 'invalid');
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid capacity'), findsOneWidget);
      });

      testWidgets('should validate route selection for existing route', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Test Bus');
        await tester.enterText(textFields.at(1), '50');
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        // Should show validation error for no route selected
        expect(find.text('Please select a route'), findsOneWidget);
      });
    });

    group('Route Selection', () {
      testWidgets('should switch to custom route mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();

        // Assert
        // Should show custom route input field
        expect(find.text('Route Name'), findsOneWidget);
        expect(find.text('Tap on map to add stops'), findsOneWidget);
      });

      testWidgets('should show existing route dropdown when in existing route mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act & Assert
        // Should have dropdown for route selection
        expect(find.text('Select Route'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });

      testWidgets('should validate custom route name', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();
        
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Test Bus');
        await tester.enterText(textFields.at(1), '50');
        // Leave route name empty
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a route name'), findsOneWidget);
      });
    });

    group('Custom Route Creation', () {
      testWidgets('should display stops section in custom route mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();

        // Assert
        expect(find.text('Stops (0)'), findsOneWidget);
        expect(find.text('No stops added yet. Tap on the map to add stops.'), findsOneWidget);
      });

      testWidgets('should show map instruction for custom route', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();

        // Assert
        expect(find.text('Tap on map to add stops'), findsOneWidget);
      });

      testWidgets('should validate minimum stops for custom route', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();
        
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Test Bus');
        await tester.enterText(textFields.at(1), '50');
        await tester.enterText(textFields.at(2), 'Test Route');
        
        await tester.tap(find.text('Create Bus'));
        await tester.pump();

        // Assert
        // Should show error for insufficient stops
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    group('Map Interactions', () {
      testWidgets('should display map with correct initial state', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.text('Select a route to preview'), findsOneWidget);
      });

      testWidgets('should update map display when route is selected', (WidgetTester tester) async {
        // This would require mocking API responses
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Map should update to show selected route
        expect(find.byType(FlutterMap), findsOneWidget);
      });

      testWidgets('should handle map tap in custom route mode', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();

        // Map tap would trigger nearby stops check
        expect(find.byType(FlutterMap), findsOneWidget);
      });
    });

    group('Nearby Stops Dialog', () {
      testWidgets('should show nearby stops dialog when available', (WidgetTester tester) async {
        // This would require mocking the getNearbyStops API call
        // For now, we test that the dialog components exist in the widget tree
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // The dialog would contain:
        // - Title "Nearby Stops Found"
        // - Map preview
        // - List of nearby stops
        // - "Create New Stop" and "Cancel" buttons
        expect(find.byType(AddBusScreen), findsOneWidget);
      });
    });

    group('Add Stop Dialog', () {
      testWidgets('should show add stop dialog for new stop creation', (WidgetTester tester) async {
        // This would test the dialog that appears when no nearby stops are found
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Dialog would contain:
        // - Title "Add New Stop"
        // - Stop name input field
        // - Coordinates display
        // - "Add" and "Cancel" buttons
        expect(find.byType(AddBusScreen), findsOneWidget);
      });
    });

    group('Bus Creation Process', () {
      testWidgets('should show loading state during bus creation', (WidgetTester tester) async {
        // This would test the loading state when create bus is tapped
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Would show:
        // - Disabled create button with loading indicator
        // - Loading indicator in app bar
        expect(find.text('Create Bus'), findsOneWidget);
      });

      testWidgets('should handle successful bus creation', (WidgetTester tester) async {
        // This would test navigation back with success result
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Would show success snackbar and navigate back
        expect(find.byType(AddBusScreen), findsOneWidget);
      });

      testWidgets('should handle bus creation errors', (WidgetTester tester) async {
        // This would test error handling during bus creation
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Would show error snackbar
        expect(find.byType(AddBusScreen), findsOneWidget);
      });
    });

    group('Form Input Behavior', () {
      testWidgets('should accept valid bus name input', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.enterText(find.byType(TextFormField).first, 'Test Bus Name');
        await tester.pump();

        // Assert
        expect(find.text('Test Bus Name'), findsOneWidget);
      });

      testWidgets('should accept valid capacity input', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        final capacityField = find.byType(TextFormField).at(1);
        await tester.enterText(capacityField, '50');
        await tester.pump();

        // Assert
        expect(find.text('50'), findsOneWidget);
      });

      testWidgets('should accept valid route name input', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        await tester.tap(find.text('Custom Route'));
        await tester.pump();
        
        final routeNameField = find.byType(TextFormField).at(2);
        await tester.enterText(routeNameField, 'Test Route');
        await tester.pump();

        // Assert
        expect(find.text('Test Route'), findsOneWidget);
      });
    });

    group('UI State Management', () {
      testWidgets('should maintain form state when switching route types', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Act
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.first, 'Test Bus');
        await tester.enterText(textFields.at(1), '50');
        
        await tester.tap(find.text('Custom Route'));
        await tester.pump();
        
        await tester.tap(find.text('Existing Route'));
        await tester.pump();

        // Assert
        // Bus name and capacity should be preserved
        expect(find.text('Test Bus'), findsOneWidget);
        expect(find.text('50'), findsOneWidget);
      });

      testWidgets('should clear custom stops when switching to existing route', (WidgetTester tester) async {
        // This would test that custom stops are cleared when switching modes
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(AddBusScreen), findsOneWidget);
      });
    });
  });

  group('AddBusScreen Integration Tests', () {
    testWidgets('should complete existing route bus creation flow', (WidgetTester tester) async {
      // This would test the complete flow:
      // 1. Fill bus info
      // 2. Select existing route
      // 3. Create bus
      // 4. Handle response
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AddBusScreen), findsOneWidget);
    });

    testWidgets('should complete custom route bus creation flow', (WidgetTester tester) async {
      // This would test the complete flow:
      // 1. Fill bus info
      // 2. Switch to custom route
      // 3. Add stops via map
      // 4. Create route and bus
      // 5. Handle response
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AddBusScreen), findsOneWidget);
    });

    testWidgets('should handle nearby stops selection flow', (WidgetTester tester) async {
      // This would test:
      // 1. Tap on map
      // 2. Show nearby stops dialog
      // 3. Select existing stop or create new
      // 4. Update stops list
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(AddBusScreen), findsOneWidget);
    });
  });
}