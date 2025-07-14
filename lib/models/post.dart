import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/tag.dart';

class Post {
  final int id;
  final String authorName;
  final String? authorImage;
  final String content;
  final int numUpvote;
  final List<Tag>? tags;
  final DateTime createdAt;
  final List<Comment>? comments;
  final bool upvoted;

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
