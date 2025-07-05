class Comment {
  final int id;
  final String content;
  final String authorName;
  final int postId;
  final DateTime createdAt;
  final int numUpvote;
  final bool upvoted;
  final String? authorImage;

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
