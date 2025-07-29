/// Represents a tag for categorizing posts in the Arebbus community platform.
/// 
/// Tags are labels that can be attached to posts to help organize and categorize
/// content. They enable users to filter and discover posts related to specific
/// topics, locations, or themes. Tags can be reused across multiple posts.
class Tag {
  /// Unique identifier for the tag (nullable for new tags not yet saved)
  final int? id;
  
  /// The text content of the tag
  final String name;

  /// Creates a new Tag instance.
  /// 
  /// Required parameters:
  /// - [name]: The text content of the tag
  /// 
  /// Optional parameters:
  /// - [id]: Unique identifier (null for new tags)
  Tag({this.id, required this.name});

  /// Creates a Tag instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of tag data from API responses.
  /// It provides a safe default for the name field if missing.
  /// 
  /// Parameters:
  /// - [json]: Map containing tag data from API response
  /// 
  /// Returns a new Tag instance populated from JSON data.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(id: json['id'], name: json['name'] ?? '');
  }

  /// Converts the Tag instance to a JSON map.
  /// 
  /// This method is used when sending tag data to the API or storing locally.
  /// 
  /// Returns a Map<String, dynamic> representing the tag data.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  /// Creates a copy of this Tag with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of a tag without
  /// modifying the original instance.
  /// 
  /// Parameters (all optional):
  /// - [id]: New tag ID
  /// - [name]: New tag name
  /// 
  /// Returns a new Tag instance with updated values.
  Tag copyWith({int? id, String? name}) {
    return Tag(id: id ?? this.id, name: name ?? this.name);
  }

  /// Returns a string representation of the Tag for debugging purposes.
  @override
  String toString() {
    return 'Tag{id: $id, name: $name}';
  }

  /// Determines whether two Tag instances are equal based on their ID.
  /// 
  /// Two tags are considered equal if they have the same ID, regardless
  /// of other field values.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  /// Returns the hash code for this Tag instance.
  /// 
  /// The hash code is based solely on the tag ID to maintain consistency
  /// with the equality operator.
  @override
  int get hashCode => id.hashCode;
}
