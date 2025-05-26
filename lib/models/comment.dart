import 'post.dart';
import 'user.dart';

class Comment {
  final int? id;
  final String content;
  final int authorId;
  final int postId;
  final int numUpvote;
  final User? author;
  final Post? post;

  Comment({
    this.id,
    required this.content,
    required this.authorId,
    required this.postId,
    required this.numUpvote,
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
      'post': post?.toJson(),
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
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      postId: postId ?? this.postId,
      numUpvote: numUpvote ?? this.numUpvote,
      author: author ?? this.author,
      post: post ?? this.post,
    );
  }

  @override
  String toString() {
    return 'Comment{id: $id, content: ${content.length > 30 ? content.substring(0, 30) + '...' : content}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}