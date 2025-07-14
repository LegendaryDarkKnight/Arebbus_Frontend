import 'dart:math' as math;
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/bus_response.dart';
import 'package:arebbus/models/route.dart';
import 'package:arebbus/models/route_response.dart';
import 'package:arebbus/models/stop.dart';

class MockApiService {
  // Mock data
  static final List<Stop> _mockStops = [
    Stop(
      id: 1,
      name: "Central Bus Station",
      latitude: 40.7128,
      longitude: -74.0060,
      // authorId: 1,
      authorName: "John Doe",
    ),
    Stop(
      id: 2,
      name: "Downtown Terminal",
      latitude: 40.7589,
      longitude: -73.9851,
      // authorId: 2,
      authorName: "Jane Smith",
    ),
    Stop(
      id: 3,
      name: "Shopping Mall",
      latitude: 40.7505,
      longitude: -73.9934,
      // authorId: 3,
      authorName: "Bob Wilson",
    ),
    Stop(
      id: 4,
      name: "University Campus",
      latitude: 40.7282,
      longitude: -73.9942,
      // authorId: 4,
      authorName: "Alice Brown",
    ),
    Stop(
      id: 5,
      name: "Airport Terminal",
      latitude: 40.6413,
      longitude: -73.7781,
      // authorId: 5,
      authorName: "Carol Davis",
    ),
  ];

  static final List<Route> _mockRoutes = [
    Route(
      id: 1,
      name: "Downtown Express",
      authorName: "John Doe",
      stops: [_mockStops[0], _mockStops[1], _mockStops[2], _mockStops[3]],
    ),
    Route(
      id: 2,
      name: "Airport Shuttle",
      authorName: "Jane Smith",
      stops: [_mockStops[2], _mockStops[4]],
    ),
  ];

  static final List<Bus> _mockBuses = [
    Bus(
      id: 1,
      name: "Express Bus 101",
      authorName: "John Doe",
      route: _mockRoutes[0],
      capacity: 50,
      numInstall: 5,
      numUpvote: 12,
      status: "ACTIVE",
      basedOn: null,
      upvoted: false,
      installed: true,
    ),
    Bus(
      id: 2,
      name: "Airport Shuttle",
      authorName: "Jane Smith",
      route: _mockRoutes[1],
      capacity: 30,
      numInstall: 3,
      numUpvote: 8,
      status: "ACTIVE",
      basedOn: null,
      upvoted: true,
      installed: false,
    ),
  ];

  // Mock API responses
  static BusResponse getAllBusesResponse({int page = 0, int size = 10}) {
    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, _mockBuses.length);
    final buses = _mockBuses.sublist(
      startIndex.clamp(0, _mockBuses.length),
      endIndex,
    );

    return BusResponse(
      buses: buses,
      page: page,
      size: size,
      totalPages: (_mockBuses.length / size).ceil(),
      totalElements: _mockBuses.length,
    );
  }

  static BusResponse getInstalledBusesResponse({int page = 0, int size = 10}) {
    final installedBuses = _mockBuses.where((bus) => bus.installed).toList();
    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, installedBuses.length);
    final buses = installedBuses.sublist(
      startIndex.clamp(0, installedBuses.length),
      endIndex,
    );

    return BusResponse(
      buses: buses,
      page: page,
      size: size,
      totalPages: (installedBuses.length / size).ceil(),
      totalElements: installedBuses.length,
    );
  }

  static Bus? getBusByIdResponse(int busId) {
    try {
      return _mockBuses.firstWhere((bus) => bus.id == busId);
    } catch (e) {
      return null;
    }
  }

  static RouteResponse getAllRoutesResponse({int page = 0, int size = 10}) {
    final startIndex = page * size;
    final endIndex = (startIndex + size).clamp(0, _mockRoutes.length);
    final routes = _mockRoutes.sublist(
      startIndex.clamp(0, _mockRoutes.length),
      endIndex,
    );

    return RouteResponse(
      routes: routes,
      page: page,
      size: size,
      totalPages: (_mockRoutes.length / size).ceil(),
      totalElements: _mockRoutes.length,
    );
  }

  static Route? getRouteByIdResponse(int routeId) {
    try {
      return _mockRoutes.firstWhere((route) => route.id == routeId);
    } catch (e) {
      return null;
    }
  }

  static Stop? getStopByIdResponse(int stopId) {
    try {
      return _mockStops.firstWhere((stop) => stop.id == stopId);
    } catch (e) {
      return null;
    }
  }

  static List<Stop> getNearbyStopsResponse({
    required double latitude,
    required double longitude,
    double radius = 3.0,
  }) {
    // Simple distance calculation for testing
    return _mockStops.where((stop) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        stop.latitude,
        stop.longitude,
      );
      return distance <= radius;
    }).toList();
  }

  static Stop createStopResponse({
    required String name,
    required double latitude,
    required double longitude,
  }) {
    final newId = _mockStops.length + 1;
    return Stop(
      id: newId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      // authorId: 1,
      authorName: "Test User",
    );
  }

  static Route createRouteResponse({
    required String name,
    required List<int> stopIds,
  }) {
    final stops = stopIds
        .map((id) => _mockStops.firstWhere((stop) => stop.id == id))
        .toList();
    
    final newId = _mockRoutes.length + 1;
    return Route(
      id: newId,
      name: name,
      authorName: "Test User",
      stops: stops,
    );
  }

  static Bus createBusResponse({
    required String name,
    required int routeId,
    required int capacity,
  }) {
    final route = _mockRoutes.firstWhere((r) => r.id == routeId);
    final newId = _mockBuses.length + 1;
    
    return Bus(
      id: newId,
      name: name,
      authorName: "Test User",
      route: route,
      capacity: capacity,
      numInstall: 0,
      numUpvote: 0,
      status: "ACTIVE",
      basedOn: null,
      upvoted: false,
      installed: false,
    );
  }

  static Map<String, dynamic> installBusResponse(int busId) {
    final bus = getBusByIdResponse(busId);
    return {
      "busId": busId,
      "busName": bus?.name ?? "Unknown Bus",
      "message": "Bus installed successfully",
      "installed": true,
    };
  }

  static Map<String, dynamic> uninstallBusResponse(int busId) {
    final bus = getBusByIdResponse(busId);
    return {
      "busId": busId,
      "busName": bus?.name ?? "Unknown Bus",
      "message": "Bus uninstalled successfully",
      "installed": false,
    };
  }

  // Helper method for distance calculation
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}