import 'package:arebbus/models/user.dart';
import 'package:arebbus/models/route.dart';

class Bus {
  final int? id;
  final int authorId;
  final int routeId;
  final int capacity;
  final int numInstall;
  final int numUpvote;
  final String? status;
  final int? basedOn;
  final User? author;
  final Route? route;
  final Bus? basedOnBus;

  Bus({
    this.id,
    required this.authorId,
    required this.routeId,
    required this.capacity,
    required this.numInstall,
    required this.numUpvote,
    this.status,
    this.basedOn,
    this.author,
    this.route,
    this.basedOnBus,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      authorId: json['author_id'] ?? json['authorId'],
      routeId: json['route_id'] ?? json['routeId'],
      capacity: json['capacity'] ?? 0,
      numInstall: json['num_install'] ?? json['numInstall'] ?? 0,
      numUpvote: json['num_upvote'] ?? json['numUpvote'] ?? 0,
      status: json['status'],
      basedOn: json['based_on'] ?? json['basedOn'],
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      route: json['route'] != null ? Route.fromJson(json['route']) : null,
      basedOnBus: json['based_on_bus'] != null ? Bus.fromJson(json['based_on_bus']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'route_id': routeId,
      'capacity': capacity,
      'num_install': numInstall,
      'num_upvote': numUpvote,
      'status': status,
      'based_on': basedOn,
      'author': author?.toJson(),
      'route': route?.toJson(),
      'based_on_bus': basedOnBus?.toJson(),
    };
  }

  Bus copyWith({
    int? id,
    int? authorId,
    int? routeId,
    int? capacity,
    int? numInstall,
    int? numUpvote,
    String? status,
    int? basedOn,
    User? author,
    Route? route,
    Bus? basedOnBus,
  }) {
    return Bus(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      routeId: routeId ?? this.routeId,
      capacity: capacity ?? this.capacity,
      numInstall: numInstall ?? this.numInstall,
      numUpvote: numUpvote ?? this.numUpvote,
      status: status ?? this.status,
      basedOn: basedOn ?? this.basedOn,
      author: author ?? this.author,
      route: route ?? this.route,
      basedOnBus: basedOnBus ?? this.basedOnBus,
    );
  }

  @override
  String toString() {
    return 'Bus{id: $id, capacity: $capacity, numInstall: $numInstall}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bus && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}