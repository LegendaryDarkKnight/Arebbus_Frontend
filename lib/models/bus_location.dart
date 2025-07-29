/// Represents a cluster of user locations associated with a specific bus.
/// 
/// When multiple users are in the same area while using a particular bus,
/// their locations are clustered together for better visualization and
/// performance. Each cluster contains the average coordinates and the
/// number of users in that location cluster.
class BusLocationCluster {
  /// Latitude coordinate of the cluster center
  final double latitude;
  
  /// Longitude coordinate of the cluster center
  final double longitude;
  
  /// Number of users in this location cluster
  final int userCount;

  /// Creates a new BusLocationCluster instance.
  /// 
  /// Parameters:
  /// - [latitude]: Latitude coordinate of the cluster center
  /// - [longitude]: Longitude coordinate of the cluster center  
  /// - [userCount]: Number of users in this cluster
  BusLocationCluster({
    required this.latitude,
    required this.longitude,
    required this.userCount,
  });

  /// Creates a BusLocationCluster instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of cluster data from API responses.
  /// It ensures proper type conversion for coordinate values.
  /// 
  /// Parameters:
  /// - [json]: Map containing cluster data from API response
  /// 
  /// Returns a new BusLocationCluster instance populated from JSON data.
  factory BusLocationCluster.fromJson(Map<String, dynamic> json) {
    return BusLocationCluster(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      userCount: json['userCount'],
    );
  }
}

/// Represents the complete location response for a specific bus.
/// 
/// This model contains all location clusters associated with a bus,
/// providing a comprehensive view of where users are located in relation
/// to that bus. It's used for real-time tracking and visualization of
/// bus usage patterns and user distribution.
class BusLocationResponse {
  /// Unique identifier of the bus
  final int busId;
  
  /// Display name of the bus
  final String busName;
  
  /// List of location clusters for users associated with this bus
  final List<BusLocationCluster> locations;

  /// Creates a new BusLocationResponse instance.
  /// 
  /// Parameters:
  /// - [busId]: Unique identifier of the bus
  /// - [busName]: Display name of the bus
  /// - [locations]: List of location clusters for this bus
  BusLocationResponse({
    required this.busId,
    required this.busName,
    required this.locations,
  });

  /// Creates a BusLocationResponse instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of bus location data from API responses.
  /// It properly deserializes the nested list of location clusters.
  /// 
  /// Parameters:
  /// - [json]: Map containing bus location data from API response
  /// 
  /// Returns a new BusLocationResponse instance populated from JSON data.
  factory BusLocationResponse.fromJson(Map<String, dynamic> json) {
    return BusLocationResponse(
      busId: json['busId'],
      busName: json['busName'],
      locations: (json['locations'] as List)
          .map((location) => BusLocationCluster.fromJson(location))
          .toList(),
    );
  }
}