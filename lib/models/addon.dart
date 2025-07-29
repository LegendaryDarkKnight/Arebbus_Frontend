import 'package:arebbus/models/addon_category.dart';
import 'package:arebbus/models/user.dart';

/// Represents an addon/extension in the Arebbus ecosystem.
/// 
/// Addons are additional features or modifications that users can install
/// to enhance their bus tracking experience. They can include custom UI themes,
/// additional route information, notification settings, or other functionality
/// created by the community or developers.
/// 
/// Each addon has metadata about its functionality, author, and installation status.
class Addon {
  /// Unique identifier for the addon
  final String id;
  
  /// Display name of the addon
  final String name;
  
  /// Detailed description of what the addon does and its features
  final String description;
  
  /// Category this addon belongs to (UI, Notifications, Routes, etc.)
  final AddonCategory category;
  
  /// User who created/published this addon
  final User author;
  
  /// Number of times this addon has been installed by users
  final int installs;
  
  /// Average user rating for this addon (typically 0.0 to 5.0)
  final double rating;
  
  /// Whether the current user has this addon installed
  final bool isInstalled;
  
  /// Timestamp when this addon was first created/published
  final DateTime createdAt;
  
  /// Timestamp when this addon was last updated
  final DateTime updatedAt;

  /// Creates a new Addon instance.
  /// 
  /// All parameters are required to ensure complete addon information.
  Addon({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.author,
    required this.installs,
    required this.rating,
    required this.isInstalled,
    required this.createdAt,
    required this.updatedAt,
  });
}
