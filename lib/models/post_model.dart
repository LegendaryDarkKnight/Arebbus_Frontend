class Post {
  final String id;
  final String userId;
  final String userName;
  final String userProfileImageUrl; // Mock
  final String content;
  final DateTime timestamp;
  final List<String> tags; // e.g., "congestion", "flyover"
  int upvotes;
  final String? locationTag; // e.g., "Mohakhali Flyover"
  final String? alertType; // e.g., "Congestion", "Accident", "New Bus"

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImageUrl,
    required this.content,
    required this.timestamp,
    required this.tags,
    this.upvotes = 0,
    this.locationTag,
    this.alertType,
  });
}
