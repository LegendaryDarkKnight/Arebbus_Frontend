/// Represents the current location and status of a user in the Arebbus system.
/// 
/// This model tracks where users are and what they're doing in relation to
/// bus transportation. It includes location coordinates, timing information,
/// and status indicators that help with route planning and real-time tracking.
/// The status field indicates whether a user is waiting for a bus, on a bus,
/// or not actively being tracked.
class UserLocation {
  /// Unique identifier of the user whose location this represents
  final int userId;
  
  /// ID of the bus the user is associated with (null if not on/waiting for a specific bus)
  final int? busId;
  
  /// Name of the bus the user is associated with (null if not on/waiting for a specific bus)
  final String? busName;
  
  /// Latitude coordinate of the user's current location
  final double latitude;
  
  /// Longitude coordinate of the user's current location
  final double longitude;
  
  /// Timestamp when this location was recorded
  final String time;
  
  /// Current status of the user (NO_TRACK, WAITING, ON_BUS)
  final String status;

  /// Creates a new UserLocation instance.
  /// 
  /// Required parameters:
  /// - [userId]: Unique identifier of the user
  /// - [latitude]: Latitude coordinate of the location
  /// - [longitude]: Longitude coordinate of the location
  /// - [time]: Timestamp when this location was recorded
  /// - [status]: Current user status
  /// 
  /// Optional parameters:
  /// - [busId]: ID of associated bus
  /// - [busName]: Name of associated bus
  UserLocation({
    required this.userId,
    this.busId,
    this.busName,
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.status,
  });

  /// Creates a UserLocation instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of location data from API responses.
  /// It ensures proper type conversion for coordinate values.
  /// 
  /// Parameters:
  /// - [json]: Map containing user location data from API response
  /// 
  /// Returns a new UserLocation instance populated from JSON data.
  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      userId: json['userId'],
      busId: json['busId'],
      busName: json['busName'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      time: json['time'],
      status: json['status'],
    );
  }

  /// Converts the UserLocation instance to a JSON map.
  /// 
  /// This method is used when sending location data to the API or storing locally.
  /// All location and status information is included.
  /// 
  /// Returns a Map<String, dynamic> representing the user location data.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'busId': busId,
      'busName': busName,
      'latitude': latitude,
      'longitude': longitude,
      'time': time,
      'status': status,
    };
  }

  /// Returns true if the user's status is NO_TRACK.
  /// 
  /// This indicates the user is not actively being tracked for transportation purposes.
  bool get isNoTrack => status == 'NO_TRACK';
  
  /// Returns true if the user's status is WAITING.
  /// 
  /// This indicates the user is waiting for a bus at a stop or location.
  bool get isWaiting => status == 'WAITING';
  
  /// Returns true if the user's status is ON_BUS.
  /// 
  /// This indicates the user is currently on a bus and being transported.
  bool get isOnBus => status == 'ON_BUS';
}