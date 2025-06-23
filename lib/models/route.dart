import 'package:arebbus/models/user.dart';

class Route {
  final int? id;
  final String name;
  final int authorId;
  final User? author;

  Route({this.id, required this.name, required this.authorId, this.author});

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      name: json['name'] ?? '',
      authorId: json['author_id'] ?? json['authorId'],
      author: json['author'] != null ? User.fromJson(json['author']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author_id': authorId,
      'author': author?.toJson(),
    };
  }

  Route copyWith({int? id, String? name, int? authorId, User? author}) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
    );
  }

  @override
  String toString() {
    return 'Route{id: $id, name: $name, authorId: $authorId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
