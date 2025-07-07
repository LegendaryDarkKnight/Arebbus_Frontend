import 'package:flutter_test/flutter_test.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/bus_response.dart';
import 'package:arebbus/models/route.dart';
import 'package:arebbus/models/route_response.dart';
import 'package:arebbus/models/stop.dart';
import '../mocks/mock_api_service.dart';

void main() {
  group('MockApiService Bus Methods', () {

    group('getAllBuses', () {
      test('should return BusResponse with correct data', () async {
        // Arrange
        final expectedResponse = MockApiService.getAllBusesResponse(page: 0, size: 10);

        // Act & Assert
        expect(expectedResponse.buses.length, 2);
        expect(expectedResponse.page, 0);
        expect(expectedResponse.size, 10);
        expect(expectedResponse.totalElements, 2);
        expect(expectedResponse.buses.first.name, "Express Bus 101");
        expect(expectedResponse.buses.first.installed, true);
        expect(expectedResponse.buses.last.name, "Airport Shuttle");
        expect(expectedResponse.buses.last.installed, false);
      });

      test('should handle pagination correctly', () async {
        // Arrange
        final firstPageResponse = MockApiService.getAllBusesResponse(page: 0, size: 1);
        final secondPageResponse = MockApiService.getAllBusesResponse(page: 1, size: 1);

        // Act & Assert
        expect(firstPageResponse.buses.length, 1);
        expect(firstPageResponse.buses.first.name, "Express Bus 101");
        
        expect(secondPageResponse.buses.length, 1);
        expect(secondPageResponse.buses.first.name, "Airport Shuttle");
      });

      test('should return empty list for page beyond available data', () async {
        // Arrange
        final emptyPageResponse = MockApiService.getAllBusesResponse(page: 10, size: 10);

        // Act & Assert
        expect(emptyPageResponse.buses.length, 0);
        expect(emptyPageResponse.page, 10);
        expect(emptyPageResponse.totalElements, 2);
      });
    });

    group('getInstalledBuses', () {
      test('should return only installed buses', () async {
        // Arrange
        final installedBusesResponse = MockApiService.getInstalledBusesResponse();

        // Act & Assert
        expect(installedBusesResponse.buses.length, 1);
        expect(installedBusesResponse.buses.first.name, "Express Bus 101");
        expect(installedBusesResponse.buses.first.installed, true);
        expect(installedBusesResponse.totalElements, 1);
      });
    });

    group('getBusById', () {
      test('should return correct bus when ID exists', () async {
        // Arrange
        const busId = 1;
        final bus = MockApiService.getBusByIdResponse(busId);

        // Act & Assert
        expect(bus, isNotNull);
        expect(bus!.id, busId);
        expect(bus.name, "Express Bus 101");
        expect(bus.capacity, 50);
        expect(bus.route, isNotNull);
        expect(bus.route!.name, "Downtown Express");
      });

      test('should return null when bus ID does not exist', () async {
        // Arrange
        const nonExistentId = 999;
        final bus = MockApiService.getBusByIdResponse(nonExistentId);

        // Act & Assert
        expect(bus, isNull);
      });
    });

    group('createBus', () {
      test('should create bus with correct data', () async {
        // Arrange
        const busName = "Test Bus";
        const routeId = 1;
        const capacity = 40;

        // Act
        final createdBus = MockApiService.createBusResponse(
          name: busName,
          routeId: routeId,
          capacity: capacity,
        );

        // Assert
        expect(createdBus.name, busName);
        expect(createdBus.capacity, capacity);
        expect(createdBus.route!.id, routeId);
        expect(createdBus.authorName, "Test User");
        expect(createdBus.numInstall, 0);
        expect(createdBus.numUpvote, 0);
        expect(createdBus.installed, false);
        expect(createdBus.upvoted, false);
      });
    });

    group('installBus', () {
      test('should return success response for valid bus ID', () async {
        // Arrange
        const busId = 1;

        // Act
        final response = MockApiService.installBusResponse(busId);

        // Assert
        expect(response['busId'], busId);
        expect(response['busName'], "Express Bus 101");
        expect(response['message'], "Bus installed successfully");
        expect(response['installed'], true);
      });

      test('should handle non-existent bus ID', () async {
        // Arrange
        const nonExistentId = 999;

        // Act
        final response = MockApiService.installBusResponse(nonExistentId);

        // Assert
        expect(response['busId'], nonExistentId);
        expect(response['busName'], "Unknown Bus");
        expect(response['installed'], true);
      });
    });

    group('uninstallBus', () {
      test('should return success response for valid bus ID', () async {
        // Arrange
        const busId = 1;

        // Act
        final response = MockApiService.uninstallBusResponse(busId);

        // Assert
        expect(response['busId'], busId);
        expect(response['busName'], "Express Bus 101");
        expect(response['message'], "Bus uninstalled successfully");
        expect(response['installed'], false);
      });
    });
  });

  group('MockApiService Route Methods', () {
    group('getAllRoutes', () {
      test('should return RouteResponse with correct data', () async {
        // Arrange
        final routesResponse = MockApiService.getAllRoutesResponse();

        // Act & Assert
        expect(routesResponse.routes.length, 2);
        expect(routesResponse.routes.first.name, "Downtown Express");
        expect(routesResponse.routes.first.stops.length, 4);
        expect(routesResponse.routes.last.name, "Airport Shuttle");
        expect(routesResponse.routes.last.stops.length, 2);
      });

      test('should handle pagination for routes', () async {
        // Arrange
        final firstPageResponse = MockApiService.getAllRoutesResponse(page: 0, size: 1);

        // Act & Assert
        expect(firstPageResponse.routes.length, 1);
        expect(firstPageResponse.page, 0);
        expect(firstPageResponse.totalElements, 2);
        expect(firstPageResponse.totalPages, 2);
      });
    });

    group('getRouteById', () {
      test('should return correct route when ID exists', () async {
        // Arrange
        const routeId = 1;
        final route = MockApiService.getRouteByIdResponse(routeId);

        // Act & Assert
        expect(route, isNotNull);
        expect(route!.id, routeId);
        expect(route.name, "Downtown Express");
        expect(route.authorName, "John Doe");
        expect(route.stops.length, 4);
        expect(route.stops.first.name, "Central Bus Station");
      });

      test('should return null when route ID does not exist', () async {
        // Arrange
        const nonExistentId = 999;
        final route = MockApiService.getRouteByIdResponse(nonExistentId);

        // Act & Assert
        expect(route, isNull);
      });
    });

    group('createRoute', () {
      test('should create route with valid stop IDs', () async {
        // Arrange
        const routeName = "Test Route";
        const stopIds = [1, 2, 3];

        // Act
        final createdRoute = MockApiService.createRouteResponse(
          name: routeName,
          stopIds: stopIds,
        );

        // Assert
        expect(createdRoute.name, routeName);
        expect(createdRoute.authorName, "Test User");
        expect(createdRoute.stops.length, stopIds.length);
        expect(createdRoute.stops.first.id, 1);
        expect(createdRoute.stops.last.id, 3);
      });
    });
  });

  group('MockApiService Stop Methods', () {
    group('getStopById', () {
      test('should return correct stop when ID exists', () async {
        // Arrange
        const stopId = 1;
        final stop = MockApiService.getStopByIdResponse(stopId);

        // Act & Assert
        expect(stop, isNotNull);
        expect(stop!.id, stopId);
        expect(stop.name, "Central Bus Station");
        expect(stop.latitude, 40.7128);
        expect(stop.longitude, -74.0060);
        expect(stop.authorName, "John Doe");
      });

      test('should return null when stop ID does not exist', () async {
        // Arrange
        const nonExistentId = 999;
        final stop = MockApiService.getStopByIdResponse(nonExistentId);

        // Act & Assert
        expect(stop, isNull);
      });
    });

    group('createStop', () {
      test('should create stop with correct data', () async {
        // Arrange
        const stopName = "Test Stop";
        const latitude = 40.7500;
        const longitude = -73.9900;

        // Act
        final createdStop = MockApiService.createStopResponse(
          name: stopName,
          latitude: latitude,
          longitude: longitude,
        );

        // Assert
        expect(createdStop.name, stopName);
        expect(createdStop.latitude, latitude);
        expect(createdStop.longitude, longitude);
        expect(createdStop.authorName, "Test User");
        expect(createdStop.id, isNotNull);
      });
    });

    group('getNearbyStops', () {
      test('should return stops within specified radius', () async {
        // Arrange - Location near Central Bus Station
        const testLatitude = 40.7130;
        const testLongitude = -74.0062;
        const radius = 3.0;

        // Act
        final nearbyStops = MockApiService.getNearbyStopsResponse(
          latitude: testLatitude,
          longitude: testLongitude,
          radius: radius,
        );

        // Assert
        expect(nearbyStops.isNotEmpty, true);
        // Central Bus Station should be nearby
        expect(nearbyStops.any((stop) => stop.name == "Central Bus Station"), true);
      });

      test('should return empty list when no stops within radius', () async {
        // Arrange - Location far from any stops
        const testLatitude = 50.0;
        const testLongitude = -80.0;
        const radius = 1.0;

        // Act
        final nearbyStops = MockApiService.getNearbyStopsResponse(
          latitude: testLatitude,
          longitude: testLongitude,
          radius: radius,
        );

        // Assert
        expect(nearbyStops.isEmpty, true);
      });

      test('should return more stops with larger radius', () async {
        // Arrange - NYC area
        const testLatitude = 40.7128;
        const testLongitude = -74.0060;

        // Act
        final smallRadiusStops = MockApiService.getNearbyStopsResponse(
          latitude: testLatitude,
          longitude: testLongitude,
          radius: 1.0,
        );
        
        final largeRadiusStops = MockApiService.getNearbyStopsResponse(
          latitude: testLatitude,
          longitude: testLongitude,
          radius: 10.0,
        );

        // Assert
        expect(largeRadiusStops.length >= smallRadiusStops.length, true);
      });
    });
  });

  group('Model Tests', () {
    group('Bus Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final originalBus = MockApiService.getBusByIdResponse(1)!;

        // Act
        final json = originalBus.toJson();
        final deserializedBus = Bus.fromJson(json);

        // Assert
        expect(deserializedBus.id, originalBus.id);
        expect(deserializedBus.name, originalBus.name);
        expect(deserializedBus.capacity, originalBus.capacity);
        expect(deserializedBus.installed, originalBus.installed);
        expect(deserializedBus.upvoted, originalBus.upvoted);
      });

      test('should handle copyWith correctly', () {
        // Arrange
        final originalBus = MockApiService.getBusByIdResponse(1)!;

        // Act
        final modifiedBus = originalBus.copyWith(
          name: "Modified Bus",
          installed: !originalBus.installed,
        );

        // Assert
        expect(modifiedBus.name, "Modified Bus");
        expect(modifiedBus.installed, !originalBus.installed);
        expect(modifiedBus.id, originalBus.id); // Should remain unchanged
        expect(modifiedBus.capacity, originalBus.capacity); // Should remain unchanged
      });
    });

    group('Route Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final originalRoute = MockApiService.getRouteByIdResponse(1)!;

        // Act
        final json = originalRoute.toJson();
        final deserializedRoute = Route.fromJson(json);

        // Assert
        expect(deserializedRoute.id, originalRoute.id);
        expect(deserializedRoute.name, originalRoute.name);
        expect(deserializedRoute.authorName, originalRoute.authorName);
        expect(deserializedRoute.stops.length, originalRoute.stops.length);
      });
    });

    group('Stop Model', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final originalStop = MockApiService.getStopByIdResponse(1)!;

        // Act
        final json = originalStop.toJson();
        final deserializedStop = Stop.fromJson(json);

        // Assert
        expect(deserializedStop.id, originalStop.id);
        expect(deserializedStop.name, originalStop.name);
        expect(deserializedStop.latitude, originalStop.latitude);
        expect(deserializedStop.longitude, originalStop.longitude);
        expect(deserializedStop.authorName, originalStop.authorName);
      });

      test('should handle copyWith correctly', () {
        // Arrange
        final originalStop = MockApiService.getStopByIdResponse(1)!;

        // Act
        final modifiedStop = originalStop.copyWith(
          name: "Modified Stop",
          latitude: 41.0,
        );

        // Assert
        expect(modifiedStop.name, "Modified Stop");
        expect(modifiedStop.latitude, 41.0);
        expect(modifiedStop.id, originalStop.id); // Should remain unchanged
        expect(modifiedStop.longitude, originalStop.longitude); // Should remain unchanged
      });
    });
  });

  group('Response Models', () {
    group('BusResponse', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final originalResponse = MockApiService.getAllBusesResponse();

        // Act
        final json = originalResponse.toJson();
        final deserializedResponse = BusResponse.fromJson(json);

        // Assert
        expect(deserializedResponse.buses.length, originalResponse.buses.length);
        expect(deserializedResponse.page, originalResponse.page);
        expect(deserializedResponse.size, originalResponse.size);
        expect(deserializedResponse.totalPages, originalResponse.totalPages);
        expect(deserializedResponse.totalElements, originalResponse.totalElements);
      });
    });

    group('RouteResponse', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final originalResponse = MockApiService.getAllRoutesResponse();

        // Act
        final json = originalResponse.toJson();
        final deserializedResponse = RouteResponse.fromJson(json);

        // Assert
        expect(deserializedResponse.routes.length, originalResponse.routes.length);
        expect(deserializedResponse.page, originalResponse.page);
        expect(deserializedResponse.size, originalResponse.size);
        expect(deserializedResponse.totalPages, originalResponse.totalPages);
        expect(deserializedResponse.totalElements, originalResponse.totalElements);
      });
    });
  });
}