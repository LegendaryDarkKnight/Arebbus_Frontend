import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/route.dart';
import '../mocks/mock_api_service.dart';

void main() {
  group('MockApiService Tests', () {
    test('should return mock buses', () {
      // Act
      final bus1 = MockApiService.getBusByIdResponse(1);
      final bus2 = MockApiService.getBusByIdResponse(2);

      // Assert
      expect(bus1, isNotNull);
      expect(bus2, isNotNull);
      expect(bus1!.id, equals(1));
      expect(bus2!.id, equals(2));
      expect(bus1.installed, isTrue);
      expect(bus2.installed, isFalse);
    });

    test('should return mock routes', () {
      // Act
      final route = MockApiService.getRouteByIdResponse(1);

      // Assert
      expect(route, isNotNull);
      expect(route!.id, equals(1));
      expect(route.stops, isNotEmpty);
      expect(route.stops.length, greaterThan(1));
    });

    test('should return nearby stops within radius', () {
      // Arrange
      const testLat = 40.7128;
      const testLon = -74.0060;
      const radiusKm = 5.0;

      // Act
      final nearbyStops = MockApiService.getNearbyStopsResponse(
        latitude: testLat, 
        longitude: testLon, 
        radius: radiusKm
      );

      // Assert
      expect(nearbyStops, isNotEmpty);
    });

    test('should handle bus list response', () {
      // Act
      final busResponse = MockApiService.getAllBusesResponse(page: 0, size: 10);

      // Assert
      expect(busResponse.buses, isA<List<Bus>>());
      expect(busResponse.page, equals(0));
      expect(busResponse.size, equals(10));
      expect(busResponse.totalPages, isA<int>());
      expect(busResponse.totalElements, isA<int>());
    });

    test('should handle route list response', () {
      // Act
      final routeResponse = MockApiService.getAllRoutesResponse(page: 0, size: 10);

      // Assert
      expect(routeResponse.routes, isA<List<Route>>());
      expect(routeResponse.page, equals(0));
      expect(routeResponse.size, equals(10));
      expect(routeResponse.totalPages, isA<int>());
      expect(routeResponse.totalElements, isA<int>());
    });

    test('should create mock stop', () {
      // Act
      final stop = MockApiService.createStopResponse(
        name: 'Test Stop',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      // Assert
      expect(stop.name, equals('Test Stop'));
      expect(stop.latitude, equals(40.7128));
      expect(stop.longitude, equals(-74.0060));
      expect(stop.authorName, equals('Test User'));
    });

    test('should create mock route', () {
      // Act
      final route = MockApiService.createRouteResponse(
        name: 'Test Route',
        stopIds: [1, 2],
      );

      // Assert
      expect(route.name, equals('Test Route'));
      expect(route.stops.length, equals(2));
      expect(route.authorName, equals('Test User'));
    });

    test('should create mock bus', () {
      // Act
      final bus = MockApiService.createBusResponse(
        name: 'Test Bus',
        capacity: 50,
        routeId: 1,
      );

      // Assert
      expect(bus.name, equals('Test Bus'));
      expect(bus.capacity, equals(50));
      expect(bus.authorName, equals('Test User'));
    });
  });
}