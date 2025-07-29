import 'package:arebbus/models/route.dart';

/// Represents a bus entity in the Arebbus transportation system.
/// 
/// This model contains all information about a bus including its metadata,
/// route information, installation statistics, and user interactions.
/// Buses can be created by users and "installed" by others for tracking.
/// The model supports hierarchical relationships where buses can be based on other buses.
class Bus {
  /// Unique identifier for the bus (nullable for new buses not yet saved)
  final int? id;
  
  /// Display name of the bus
  final String name;
  
  /// Name of the user who created this bus
  final String authorName;
  
  /// Maximum passenger capacity of the bus
  final int capacity;
  
  /// Number of users who have installed this bus for tracking
  final int numInstall;
  
  /// Number of upvotes this bus has received from users
  final int numUpvote;
  
  /// Current operational status of the bus (e.g., "ACTIVE", "INACTIVE")
  final String? status;
  
  /// The route that this bus follows (nullable if no route assigned)
  final Route? route;
  
  /// Reference to another bus that this bus is based on (for bus variations)
  final Bus? basedOn;
  
  /// Whether the current user has upvoted this bus
  final bool upvoted;
  
  /// Whether the current user has installed this bus for tracking
  final bool installed;

  /// Creates a new Bus instance.
  /// 
  /// Required parameters:
  /// - [name]: Display name of the bus
  /// - [authorName]: Name of the user who created this bus
  /// - [capacity]: Maximum passenger capacity
  /// - [numInstall]: Number of users who have installed this bus
  /// - [numUpvote]: Number of upvotes received
  /// - [upvoted]: Whether current user has upvoted
  /// - [installed]: Whether current user has installed this bus
  /// 
  /// Optional parameters:
  /// - [id]: Unique identifier (null for new buses)
  /// - [status]: Current operational status
  /// - [route]: Associated route information
  /// - [basedOn]: Reference to parent bus if this is a variation
  Bus({
    this.id,
    required this.name,
    required this.authorName,
    required this.capacity,
    required this.numInstall,
    required this.numUpvote,
    this.status,
    this.route,
    this.basedOn,
    required this.upvoted,
    required this.installed,
  });

  /// Creates a Bus instance from a JSON map.
  /// 
  /// This factory constructor deserializes bus data from API responses.
  /// It handles nested objects like Route and recursive Bus references safely.
  /// 
  /// Parameters:
  /// - [json]: Map containing the bus data from API response
  /// 
  /// Returns a new Bus instance populated from the JSON data.
  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      name: json['name'] ?? '',
      authorName: json['authorName'] ?? '',
      capacity: json['capacity'] ?? 0,
      numInstall: json['numInstall'] ?? 0,
      numUpvote: json['numUpvote'] ?? 0,
      status: json['status'],
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      basedOn: json['basedOn'] != null ? Bus.fromJson(json['basedOn']) : null,
      upvoted: json['upvoted'] ?? false,
      installed: json['installed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'authorName': authorName,
      'capacity': capacity,
      'numInstall': numInstall,
      'numUpvote': numUpvote,
      'status': status,
      'route': route?.toJson(),
      'basedOn': basedOn?.toJson(),
      'upvoted': upvoted,
      'installed': installed,
    };
  }

  Bus copyWith({
    int? id,
    String? name,
    String? authorName,
    int? capacity,
    int? numInstall,
    int? numUpvote,
    String? status,
    Route? route,
    Bus? basedOn,
    bool? upvoted,
    bool? installed,
  }) {
    return Bus(
      id: id ?? this.id,
      name: name ?? this.name,
      authorName: authorName ?? this.authorName,
      capacity: capacity ?? this.capacity,
      numInstall: numInstall ?? this.numInstall,
      numUpvote: numUpvote ?? this.numUpvote,
      status: status ?? this.status,
      route: route ?? this.route,
      basedOn: basedOn ?? this.basedOn,
      upvoted: upvoted ?? this.upvoted,
      installed: installed ?? this.installed,
    );
  }

  @override
  String toString() {
    return 'Bus{id: $id, name: $name, capacity: $capacity, numInstall: $numInstall, installed: $installed}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bus && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
