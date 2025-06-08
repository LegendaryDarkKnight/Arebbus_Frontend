import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/widgets/comment_card.dart';

// Utility class for common PostCard functionalities
class PostCardUtils {
  static String formatTimestamp(DateTime timestamp) {
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
    }
    return DateFormat('MMM d, yyyy').format(timestamp);
  }

  static TagAppearance getTagAppearance(String? tagName, ThemeData theme) {
    final defaultAppearance = TagAppearance(
      chipBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      chipForegroundColor: theme.colorScheme.onSurfaceVariant,
      iconData: FontAwesomeIcons.infoCircle,
      cardAccentColor: theme.colorScheme.outline.withOpacity(0.5),
    );

    if (tagName == null) return defaultAppearance;

    const tagStyles = {
      'Congestion': TagAppearance(
        chipBackgroundColor: Color(0xFFFFCDD2),
        chipForegroundColor: Color(0xFFB71C1C),
        iconData: FontAwesomeIcons.carBurst,
        cardAccentColor: Color(0xFFEF5350),
      ),
      'Bus Delay': TagAppearance(
        chipBackgroundColor: Color(0xFFFFE0B2),
        chipForegroundColor: Color(0xFFF57C00),
        iconData: FontAwesomeIcons.clock,
        cardAccentColor: Color(0xFFFFA726),
      ),
      'New Bus Info': TagAppearance(
        chipBackgroundColor: Color(0xFFC8E6C9),
        chipForegroundColor: Color(0xFF2E7D32),
        iconData: FontAwesomeIcons.busSimple,
        cardAccentColor: Color(0xFF4CAF50),
      ),
      'Route Update': TagAppearance(
        chipBackgroundColor: Color(0xFFBBDEFB),
        chipForegroundColor: Color(0xFF0D47A1),
        iconData: FontAwesomeIcons.route,
        cardAccentColor: Color(0xFF42A5F5),
      ),
      'Accident': TagAppearance(
        chipBackgroundColor: Color(0xFFFFCCBC),
        chipForegroundColor: Color(0xFFE64A19),
        iconData: FontAwesomeIcons.triangleExclamation,
        cardAccentColor: Color(0xFFFF8A65),
      ),
      'Service Alert': TagAppearance(
        chipBackgroundColor: Color(0xFFFFECB3),
        chipForegroundColor: Color(0xFFFF8F00),
        iconData: FontAwesomeIcons.bell,
        cardAccentColor: Color(0xFFFFCA28),
      ),
    };

    return tagStyles[tagName] ?? defaultAppearance;
  }

  static List<Comment> parseComments(List<dynamic> data) {
    return data.map((item) {
      return Comment(
        id: item['id'] as int,
        content: item['content'] as String? ?? '',
        numUpvote: item['numUpvote'] as int? ?? 0,
        postId: item['postId'] as int,
        timestamp: item['createdAt'] != null
            ? DateTime.parse(item['createdAt'] as String)
            : DateTime.now(),
        author: item['authorName'] != null
            ? User(
                name: item['authorName'] as String,
                image: 'https://picsum.photos/seed/picsum/200/300',
              )
            : null,
      );
    }).toList();
  }
}

// Data class for tag appearance
class TagAppearance {
  final Color chipBackgroundColor;
  final Color chipForegroundColor;
  final IconData iconData;
  final Color cardAccentColor;

  const TagAppearance({
    required this.chipBackgroundColor,
    required this.chipForegroundColor,
    required this.iconData,
    required this.cardAccentColor,
  });
}

