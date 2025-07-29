/// Represents a bus stop in the Arebbus transportation system.
/// 
/// A stop is a specific location where buses can pick up and drop off passengers.
/// Each stop has a unique name, geographic coordinates, and information about
/// who created it. Stops are the building blocks of routes and are used for
/// navigation, trip planning, and user location services.
class Stop {
  /// Unique identifier for the stop (nullable for new stops not yet saved)
  final int? id;
  
  /// Display name of the bus stop
  final String name;
  
  /// Latitude coordinate of the stop location
  final double latitude;
  
  /// Longitude coordinate of the stop location
  final double longitude;
  
  /// Name of the user who created this stop
  final String authorName;

  /// Creates a new Stop instance.
  /// 
  /// Required parameters:
  /// - [name]: Display name of the bus stop
  /// - [latitude]: Latitude coordinate of the location
  /// - [longitude]: Longitude coordinate of the location
  /// - [authorName]: Name of the user who created this stop
  /// 
  /// Optional parameters:
  /// - [id]: Unique identifier (null for new stops)
  Stop({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.authorName,
  });

  /// Creates a Stop instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of stop data from API responses.
  /// It ensures proper type conversion for coordinate values and provides safe defaults.
  /// 
  /// Parameters:
  /// - [json]: Map containing stop data from API response
  /// 
  /// Returns a new Stop instance populated from JSON data.
  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      authorName: json['authorName'],
    );
  }

  /// Converts the Stop instance to a JSON map.
  /// 
  /// This method is used when sending stop data to the API or storing locally.
  /// All stop information including coordinates is included.
  /// 
  /// Returns a Map<String, dynamic> representing the stop data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'authorName': authorName,
    };
  }

  /// Creates a copy of this Stop with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of a stop without
  /// modifying the original instance.
  /// 
  /// Parameters (all optional):
  /// - [id]: New stop ID
  /// - [name]: New stop name
  /// - [latitude]: New latitude coordinate
  /// - [longitude]: New longitude coordinate
  /// - [authorName]: New author name
  /// 
  /// Returns a new Stop instance with updated values.
  Stop copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? authorName,
  }) {
    return Stop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      authorName: authorName ?? this.authorName,
    );
  }

  /// Returns a string representation of the Stop for debugging purposes.
  /// 
  /// Includes the stop ID, name, and coordinates for easy identification.
  @override
  String toString() {
    return 'Stop{id: $id, name: $name, lat: $latitude, lon: $longitude}';
  }

  /// Determines whether two Stop instances are equal based on their ID.
  /// 
  /// Two stops are considered equal if they have the same ID, regardless
  /// of other field values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stop && other.id == id;
  }

  /// Returns the hash code for this Stop instance.
  /// 
  /// The hash code is based solely on the stop ID to maintain consistency
  /// with the equality operator.
  @override
  int get hashCode => id.hashCode;
}
