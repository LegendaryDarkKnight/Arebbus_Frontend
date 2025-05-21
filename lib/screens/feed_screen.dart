import 'package:arebbus/models/post_model.dart';
import 'package:arebbus/service/mock_data_service.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/widgets/post_card.dart'; 

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late List<Post> _posts;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _posts = MockDataService.getMockPosts();
    _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _upvotePost(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].upvotes++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Placeholder for filter chips or search bar for feed
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Updates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedFilter,
                  icon: const Icon(Icons.filter_list),
                  underline: Container(),
                  items:
                      <String>[
                        'All',
                        'Congestion',
                        'Bus Delay',
                        'New Bus Info',
                        'Route Update',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                      // Implement filtering logic here if needed
                      // For now, it's just a UI element
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Filter by: $_selectedFilter (mock)'),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _posts.isEmpty
                    ? const Center(
                      child: Text(
                        'No community posts yet. Be the first!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return PostCard(
                          post: post,
                          onUpvote: () => _upvotePost(post.id),
                          onComment: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Comment on post: ${post.id} (mock)',
                                ),
                              ),
                            );
                          },
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Share post: ${post.id} (mock)'),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post')));
        },
        label: const Text('Add Post'),
        icon: const Icon(Icons.post_add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
