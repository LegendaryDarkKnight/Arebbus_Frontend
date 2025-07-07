import 'package:arebbus/models/route.dart';

class Bus {
  final int? id;
  final String name;
  final String authorName;
  final int capacity;
  final int numInstall;
  final int numUpvote;
  final String? status;
  final Route? route;
  final Bus? basedOn;
  final bool upvoted;
  final bool installed;

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