// Constants for styling
class PostCardConstants {
  static const double cardMarginVertical = 8.0;
  static const double cardMarginHorizontal = 4.0;
  static const double cardElevation = 1.5;
  static const double borderRadius = 16.0;
  static const double padding = 16.0;
  static const double avatarRadius = 22.0;
  static const double chipSpacing = 6.0;
  static const double chipRunSpacing = 4.0;
  static const double dividerThickness = 0.8;
  static const double buttonPaddingHorizontal = 10.0;
  static const double buttonPaddingVertical = 8.0;
}

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCard({
    super.key,
    required this.post,
    required this.onUpvote,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showComments = false;
  List<Comment> _comments = [];
  bool _isLoadingComments = false;

  Future<void> _fetchComments(int postId) async {
    if (_showComments) {
      setState(() => _showComments = false);
      return;
    }

    setState(() => _isLoadingComments = true);
    try {
      final data = await ApiService.instance.getPostById(postId);
      final commentsData = data?['comments'] as List<dynamic>? ?? [];
      setState(() {
        _comments = PostCardUtils.parseComments(commentsData);
        _showComments = true;
      });
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  String? _getPrimaryTagName() {
    if (widget.post.tags == null || widget.post.tags!.isEmpty) return null;

    const priorityTags = [
      'Congestion',
      'Bus Delay',
      'Accident',
      'Service Alert',
      'New Bus Info',
      'Route Update',
    ];

    try {
      return widget.post.tags!
          .firstWhere((tag) => priorityTags.contains(tag.name))
          .name;
    } catch (e) {
      return widget.post.tags!.first.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = PostCardUtils.formatTimestamp(widget.post.timestamp);
    final primaryTagName = _getPrimaryTagName();
    final tagAppearance = PostCardUtils.getTagAppearance(primaryTagName, theme);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: PostCardConstants.cardMarginVertical,
        horizontal: PostCardConstants.cardMarginHorizontal,
      ),
      elevation: PostCardConstants.cardElevation,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: tagAppearance.cardAccentColor.withOpacity(0.7),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(PostCardConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PostCardConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, timeAgo, primaryTagName, tagAppearance),
            const SizedBox(height: 12),
            _buildContent(theme),
            if (widget.post.tags != null && widget.post.tags!.isNotEmpty)
              _buildTags(theme),
            _buildDivider(theme),
            _buildActionButtons(theme),
            _buildCommentsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    String timeAgo,
    String? primaryTagName,
    TagAppearance tagAppearance,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(theme),
        const SizedBox(width: 12),
        Expanded(child: _buildUserInfo(theme, timeAgo)),
        if (primaryTagName != null) _buildTagChip(theme, primaryTagName, tagAppearance),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: PostCardConstants.avatarRadius,
      backgroundImage: widget.post.author?.image != null &&
              widget.post.author!.image.isNotEmpty
          ? NetworkImage(widget.post.author!.image)
          : null,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: widget.post.author?.image == null ||
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
    );
  }

  Widget _buildUserInfo(ThemeData theme, String timeAgo) {
    return Column(
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
    );
  }

  Widget _buildTagChip(ThemeData theme, String tagName, TagAppearance tagAppearance) {
    return Chip(
      avatar: FaIcon(
        tagAppearance.iconData,
        size: 14,
        color: tagAppearance.chipForegroundColor,
      ),
      label: Text(
        tagName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tagAppearance.chipForegroundColor,
        ),
      ),
      backgroundColor: tagAppearance.chipBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PostCardConstants.borderRadius),
        side: BorderSide(
          color: tagAppearance.chipForegroundColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      widget.post.content,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.45,
        color: theme.colorScheme.onSurface.withOpacity(0.85),
      ),
    );
  }

  Widget _buildTags(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: PostCardConstants.chipSpacing,
        runSpacing: PostCardConstants.chipRunSpacing,
        children: widget.post.tags!.map((tag) => Chip(
          label: Text(
            '#${tag.name}',
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9),
            ),
          ),
          backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        )).toList(),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Divider(
        height: 16,
        thickness: PostCardConstants.dividerThickness,
        color: theme.dividerColor.withOpacity(0.5),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInteractionButton(
          theme: theme,
          icon: FontAwesomeIcons.solidThumbsUp,
          label: '${widget.post.numUpvote}',
          onPressed: widget.onUpvote,
          color: theme.colorScheme.primary,
          isPrimary: true,
          tooltip: 'Upvote',
        ),
        _buildInteractionButton(
          theme: theme,
          icon: _showComments
              ? FontAwesomeIcons.solidCommentDots
              : FontAwesomeIcons.commentDots,
          label: '',
          onPressed: () => _fetchComments(widget.post.id),
          color: _showComments
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          tooltip: _showComments ? 'Hide Comments' : 'Show Comments',
        ),
        _buildInteractionButton(
          theme: theme,
          icon: FontAwesomeIcons.plusCircle,
          label: '',
          onPressed: widget.onComment,
          color: theme.colorScheme.secondary,
          tooltip: 'Add Comment',
        ),
        _buildInteractionButton(
          theme: theme,
          icon: FontAwesomeIcons.shareNodes,
          label: '',
          onPressed: widget.onShare,
          color: theme.colorScheme.onSurfaceVariant,
          tooltip: 'Share',
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(PostCardConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PostCardConstants.buttonPaddingHorizontal,
            vertical: PostCardConstants.buttonPaddingVertical,
          ),
          child: Row(
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
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection(ThemeData theme) {
    return AnimatedSize(
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
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            if (_isLoadingComments)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_comments.isEmpty)
              _buildEmptyComments(theme)
            else
              _buildCommentsList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyComments(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'No comments yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const FaIcon(FontAwesomeIcons.commentMedical, size: 16),
              label: const Text('Be the first to comment'),
              onPressed: widget.onComment,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            'Comments (${_comments.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) => CommentCard(comment: _comments[index]),
        ),
      ],
    );
  }
}