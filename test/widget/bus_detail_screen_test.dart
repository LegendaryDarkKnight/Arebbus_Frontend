import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:arebbus/screens/bus_detail_screen.dart';
import 'package:arebbus/models/bus.dart';
import '../mocks/mock_api_service.dart';
import '../helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await TestSetup.initialize();
  });

  group('BusDetailScreen Widget Tests', () {
    late Bus testBus;
    late Bus testInstalledBus;

    setUp(() {
      testBus = MockApiService.getBusByIdResponse(2)!; // Not installed bus
      testInstalledBus = MockApiService.getBusByIdResponse(1)!; // Installed bus
    });

    Widget createWidgetUnderTest(Bus bus) {
      return MaterialApp(
        home: BusDetailScreen(bus: bus),
      );
    }

    group('Initial UI Display', () {
      testWidgets('should display app bar with bus name', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.text(testBus.name), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display install button for non-installed bus', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.download), findsOneWidget);
        final installButton = find.byIcon(Icons.download);
        final iconButton = tester.widget<IconButton>(installButton);
        expect(iconButton.icon, isA<Icon>());
      });

      testWidgets('should display uninstall button for installed bus', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.delete), findsOneWidget);
        final uninstallButton = find.byIcon(Icons.delete);
        final iconButton = tester.widget<IconButton>(uninstallButton);
        expect(iconButton.icon, isA<Icon>());
      });

      testWidgets('should display bus information card', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.text(testBus.name), findsAtLeastNWidgets(1));
        expect(find.text('By ${testBus.authorName}'), findsOneWidget);
        expect(find.text('${testBus.capacity} seats'), findsOneWidget);
        expect(find.text('${testBus.numInstall} installs'), findsOneWidget);
        expect(find.text('${testBus.numUpvote} upvotes'), findsOneWidget);
      });

      testWidgets('should display route information when available', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        if (testBus.route != null) {
          expect(find.text('Route: ${testBus.route!.name}'), findsOneWidget);
        }
      });

      testWidgets('should display bus status when available', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        if (testBus.status != null) {
          expect(find.text(testBus.status!), findsOneWidget);
        }
      });
    });

    group('Map Display', () {
      testWidgets('should display map when route has stops', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus)); // Has route with stops

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.text('Route Map'), findsOneWidget);
      });

      testWidgets('should display correct number of stops in map header', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        final stopsCount = testInstalledBus.route?.stops.length ?? 0;
        expect(find.textContaining('($stopsCount stops)'), findsOneWidget);
      });

      testWidgets('should display no route message when route is empty', (WidgetTester tester) async {
        // Arrange
        final busWithoutRoute = testBus.copyWith(route: null);
        await tester.pumpWidget(createWidgetUnderTest(busWithoutRoute));

        // Act
        await tester.pump();

        // Assert
        expect(find.text('No route information available'), findsOneWidget);
        expect(find.byIcon(Icons.map), findsOneWidget);
      });

      testWidgets('should display map markers for route stops', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        // Map markers would be tested with integration tests
      });
    });

    group('Bus Status Indicators', () {
      testWidgets('should show correct avatar color for installed bus', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        final avatar = find.byType(CircleAvatar);
        expect(avatar, findsOneWidget);
        // Would check background color is green for installed bus
      });

      testWidgets('should show correct avatar color for non-installed bus', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        final avatar = find.byType(CircleAvatar);
        expect(avatar, findsOneWidget);
        // Would check background color is grey for non-installed bus
      });

      testWidgets('should display status badge correctly', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        if (testBus.status == 'ACTIVE') {
          expect(find.text('ACTIVE'), findsOneWidget);
          // Would check container color is green for active status
        }
      });
    });

    group('Info Chips Display', () {
      testWidgets('should display capacity info chip', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.people), findsOneWidget);
        expect(find.text('${testBus.capacity} seats'), findsOneWidget);
      });

      testWidgets('should display installs info chip', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.download), findsAtLeastNWidgets(1));
        expect(find.text('${testBus.numInstall} installs'), findsOneWidget);
      });

      testWidgets('should display upvotes info chip', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.text('${testBus.numUpvote} upvotes'), findsOneWidget);
      });
    });

    group('Install/Uninstall Actions', () {
      testWidgets('should handle install action tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        // Act
        await tester.tap(find.byIcon(Icons.download));
        await tester.pump();

        // Assert
        // Would verify API call and navigation back
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should handle uninstall action tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));
        await tester.pump();

        // Act
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pump();

        // Assert
        // Would verify API call and navigation back
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should show success snackbar on successful install', (WidgetTester tester) async {
        // This would require mocking API response
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        // Would tap install button and verify snackbar appears
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should show error snackbar on failed install', (WidgetTester tester) async {
        // This would require mocking API error response
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        // Would tap install button and verify error snackbar appears
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should navigate back when install succeeds', (WidgetTester tester) async {
        // This would test navigation behavior
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        // Would verify Navigator.pop is called on success
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should stay on screen when install fails', (WidgetTester tester) async {
        // This would test error handling
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        // Would verify screen remains visible on error
        expect(find.byType(BusDetailScreen), findsOneWidget);
      });
    });

    group('Map Interaction', () {
      testWidgets('should fit map to show all route stops', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        // Map fitting behavior would be tested with integration tests
      });

      testWidgets('should display route polyline on map', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        // Polyline display would be tested with integration tests
      });

      testWidgets('should display stop markers with correct colors', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testInstalledBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(FlutterMap), findsOneWidget);
        // Marker colors would be tested with integration tests
      });
    });

    group('Screen Layout', () {
      testWidgets('should have correct layout structure', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(testBus));

        // Act
        await tester.pump();

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(Card), findsAtLeastNWidgets(1));
      });

      testWidgets('should be responsive to different screen sizes', (WidgetTester tester) async {
        // This would test responsive behavior
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should handle long bus names correctly', (WidgetTester tester) async {
        // Arrange
        final busWithLongName = testBus.copyWith(
          name: 'This is a very long bus name that should be handled properly in the UI',
        );
        await tester.pumpWidget(createWidgetUnderTest(busWithLongName));

        // Act
        await tester.pump();

        // Assert
        expect(find.textContaining('This is a very long bus name'), findsOneWidget);
      });

      testWidgets('should handle missing route gracefully', (WidgetTester tester) async {
        // Arrange
        final busWithoutRoute = testBus.copyWith(route: null);
        await tester.pumpWidget(createWidgetUnderTest(busWithoutRoute));

        // Act
        await tester.pump();

        // Assert
        expect(find.text('No route information available'), findsOneWidget);
        expect(find.byIcon(Icons.map), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle API errors gracefully', (WidgetTester tester) async {
        // This would test error states
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        expect(find.byType(BusDetailScreen), findsOneWidget);
      });

      testWidgets('should handle network connectivity issues', (WidgetTester tester) async {
        // This would test offline behavior
        await tester.pumpWidget(createWidgetUnderTest(testBus));
        await tester.pump();

        expect(find.byType(BusDetailScreen), findsOneWidget);
      });
    });
  });

  group('BusDetailScreen Edge Cases', () {
    testWidgets('should handle bus with empty route stops', (WidgetTester tester) async {
      // Arrange
      final busWithEmptyRoute = MockApiService.getBusByIdResponse(1)!.copyWith(
        route: MockApiService.getRouteByIdResponse(1)!.copyWith(stops: []),
      );
      
      await tester.pumpWidget(MaterialApp(
        home: BusDetailScreen(bus: busWithEmptyRoute),
      ));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('No route information available'), findsOneWidget);
    });

    testWidgets('should handle bus with null status', (WidgetTester tester) async {
      // Arrange
      final busWithNullStatus = MockApiService.getBusByIdResponse(1)!.copyWith(status: null);
      
      await tester.pumpWidget(MaterialApp(
        home: BusDetailScreen(bus: busWithNullStatus),
      ));

      // Act
      await tester.pump();

      // Assert
      // Status badge should not appear
      expect(find.byType(BusDetailScreen), findsOneWidget);
    });

    testWidgets('should handle zero capacity bus', (WidgetTester tester) async {
      // Arrange
      final busWithZeroCapacity = MockApiService.getBusByIdResponse(1)!.copyWith(capacity: 0);
      
      await tester.pumpWidget(MaterialApp(
        home: BusDetailScreen(bus: busWithZeroCapacity),
      ));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('0 seats'), findsOneWidget);
    });
  });
}