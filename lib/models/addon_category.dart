/// Enumeration of available addon categories in the Arebbus application.
/// 
/// This enum defines the different types of addons that can be created
/// and installed in the application. Each category represents a specific
/// area of functionality that addons can enhance or modify.
/// 
/// Categories help users find relevant addons and organize the addon
/// marketplace for better discoverability.
enum AddonCategory {
  /// Addons that enhance bus-related functionality
  /// Examples: Custom bus icons, bus status indicators, arrival predictions
  bus('Bus'),
  
  /// Addons that provide route-specific features
  /// Examples: Route optimizers, alternative route suggestions, route analytics
  route('Route'),
  
  /// Addons that improve bus stop functionality
  /// Examples: Stop amenities info, real-time crowding data, accessibility features
  stop('Stop');

  /// Creates an AddonCategory with the specified string value.
  const AddonCategory(this.value);
  
  /// The string representation of this category
  final String value;

  /// Creates an AddonCategory from a string value.
  /// 
  /// This method maps string values from API responses or user input
  /// to the corresponding enum value. If no match is found, defaults
  /// to the 'bus' category.
  /// 
  /// Parameter:
  /// - [value]: String representation of the category
  /// 
  /// Returns: The corresponding AddonCategory enum value
  static AddonCategory fromString(String value) {
    return AddonCategory.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AddonCategory.bus,
    );
  }
}
