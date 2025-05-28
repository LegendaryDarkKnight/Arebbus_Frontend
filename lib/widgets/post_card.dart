import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/models/post.dart'; // Ensure this path is correct
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:arebbus/widgets/comment_card.dart'; // Import the new CommentCard

// Helper class to define the visual appearance based on a tag (remains the same)
class _TagAppearance {
  final Color chipBackgroundColor;
  final Color chipForegroundColor;
  final IconData iconData;
  final Color cardAccentColor;

  _TagAppearance({
    required this.chipBackgroundColor,
    required this.chipForegroundColor,
    required this.iconData,
    required this.cardAccentColor,
  });
}

class PostCard extends StatefulWidget {
  // Changed to StatefulWidget
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onComment; // This will be for ADDING a comment
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onUpvote,
    required this.onComment, // Callback to trigger add comment dialog
    required this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // State class for PostCard
  bool _showComments = false; // State to manage comment visibility
  List<Comment> comments = [];
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
      return 'Yesterday at ${DateFormat.jm().format(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  _TagAppearance _getTagAppearance(String? tagName, ThemeData theme) {
    _TagAppearance defaultAppearance = _TagAppearance(
      chipBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      chipForegroundColor: theme.colorScheme.onSurfaceVariant,
      iconData: FontAwesomeIcons.infoCircle,
      cardAccentColor: theme.colorScheme.outline.withValues(alpha: 0.5),
    );

