class BusLocationCluster {
  final double latitude;
  final double longitude;
  final int userCount;

  BusLocationCluster({
    required this.latitude,
    required this.longitude,
    required this.userCount,
  });

  factory BusLocationCluster.fromJson(Map<String, dynamic> json) {
    return BusLocationCluster(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      userCount: json['userCount'],
    );
  }
}

class BusLocationResponse {
  final int busId;
  final String busName;
  final List<BusLocationCluster> locations;

  BusLocationResponse({
    required this.busId,
    required this.busName,
    required this.locations,
  });

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