import 'package:flutter/material.dart';
import 'package:arebbus/models/post_model.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimestamp(post.timestamp);

    Color alertColor = theme.primaryColorLight;
    IconData alertIcon = FontAwesomeIcons.infoCircle;

    switch (post.alertType) {
        case 'Congestion':
            alertColor = Colors.redAccent.withOpacity(0.1);
            alertIcon = FontAwesomeIcons.carBurst;
            break;
        case 'Bus Delay':
            alertColor = Colors.orangeAccent.withOpacity(0.1);
            alertIcon = FontAwesomeIcons.clockFour;
            break;
        case 'New Bus Info':
            alertColor = Colors.greenAccent.withOpacity(0.15);
            alertIcon = FontAwesomeIcons.bus;
            break;
        case 'Route Update':
            alertColor = Colors.blueAccent.withOpacity(0.1);
            alertIcon = FontAwesomeIcons.mapSigns;
            break;
    }


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: alertColor == theme.primaryColorLight ? Colors.transparent : alertColor.withOpacity(0.8), width: 1.5),
        borderRadius: BorderRadius.circular(12.0)
      ),
      color: alertColor, // Background color based on alert type
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.userProfileImageUrl),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (post.alertType != null)
                    Chip(
                        avatar: FaIcon(alertIcon, size: 14, color: _getIconColorForAlert(post.alertType, theme)),
                        label: Text(post.alertType!, style: TextStyle(fontSize: 11, color: _getIconColorForAlert(post.alertType, theme))),
                        backgroundColor: _getChipBackgroundColorForAlert(post.alertType, theme).withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: post.tags.map((tag) => Chip(
                  label: Text('#$tag', style: TextStyle(fontSize: 11, color: theme.primaryColorDark)),
                  backgroundColor: theme.primaryColorLight.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
             if (post.locationTag != null && post.locationTag!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(post.locationTag!, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic))),
                ],
              )
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInteractionButton(
                  context,
                  icon: FontAwesomeIcons.thumbsUp,
                  label: '${post.upvotes} Upvotes',
                  onPressed: onUpvote,
                  color: theme.primaryColor,
                ),
                _buildInteractionButton(
                  context,
                  icon: FontAwesomeIcons.commentDots,
                  label: 'Comment',
                  onPressed: onComment,
                  color: Colors.grey[700],
                ),
                _buildInteractionButton(
                  context,
                  icon: FontAwesomeIcons.shareNodes,
                  label: 'Share',
                  onPressed: onShare,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  Color _getIconColorForAlert(String? alertType, ThemeData theme) {
    switch (alertType) {
        case 'Congestion': return Colors.red.shade800;
        case 'Bus Delay': return Colors.orange.shade800;
        case 'New Bus Info': return Colors.green.shade800;
        case 'Route Update': return Colors.blue.shade800;
        default: return theme.primaryColorDark;
    }
  }
   Color _getChipBackgroundColorForAlert(String? alertType, ThemeData theme) {
    switch (alertType) {
        case 'Congestion': return Colors.red.shade100;
        case 'Bus Delay': return Colors.orange.shade100;
        case 'New Bus Info': return Colors.green.shade100;
        case 'Route Update': return Colors.blue.shade100;
        default: return theme.primaryColorLight;
    }
  }


  Widget _buildInteractionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed, Color? color}) {
    return TextButton.icon(
      icon: FaIcon(icon, size: 16, color: color ?? Theme.of(context).primaryColor),
      label: Text(label, style: TextStyle(fontSize: 13, color: color ?? Theme.of(context).primaryColor)),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
