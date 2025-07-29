/// Enumeration representing the various location tracking statuses for users in the Arebbus system.
/// 
/// This enum defines the possible states a user can be in regarding their relationship
/// to bus transportation. It's used throughout the location tracking system to determine
/// appropriate notifications, UI states, and data processing logic.
enum LocationStatus {
  /// User is currently on a bus and being transported
  onBus('ON_BUS'),
  
  /// User is waiting for a bus at a stop or location
  waiting('WAITING'),
  
  /// User has left/exited the bus
  leftBus('LEFT_BUS');

  /// Creates a LocationStatus with the corresponding string value.
  /// 
  /// The [value] parameter represents the string representation used in API communications.
  const LocationStatus(this.value);
  
  /// String representation of the status used in API requests and responses
  final String value;

  /// Creates a LocationStatus from a string value.
  /// 
  /// This static method is used when deserializing location status data from API responses
  /// or when converting user input to the appropriate enum value.
  /// 
  /// Parameters:
  /// - [value]: String representation of the location status
  /// 
  /// Returns the corresponding LocationStatus enum value, defaulting to 'waiting' if not found.
  static LocationStatus fromString(String value) {
    return LocationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LocationStatus.waiting,
    );
  }
}
