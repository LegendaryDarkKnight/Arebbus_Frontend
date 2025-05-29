import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/user.dart';

class Comment {
  final int? id;
  final String content;
  final int? authorId;
  final int postId;
  final int numUpvote;
  final User? author;
  final Post? post; // Be cautious with circular dependencies if Post also holds List<Comment>
  final DateTime timestamp;

  Comment({
    this.id,
    required this.content,
    this.authorId,
    required this.postId,
    required this.numUpvote,
    required this.timestamp, // Made timestamp a required named parameter
    this.author,
    this.post,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      authorId: json['author_id'] ?? json['authorId'],
      postId: json['post_id'] ?? json['postId'],
      numUpvote: json['num_upvote'] ?? json['numUpvote'] ?? 0,
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
      // Ensure 'timestamp' is correctly parsed. Assuming it's an ISO 8601 string.
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(), // Fallback, ideally timestamp should always be present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'post_id': postId,
      'num_upvote': numUpvote,
      'author': author?.toJson(),
      'post': post?.toJson(), // Be cautious with circular serialization
      'timestamp': timestamp.toIso8601String(), // Added timestamp
    };
  }

  Comment copyWith({
    int? id,
    String? content,
    int? authorId,
    int? postId,
    int? numUpvote,
    User? author,
    Post? post,
    DateTime? timestamp, // Added timestamp
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      postId: postId ?? this.postId,
      numUpvote: numUpvote ?? this.numUpvote,
      author: author ?? this.author,
      post: post ?? this.post,
      timestamp: timestamp ?? this.timestamp, // Added timestamp
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, content: ${content.length > 30 ? '${content.substring(0, 30)}...' : content}, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id && other.timestamp == timestamp; // Consider timestamp for equality if ID can be null for new comments
  }

  @override
  int get hashCode => id.hashCode ^ timestamp.hashCode; // Combine hashCodes
}