    if (tagName == null) return defaultAppearance;
    switch (tagName) {
      case 'Congestion':
        return _TagAppearance(
          chipBackgroundColor: Colors.red.shade100,
          chipForegroundColor: Colors.red.shade800,
          iconData: FontAwesomeIcons.carBurst,
          cardAccentColor: Colors.red.shade400,
        );
      case 'Bus Delay':
        return _TagAppearance(
          chipBackgroundColor: Colors.orange.shade100,
          chipForegroundColor: Colors.orange.shade800,
          iconData: FontAwesomeIcons.clock,
          cardAccentColor: Colors.orange.shade400,
        );
      case 'New Bus Info':
        return _TagAppearance(
          chipBackgroundColor: Colors.green.shade100,
          chipForegroundColor: Colors.green.shade800,
          iconData: FontAwesomeIcons.busSimple,
          cardAccentColor: Colors.green.shade400,
        );
      case 'Route Update':
        return _TagAppearance(
          chipBackgroundColor: Colors.blue.shade100,
          chipForegroundColor: Colors.blue.shade800,
          iconData: FontAwesomeIcons.route,
          cardAccentColor: Colors.blue.shade400,
        );
      case 'Accident':
        return _TagAppearance(
          chipBackgroundColor: Colors.deepOrange.shade100,
          chipForegroundColor: Colors.deepOrange.shade900,
          iconData: FontAwesomeIcons.triangleExclamation,
          cardAccentColor: Colors.deepOrange.shade400,
        );
      case 'Service Alert':
        return _TagAppearance(
          chipBackgroundColor: Colors.amber.shade100,
          chipForegroundColor: Colors.amber.shade900,
          iconData: FontAwesomeIcons.bell,
          cardAccentColor: Colors.amber.shade600,
        );
      default:
        return defaultAppearance;
    }
  }

  List<Comment> _pareseComments(List<dynamic> data) {
    return data.map((item) {
      return Comment(
        id: item['id'],
        content: item['content'] ?? '',
        numUpvote: item['numUpvote'] ?? 0,
        postId: item['postId'],
        timestamp:
            item['createdAt'] != null
                ? DateTime.parse(item['createdAt'])
                : DateTime.now(),
        author:
            item['authorName'] != null
                ? User(
                  name: item['authorName'],
                  image: 'https://picsum.photos/seed/picsum/200/300',
                ) // You may need to adapt based on your `User` class
                : null,
      );
    }).toList();
  }

  void _fetchComments(int? postId) async {
    if (_showComments) {
      setState(() => _showComments = !_showComments);
      return;
    }
    try {
      ApiService apiService = ApiService();
      Map<String, dynamic>? data = await apiService.getPostById(postId);
      final List<dynamic> getComments = data?['comments'];
      debugPrint('$getComments');
      final List<Comment> retracted = _pareseComments(getComments);
      setState(() => comments = retracted);
      setState(() => _showComments = !_showComments);
    } catch (e) {
      debugPrint("error occured fetching comment $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimestamp(widget.post.timestamp); // Use widget.post
    comments.addAll(widget.post.comments ?? []);

    String? primaryTagName;
    if (widget.post.tags != null && widget.post.tags!.isNotEmpty) {
      try {
        primaryTagName =
            widget.post.tags!
                .firstWhere(
                  (tag) => [
                    'Congestion',
                    'Bus Delay',
                    'Accident',
                    'Service Alert',
                    'New Bus Info',
                    'Route Update',
                  ].contains(tag.name),
                )
                .name;
      } catch (e) {
        primaryTagName = widget.post.tags!.first.name;
      }
    }

    final tagAppearance = _getTagAppearance(primaryTagName, theme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: tagAppearance.cardAccentColor.withValues(alpha: 0.7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      widget.post.author?.image != null &&
                              widget.post.author!.image.isNotEmpty
                          ? NetworkImage(widget.post.author!.image)
                          : null,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child:
                      widget.post.author?.image == null ||
                              widget.post.author!.image.isEmpty
                          ? Text(
                            widget.post.author?.name.isNotEmpty == true
                                ? widget.post.author!.name[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 18,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author?.name ?? 'Unknown User',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (primaryTagName != null)
                  Chip(
                    avatar: FaIcon(
                      tagAppearance.iconData,
                      size: 14,
                      color: tagAppearance.chipForegroundColor,
                    ),
                    label: Text(
                      primaryTagName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: tagAppearance.chipForegroundColor,
                      ),
                    ),
                    backgroundColor: tagAppearance.chipBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: tagAppearance.chipForegroundColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.post.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
            if (widget.post.tags != null && widget.post.tags!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children:
                    widget.post.tags!
                        .map(
                          (tag) => Chip(
                            label: Text(
                              '#${tag.name}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSecondaryContainer
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                            backgroundColor: theme
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 1.0,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Divider(
                height: 16,
                thickness: 0.8,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            // Action Buttons Row
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween, // Use spaceBetween for wider spread
              children: [
                _buildInteractionButton(
                  theme: theme,
                  icon: FontAwesomeIcons.solidThumbsUp,
                  label: '${widget.post.numUpvote}',
                  onPressed: widget.onUpvote,
                  color: theme.colorScheme.primary,
                  isPrimary: true,
                  tooltip: "Upvote",
                ),
                _buildInteractionButton(
                  // Button to toggle comment visibility
                  theme: theme,
                  icon:
                      _showComments
                          ? FontAwesomeIcons.solidCommentDots
                          : FontAwesomeIcons.commentDots,
                  label: '', //'${comments.length}',
                  onPressed: () => _fetchComments(widget.post.id),
                  color:
                      _showComments
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                  tooltip: _showComments ? "Hide Comments" : "Show Comments",
                ),
                _buildInteractionButton(
                  // Dedicated Add Comment Button
                  theme: theme,
                  icon: FontAwesomeIcons.plusCircle,
                  label: '', // No label, icon only
                  onPressed: widget.onComment, // Triggers add comment dialog
                  color: theme.colorScheme.secondary,
                  tooltip: "Add Comment",
                ),
                _buildInteractionButton(
                  theme: theme,
                  icon: FontAwesomeIcons.shareNodes,
                  label: '', // No label, icon only
                  onPressed: widget.onShare,
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: "Share",
                ),
              ],
            ),

            // Collapsible Comments Section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: _showComments,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: theme.dividerColor.withValues(alpha: .3),
                      ),
                    ),
                    if (comments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text(
                          "Comments (${comments.length})",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (comments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "No comments yet.",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                icon: const FaIcon(
                                  FontAwesomeIcons.commentMedical,
                                  size: 16,
                                ),
                                label: const Text("Be the first to comment"),
                                onPressed:
                                    widget
                                        .onComment, // Trigger add comment dialog
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap:
                            true, // Important for ListView inside Column
                        physics:
                            const NeverScrollableScrollPhysics(), // Also important
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return CommentCard(comment: comments[index]);
                        },
                      ),
                    // Optional: Add a quick comment TextField directly here (more advanced)
                    // For now, rely on the "Add Comment" icon button in the action bar.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
    required String tooltip, // Added tooltip
  }) {
    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: isPrimary ? 17 : 15, color: color),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: (isPrimary
                    ? theme.textTheme.labelMedium
                    : theme.textTheme.bodySmall)
                ?.copyWith(
                  color: color,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ],
    );

    return Tooltip(
      // Added Tooltip
      message: tooltip,
      child: InkWell(
        // Using InkWell for custom tap area and visual feedback
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8), // For ripple effect shape
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ), // Adjusted padding
          child: buttonContent,
        ),
      ),
    );
  }
}
