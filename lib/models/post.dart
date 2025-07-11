import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/models/user.dart';

class Post {
  final int id;
  final int? authorId;
  final String content;
  final int numUpvote;
  final DateTime timestamp; // Added timestamp for sorting
  final User? author;
  final List<Tag>? tags;
  final List<Comment>? comments;
  final bool? upvoted;

  Post({
    required this.id,
    this.authorId,
    required this.content,
    required this.numUpvote,
    required this.timestamp,
    this.author,
    this.tags,
    this.comments,
    this.upvoted,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorId: json['author_id'] ?? json['authorId'],
      content: json['content'] ?? '',
      numUpvote: json['num_upvote'] ?? json['numUpvote'] ?? 0,
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'content': content,
      'num_upvote': numUpvote,
      'timestamp': timestamp.toIso8601String(),
      'author': author?.toJson(),
      'tags': tags?.map((tag) => tag.toJson()).toList(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'upvoted': upvoted,
    };
  }

  Post copyWith({
    int? id,
    int? authorId,
    String? content,
    int? numUpvote,
    DateTime? timestamp,
    User? author,
    List<Tag>? tags,
    List<Comment>? comments,
    bool? upvoted,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      numUpvote: numUpvote ?? this.numUpvote,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      upvoted: upvoted ?? this.upvoted,
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
