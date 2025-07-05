// lib/models/route_model.dart
import 'package:arebbus/models/stop.dart';

class RouteModel {
  final String id;
  final String name;
  final List<Stop> stops;

  RouteModel({
    required this.id,
    required this.name,
    required this.stops,
  });
}