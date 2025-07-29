import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/user.dart';

/// Represents a record of a user waiting for a specific bus.
/// 
/// This model tracks the relationship between users and buses when users are
/// actively waiting for transportation. It includes validation status to ensure
/// the waiting record is current and accurate, and can contain detailed information
/// about both the user and the bus being waited for.
class WaitingFor {
  /// ID of the user who is waiting
  final int userId;
  
  /// ID of the bus being waited for
  final int busId;
  
  /// Whether this waiting record is still valid/active
  final bool valid;
  
  /// Optional detailed user information
  final User? user;
  
  /// Optional detailed bus information
  final Bus? bus;

  /// Creates a new WaitingFor instance.
  /// 
  /// Required parameters:
  /// - [userId]: ID of the user who is waiting
  /// - [busId]: ID of the bus being waited for
  /// - [valid]: Whether this waiting record is active
  /// 
  /// Optional parameters:
  /// - [user]: Detailed user information
  /// - [bus]: Detailed bus information
  WaitingFor({
    required this.userId,
    required this.busId,
    required this.valid,
    this.user,
    this.bus,
  });

  /// Creates a WaitingFor instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of waiting data from API responses.
  /// It supports both snake_case and camelCase field naming conventions and provides
  /// safe defaults for the validity flag.
  /// 
  /// Parameters:
  /// - [json]: Map containing waiting data from API response
  /// 
  /// Returns a new WaitingFor instance populated from JSON data.
  factory WaitingFor.fromJson(Map<String, dynamic> json) {
    return WaitingFor(
      userId: json['user_id'] ?? json['userId'],
      busId: json['bus_id'] ?? json['busId'],
      valid: json['valid'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      bus: json['bus'] != null ? Bus.fromJson(json['bus']) : null,
    );
  }

  /// Converts the WaitingFor instance to a JSON map.
  /// 
  /// This method is used when sending waiting data to the API or storing locally.
  /// It uses snake_case field names for API compatibility.
  /// 
  /// Returns a Map<String, dynamic> representing the waiting data.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bus_id': busId,
      'valid': valid,
      'user': user?.toJson(),
      'bus': bus?.toJson(),
    };
  }

  /// Creates a copy of this WaitingFor with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of a waiting record without
  /// modifying the original instance. Commonly used for updating validity status
  /// or refreshing nested user/bus information.
  /// 
  /// Parameters (all optional):
  /// - [userId]: New user ID
  /// - [busId]: New bus ID
  /// - [valid]: New validity status
  /// - [user]: New user information
  /// - [bus]: New bus information
  /// 
  /// Returns a new WaitingFor instance with updated values.
  WaitingFor copyWith({
    int? userId,
    int? busId,
    bool? valid,
    User? user,
    Bus? bus,
  }) {
    return WaitingFor(
      userId: userId ?? this.userId,
      busId: busId ?? this.busId,
      valid: valid ?? this.valid,
      user: user ?? this.user,
      bus: bus ?? this.bus,
    );
  }

  /// Returns a string representation of the WaitingFor for debugging purposes.
  /// 
  /// Includes the user ID, bus ID, and validity status for easy identification.
  @override
  String toString() {
    return 'WaitingFor{userId: $userId, busId: $busId, valid: $valid}';
  }
}
