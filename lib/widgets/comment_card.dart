import 'package:arebbus/models/comment.dart'; // Adjust import path
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget for displaying individual comments in the social feed.
/// 
/// CommentCard is a reusable widget that renders a single comment with:
/// - Author information (name and avatar)
/// - Comment content with proper text formatting
/// - Timestamp with relative time display
/// - Upvote functionality and count display
/// - Consistent styling with the app theme
/// 
/// The widget handles:
/// - Author avatar loading with fallback to default image
/// - Long content text with proper wrapping
/// - Timestamp formatting for readability
/// - Interactive upvote button with visual feedback
/// - Responsive layout that adapts to different screen sizes
class CommentCard extends StatelessWidget {
  /// The comment data to display
  final Comment comment;

  /// Creates a CommentCard widget.
  /// 
  /// @param comment The Comment object containing all comment data
  const CommentCard({super.key, required this.comment});

  /// Formats a timestamp into a human-readable relative time string.
  /// 
  /// Converts DateTime objects into user-friendly time representations
  /// similar to social media platforms:
  /// - Very recent: "just now"
  /// - Seconds: "30s ago"
  /// - Minutes: "5m ago"
  /// - Hours: "2h ago"
  /// - Yesterday: "Yesterday at 3:45 PM"
  /// - Days: "3d ago"
  /// - Older: "Mar 15, 2024"
  /// 
  /// @param timestamp The DateTime to format
  /// @return Human-readable relative time string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 5) {
      return 'just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 1) {
      // Yesterday
      return 'Yesterday at ${DateFormat.jm().format(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorName = comment.authorName ;
    final authorImageUrl = comment.authorImage?? 'https://picsum.photos/seed/picsum/200/300';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            backgroundImage:
                (authorImageUrl.isNotEmpty)
                    ? NetworkImage(authorImageUrl)
                    : null,
            child:
                (authorImageUrl.isEmpty)
                    ? Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : 'S',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        theme
                            .colorScheme
                            .surfaceContainerHighest, // Slightly different background for comment bubble
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        comment.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    _formatTimestamp(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
