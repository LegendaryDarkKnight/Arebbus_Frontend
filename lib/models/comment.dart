/// Represents a comment on a post in the Arebbus community platform.
/// 
/// Comments allow users to engage with posts by providing additional content,
/// discussions, or reactions. Each comment is associated with a specific post
/// and supports upvoting functionality similar to posts. Comments maintain
/// their own engagement metrics and author information.
class Comment {
  /// Unique identifier for the comment
  final int id;
  
  /// The text content of the comment
  final String content;
  
  /// Display name of the comment author
  final String authorName;
  
  /// ID of the post this comment belongs to
  final int postId;
  
  /// Timestamp when the comment was created
  final DateTime createdAt;
  
  /// Number of upvotes this comment has received
  final int numUpvote;
  
  /// Whether the current user has upvoted this comment
  final bool upvoted;
  
  /// Optional profile image URL of the comment author
  final String? authorImage;

  /// Creates a new Comment instance.
  /// 
  /// Required parameters:
  /// - [id]: Unique identifier for the comment
  /// - [content]: The text content of the comment
  /// - [authorName]: Display name of the comment author
  /// - [postId]: ID of the post this comment belongs to
  /// - [createdAt]: Timestamp when the comment was created
  /// - [numUpvote]: Number of upvotes received
  /// - [upvoted]: Whether current user has upvoted this comment
  /// 
  /// Optional parameters:
  /// - [authorImage]: Profile image URL of the comment author
  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.postId,
    required this.createdAt,
    required this.numUpvote,
    required this.upvoted,
    this.authorImage,
  });

  /// Creates a Comment instance from a JSON map.
  /// 
  /// This factory constructor handles deserialization of comment data from API responses.
  /// It properly handles DateTime parsing from string format and provides safe defaults
  /// for optional fields.
  /// 
  /// Parameters:
  /// - [json]: Map containing comment data from API response
  /// 
  /// Returns a new Comment instance populated from JSON data.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      authorName: json['authorName'],
      postId: json['postId'],
      numUpvote: json['numUpvote'] ?? 0,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] ?? DateTime.now()),
      upvoted: json['upvoted'] ?? false,
    );
  }

  /// Converts the Comment instance to a JSON map.
  /// 
  /// This method is used when sending comment data to the API or storing locally.
  /// The DateTime is converted to ISO 8601 string format for proper serialization.
  /// Note: There's a typo in the original where 'upVoted' should be 'upvoted'.
  /// 
  /// Returns a Map<String, dynamic> representing the comment data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'postId': postId,
      'createdAt': createdAt.toIso8601String(), // Added timestamp
      'numUpvote': numUpvote,
      'upVoted': upvoted,
      'authorImage': authorImage,
    };
  }

  Comment copyWith({
    int? id,
    String? content,
    String? authorName,
    int? postId,
    DateTime? createdAt,
    int? numUpvote,
    bool? upvoted,
    String? authorImage,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      numUpvote: numUpvote ?? this.numUpvote,
      upvoted: upvoted ?? this.upvoted,
      authorImage: authorImage ?? this.authorImage,
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content}, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment &&
        other.id == id &&
        other.createdAt ==
            createdAt; // Consider timestamp for equality if ID can be null for new comments
  }

  @override
  int get hashCode => id.hashCode ^ createdAt.hashCode; // Combine hashCodes
}
