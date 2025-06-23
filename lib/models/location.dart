import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/location_status.dart';
import 'package:arebbus/models/user.dart';

class Location {
  final int busId;
  final int userId;
  final double latitude;
  final double longitude;
  final DateTime time;
  final LocationStatus status;
  final Bus? bus;
  final User? user;

  Location({
    required this.busId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.status,
    this.bus,
    this.user,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      busId: json['bus_id'] ?? json['busId'],
      userId: json['user_id'] ?? json['userId'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      time: DateTime.parse(json['time']),
      status: LocationStatus.fromString(json['status'] ?? 'WAITING'),
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'time': time.toIso8601String(),
      'status': status.value,
      'bus': bus?.toJson(),
      'user': user?.toJson(),
    };
  }

  Location copyWith({
    int? busId,
    int? userId,
    double? latitude,
    double? longitude,
    DateTime? time,
    LocationStatus? status,
    Bus? bus,
    User? user,
  }) {
    return Location(
      busId: busId ?? this.busId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      time: time ?? this.time,
      status: status ?? this.status,
      bus: bus ?? this.bus,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Location{busId: $busId, userId: $userId, status: ${status.value}}';
  }
}
