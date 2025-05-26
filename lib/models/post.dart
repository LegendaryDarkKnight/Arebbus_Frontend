import 'comment.dart';
import 'tag.dart';
import 'user.dart';

class Post {
  final int? id;
  final int authorId;
  final String content;
  final int numUpvote;
  final DateTime timestamp; // Added timestamp for sorting
  final User? author;
  final List<Tag>? tags;
  final List<Comment>? comments;

  Post({
    this.id,
    required this.authorId,
    required this.content,
    required this.numUpvote,
    required this.timestamp,
    this.author,
    this.tags,
    this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorId: json['author_id'] ?? json['authorId'],
      content: json['content'] ?? '',
      numUpvote: json['num_upvote'] ?? json['numUpvote'] ?? 0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      tags: json['tags'] != null 
          ? (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((comment) => Comment.fromJson(comment)).toList()
          : null,
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