class Author {
  final String id;
  final String username;
  final int reputation;

  Author({
    required this.id,
    required this.username,
    required this.reputation,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      username: json['username'],
      reputation: json['reputation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'reputation': reputation,
    };
  }
}

class Addon {
  final String id;
  final String name;
  final String description;
  final String category;
  final Author author;
  final int installs;
  final double rating;
  final bool isInstalled;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      author: Author.fromJson(json['author']),
      installs: json['installs'],
      rating: (json['rating'] as num).toDouble(),
      isInstalled: json['isInstalled'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'author': author.toJson(),
      'installs': installs,
      'rating': rating,
      'isInstalled': isInstalled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
