// lib/models/bus_model.dart
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng

class Bus {
  final String id;
  final String name; 
  final String routeName; // e.g., "Rayerbag to Bakshibazar"
  final int totalSeats;
  int availableSeats; // Can change
  final String currentStatus; // e.g., "Running", "Delayed"
  final LatLng? currentLocation; // Mock location
  final List<String> stoppages;
  final Map<String, double> fareInfo; // Stoppage to fare
  String userActionStatus; // "none", "waiting", "on_bus"

  Bus({
    required this.id,
    required this.name,
    required this.routeName,
    required this.totalSeats,
    required this.availableSeats,
    this.currentStatus = "Running",
    this.currentLocation,
    required this.stoppages,
    required this.fareInfo,
    this.userActionStatus = "none",
  });
}

class RouteInfo {
  final String id;
  final String name;
  final List<String> stoppages;
  final String description;

  RouteInfo({
    required this.id,
    required this.name,
    required this.stoppages,
    required this.description,
  });
}
