import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/user.dart';

/// Represents a user's installation of a bus for tracking and notifications.
/// 
/// When users "install" a bus, they add it to their personal list of tracked buses.
/// This allows them to receive notifications, see real-time locations, and get
/// updates specific to that bus. Installations create a many-to-many relationship
/// between users and buses, enabling personalized transportation experiences.
class Install {
  /// ID of the user who installed the bus
  final int userId;
  
  /// ID of the bus that was installed
  final int busId;
  
  /// Optional detailed user information
  final User? user;
  
  /// Optional detailed bus information
  final Bus? bus;

  /// Creates a new Install instance.
  /// 
  /// Required parameters:
  /// - [userId]: ID of the user installing the bus
  /// - [busId]: ID of the bus being installed
  /// 
  /// Optional parameters:
  /// - [user]: Detailed user information
  /// - [bus]: Detailed bus information
  Install({required this.userId, required this.busId, this.user, this.bus});

  /// Creates an Install instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of installation data from API responses.
  /// It supports both snake_case and camelCase field naming conventions.
  /// 
  /// Parameters:
  /// - [json]: Map containing installation data from API response
  /// 
  /// Returns a new Install instance populated from JSON data.
  factory Install.fromJson(Map<String, dynamic> json) {
    return Install(
      userId: json['user_id'] ?? json['userId'],
      busId: json['bus_id'] ?? json['busId'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }

  /// Converts the Install instance to a JSON map.
  /// 
  /// This method is used when sending installation data to the API or storing locally.
  /// It uses snake_case field names for API compatibility.
  /// 
  /// Returns a Map<String, dynamic> representing the installation data.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'user': user?.toJson(),
      'bus': bus?.toJson(),
    };
  }

  /// Creates a copy of this Install with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of an installation without
  /// modifying the original instance.
  /// 
  /// Parameters (all optional):
  /// - [userId]: New user ID
  /// - [busId]: New bus ID
  /// - [user]: New user information
  /// - [bus]: New bus information
  /// 
  /// Returns a new Install instance with updated values.
  Install copyWith({int? userId, int? busId, User? user, Bus? bus}) {
    return Install(
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      user: user ?? this.user,
      bus: bus ?? this.bus,
    );
  }

  @override
  String toString() {
    return 'Install{userId: $userId, busId: $busId}';
  }
}
