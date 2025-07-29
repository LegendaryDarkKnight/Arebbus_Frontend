/// Represents the count of users waiting for a specific bus.
/// 
/// This model provides real-time information about how many users are currently
/// waiting for a particular bus. It's used for displaying passenger demand,
/// helping with capacity planning, and providing users with insights about
/// bus popularity and crowding levels.
class WaitingUsersCount {
  /// Unique identifier of the bus
  final int busId;
  
  /// Display name of the bus
  final String busName;
  
  /// Number of users currently waiting for this bus
  final int waitingCount;

  /// Creates a new WaitingUsersCount instance.
  /// 
  /// Parameters:
  /// - [busId]: Unique identifier of the bus
  /// - [busName]: Display name of the bus
  /// - [waitingCount]: Number of users waiting for this bus
  WaitingUsersCount({
    required this.busId,
    required this.busName,
    required this.waitingCount,
  });

  /// Creates a WaitingUsersCount instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of waiting count data from API responses.
  /// 
  /// Parameters:
  /// - [json]: Map containing waiting users count data from API response
  /// 
  /// Returns a new WaitingUsersCount instance populated from JSON data.
  factory WaitingUsersCount.fromJson(Map<String, dynamic> json) {
    return WaitingUsersCount(
      busId: json['busId'],
      busName: json['busName'],
      waitingCount: json['waitingCount'],
    );
  }

  /// Converts the WaitingUsersCount instance to a JSON map.
  /// 
  /// This method is used when caching count data locally or for debugging purposes.
  /// 
  /// Returns a Map<String, dynamic> representing the waiting users count data.
  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'busName': busName,
      'waitingCount': waitingCount,
    };
  }
}