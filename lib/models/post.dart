import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/tag.dart';

/// Represents a social media post in the Arebbus community platform.
/// 
/// Posts are user-generated content that can include text, tags, and comments.
/// They support upvoting functionality and are displayed in the feed screen.
/// This model handles all post-related data including author information,
/// content, engagement metrics, and associated comments.
class Post {
  /// Unique identifier for the post
  final int id;
  
  /// Display name of the post author
  final String authorName;
  
  /// Optional profile image URL of the post author
  final String? authorImage;
  
  /// The main text content of the post
  final String content;
  
  /// Number of upvotes this post has received
  final int numUpvote;
  
  /// Optional list of tags associated with this post for categorization
  final List<Tag>? tags;
  
  /// Timestamp when the post was created
  final DateTime createdAt;
  
  /// Optional list of comments on this post
  final List<Comment>? comments;
  
  /// Whether the current user has upvoted this post
  final bool upvoted;

  /// Creates a new Post instance.
  /// 
  /// Required parameters:
  /// - [id]: Unique identifier for the post
  /// - [authorName]: Display name of the post author
  /// - [content]: The main text content of the post
  /// - [numUpvote]: Number of upvotes this post has received
  /// - [createdAt]: Timestamp when the post was created
  /// - [upvoted]: Whether the current user has upvoted this post
  /// 
  /// Optional parameters:
  /// - [authorImage]: Profile image URL of the post author
  /// - [tags]: List of tags associated with this post
  /// - [comments]: List of comments on this post
  Post({
    required this.id,
    required this.authorName,
    this.authorImage,
    required this.content,
    required this.numUpvote,
    required this.createdAt,
    this.tags,
    this.comments,
    required this.upvoted,
  });

  /// Creates a Post instance from a JSON map.
  /// 
  /// This factory constructor is used when deserializing post data from API responses.
  /// It handles null safety and provides default values for optional fields.
  /// 
  /// Parameters:
  /// - [json]: Map containing the post data from API response
  /// 
  /// Returns a new Post instance with data populated from the JSON map.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorName: json['authorName'],
      authorImage: json['authorImage'],
      content: json['content'] ?? '',
      numUpvote: json['numUpvote'] ?? 0,
      createdAt: json['createdAt'] ??DateTime.now(),
      tags:
          json['tags'] != null
              ? (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList()
              : null,
      comments:
          json['comments'] != null
              ? (json['comments'] as List)
                  .map((comment) => Comment.fromJson(comment))
                  .toList()
              : null,
      upvoted: json['upvoted'] ?? false,
    );
  }

  /// Converts the Post instance to a JSON map.
  /// 
  /// This method is used when sending post data to the API or storing it locally.
  /// All DateTime objects are converted to ISO 8601 strings for proper serialization.
  /// 
  /// Returns a Map<String, dynamic> representing the post data.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorImage': authorImage,
      'content': content,
      'numUpvote': numUpvote,
      'tags': tags?.map((tag) => tag.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'upvoted': upvoted,
    };
  }

  /// Creates a copy of this Post with the given fields replaced with new values.
  /// 
  /// This method is useful for updating specific fields of a post without 
  /// modifying the original instance. Commonly used when toggling upvote status
  /// or updating comment counts.
  /// 
  /// Parameters (all optional):
  /// - [id]: New post ID
  /// - [authorName]: New author name
  /// - [authorImage]: New author image URL
  /// - [content]: New post content
  /// - [numUpvote]: New upvote count
  /// - [tags]: New list of tags
  /// - [createdAt]: New creation timestamp
  /// - [comments]: New list of comments
  /// - [upvoted]: New upvote status for current user
  /// 
  /// Returns a new Post instance with updated values.
  Post copyWith({
    int? id,
    String? authorName,
    String? authorImage,
    String? content,
    int? numUpvote,
    List<Tag>? tags,
    DateTime? createdAt,
    List<Comment>? comments,
    bool? upvoted,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorImage: authorImage ?? this.authorImage,
      content: content ?? this.content,
      numUpvote: numUpvote ?? this.numUpvote,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      upvoted: upvoted ?? this.upvoted,
    );
  }

  /// Returns a string representation of the Post for debugging purposes.
  /// 
  /// The content is truncated to 50 characters to keep the output manageable.
  /// This is useful for logging and debugging operations.
  @override
  String toString() {
    return 'Post{id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}}';
  }

  /// Determines whether two Post instances are equal based on their ID.
  /// 
  /// Two posts are considered equal if they have the same ID, regardless
  /// of other field values. This is useful for list operations and comparisons.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  /// Returns the hash code for this Post instance.
  /// 
  /// The hash code is based solely on the post ID to maintain consistency
  /// with the equality operator.
  @override
  int get hashCode => id.hashCode;
}
