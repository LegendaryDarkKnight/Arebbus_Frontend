import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/widgets/post_card.dart';
import 'package:arebbus/service/api_service.dart'; // Added for DioException and potentially for Dio instance if passed
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  List<Post> _posts = []; // Master list of all loaded posts
  List<Post> _filteredPosts = [];
  String _selectedTagFilter = 'All';
  String _sortBy = 'Default';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  bool _showAdvancedFilters = false;
  final List<String> _defaultTags = const [
    'Congestion',
    'Bus Delay',
    'New Bus Info',
    'Route Update',
    'Safety Concern',
    'Station Feedback',
    'Lost & Found',
    'Accessibility',
    'Cleanliness',
    'Crowded',
    'Accident',
    'Service Alert',
  ];

  List<String> _availableFilterTags = [];

  List<Post> _parsePosts(List<dynamic> data) {
    return data.map((item) {
      return Post(
        id: item['postId'],
        authorId:
            null, // If not available in item, you can set it to null or a default
        content: item['content'] ?? '',
        numUpvote: item['numUpvote'] ?? 0,
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
        tags:
            item['tags'] != null
                ? (item['tags'] as List)
                    .map((tag) => Tag(name: tag.toString()))
                    .toList()
                : [],
        comments: [], // Comments not present in this data
      );
    }).toList();
  }

  int _currentPage = 0;
  int _totalPages = 10; // Assume at least one page initially
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 2; // Number of posts per page
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _loadPosts(isRefresh: true); // Initial load
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (!mounted) return;

    ApiService apiService = ApiService();
    if (isRefresh) {
      _currentPage = 0;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
      if (isRefresh) {
        _posts = [];
        _filteredPosts = [];
      }
    });

    try {
      final Map<String, dynamic> data = await apiService.fetchPosts(
        _currentPage,
        _pageSize,
      );
      final List<Post> fetchedPosts = _parsePosts(data['posts']);
      final int totalPagesFromApi = data['totalPages'] as int;
      final int currentPageFromApi = data['page'] as int;

      if (!mounted) return;

      setState(() {
        if (isRefresh || _currentPage == 0) {
          _posts = fetchedPosts;
        } else {
          _posts = fetchedPosts;
        }
        _currentPage = currentPageFromApi; // API returns current page index
        _totalPages = totalPagesFromApi;

        _updateAvailableFilterTags();
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError =
            e.toString().length > 100
                ? "${e.toString().substring(0, 100)}..."
                : e.toString();
        if (isRefresh || _currentPage == 0) {
          _posts = [];
          _filteredPosts = []; // Clear posts on error for initial/refresh
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load posts: $_loadError'),
            backgroundColor: Colors.redAccent,
          ),
        );
      });
      debugPrint('Error in _loadPosts: $e');
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore ||
        _isLoading ||
        !mounted ||
        _currentPage >= _totalPages - 1) {
      // If already loading, or initial load in progress, or no more pages, or not mounted: return
      if (_currentPage >= _totalPages - 1 && _totalPages > 0) {
        // _totalPages could be 0 if API fails initially
        debugPrint("No more posts to load.");
      }
      return;
    }
    ApiService apiService = ApiService();

    setState(() {
      _isLoadingMore = true;
      _loadError = null; // Clear previous load more errors
    });

    try {
      final int nextPage = _currentPage + 1;
      final Map<String, dynamic> data = await apiService.fetchPosts(
        nextPage,
        _pageSize,
      );
      final List<Post> fetchedPosts = _parsePosts(data['posts']);
      final int totalPagesFromApi = data['totalPages'] as int;
      final int currentPageFromApi = data['page'] as int;

      if (!mounted) return;

      setState(() {
        _posts.addAll(fetchedPosts);
        _currentPage = currentPageFromApi; // Update based on API response
        _totalPages = totalPagesFromApi;

        _updateAvailableFilterTags(); // Update tags if new posts brought new tags
        _applyFiltersAndSort();
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadError =
            e.toString().length > 100
                ? "${e.toString().substring(0, 100)}..."
                : e.toString();
        // Show a less intrusive error for "load more"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more posts.'),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      });
      debugPrint('Error in _loadMorePosts: $e');
    }
  }

  void _scrollListener() {
    // Load more when near the bottom of the list
    if (_scrollController.position.extentAfter < 300 &&
        !_isLoadingMore &&
        !_isLoading) {
      if (_currentPage < _totalPages - 1) {
        // Check if there are more pages
        _loadMorePosts();
      }
    }
  }

  void _updateAvailableFilterTags() {
    final Set<String> allPostTags = {};
    for (var post in _posts) {
      post.tags?.forEach((tag) {
        if (tag.name.isNotEmpty) allPostTags.add(tag.name);
      });
    }
    _availableFilterTags =
        {
          'All',
          ..._defaultTags,
          ...allPostTags.where((t) => !_defaultTags.contains(t) && t != 'All'),
        }.toList();
    _availableFilterTags.sort(
      (a, b) => a == "All" ? -1 : (b == "All" ? 1 : a.compareTo(b)),
    );
  }

  void _onSearchChanged() {
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    if (!mounted) return;
    setState(() {
      List<Post> tempPosts = List.from(
        _posts,
      ); // Always filter from the master list

      if (_selectedTagFilter != 'All') {
        tempPosts =
            tempPosts.where((post) {
              return post.tags?.any((tag) => tag.name == _selectedTagFilter) ??
                  false;
            }).toList();
      }

      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        tempPosts =
            tempPosts.where((post) {
              return post.content.toLowerCase().contains(query) ||
                  (post.author?.name.toLowerCase().contains(query) ?? false) ||
                  (post.tags?.any(
                        (tag) => tag.name.toLowerCase().contains(query),
                      ) ??
                      false);
            }).toList();
      }
      if (_sortBy == 'Recent') {
        tempPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else if (_sortBy == 'Popular') {
        tempPosts.sort((a, b) => b.numUpvote.compareTo(a.numUpvote));
      }
      _filteredPosts = tempPosts;
    });
  }

  void _upvotePost(int? postId) {
    if (postId == null) return;
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          numUpvote: _posts[postIndex].numUpvote + 1,
        );
        final filteredPostIndex = _filteredPosts.indexWhere(
          (p) => p.id == postId,
        );
        if (filteredPostIndex != -1) {
          _filteredPosts[filteredPostIndex] = _filteredPosts[filteredPostIndex]
              .copyWith(
                numUpvote: _filteredPosts[filteredPostIndex].numUpvote + 1,
              );
        }
        if (_sortBy == 'Popular') _applyFiltersAndSort();
      }
    });
  }

  void _addComment(int? postId, String commentContent) {
    if (postId == null || commentContent.trim().isEmpty) return;
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch, // Mock ID
          content: commentContent,
          authorId: 1, // Mock user ID
          postId: postId,
          numUpvote: 0,
          timestamp: DateTime.now(),
        );
        final updatedComments = [...?_posts[postIndex].comments, newComment];
        _posts[postIndex] = _posts[postIndex].copyWith(
          comments: updatedComments,
        );

        final filteredPostIndex = _filteredPosts.indexWhere(
          (p) => p.id == postId,
        );
        if (filteredPostIndex != -1) {
          _filteredPosts[filteredPostIndex] = _filteredPosts[filteredPostIndex]
              .copyWith(comments: updatedComments);
        }
      }
    });
  }

  void _addPost(String content, List<String> tagNames) async {
    if (content.trim().isEmpty) return;
    debugPrint('here');
    try {
      ApiService apiService = ApiService();
      final Map<String, dynamic> data = await apiService.createPost(
        content,
        tagNames,
      );
      final newPost = Post(
        id: data['postId'], // Mock ID, ensure this is fine with your backend strategy
        content: content,
        numUpvote: 0,
        timestamp: DateTime.now(),
        tags:
            tagNames
                .map((name) => Tag(id: null, name: name.trim()))
                .where((tag) => tag.name.isNotEmpty)
                .toList(),
        comments: [],
        author: User(
          name: data['authorName'],
          image: 'https://picsum.photos/seed/picsum/200/300',
        ),
      );

      setState(() {
        _posts.insert(0, newPost);

        bool newTagsAddedToFilters = false;
        for (String tagName in tagNames) {
          if (tagName.isNotEmpty && !_availableFilterTags.contains(tagName)) {
            _availableFilterTags.add(tagName);
            newTagsAddedToFilters = true;
          }
        }
        if (newTagsAddedToFilters) {
          _availableFilterTags.sort(
            (a, b) =>
                a == "All"
                    ? -1
                    : b == "All"
                    ? 1
                    : a.compareTo(b),
          );
        }
        _applyFiltersAndSort(); // Re-apply filters and sort
      });
    } catch (e) {
      debugPrint("error in adding post $e");
    }
  }

  void _showAddPostDialog() {
    final contentController = TextEditingController();
    final customTagController = TextEditingController();
    Set<String> selectedTagsInDialog = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Post',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'What\'s on your mind?',
                        hintText: 'Share an update or ask a question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(150),
                      ),
                      maxLines: 5,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Tags:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          _defaultTags.map((tag) {
                            final isSelected = selectedTagsInDialog.contains(
                              tag,
                            );
                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    selectedTagsInDialog.add(tag);
                                  } else {
                                    selectedTagsInDialog.remove(tag);
                                  }
                                });
                              },
                              selectedColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              checkmarkColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: customTagController,
                      decoration: InputDecoration(
                        labelText: 'Custom Tags',
                        hintText: 'e.g., Event, Suggestion (comma-separated)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send_outlined),
                          label: const Text('Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (contentController.text.isNotEmpty) {
                              final customTagsRaw =
                                  customTagController.text
                                      .split(',')
                                      .map((tag) => tag.trim())
                                      .where((tag) => tag.isNotEmpty)
                                      .toList();
                              final allTagsForPost =
                                  {
                                    ...selectedTagsInDialog,
                                    ...customTagsRaw,
                                  }.toList();
                              _addPost(contentController.text, allTagsForPost);
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Post content cannot be empty.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  String _getActiveFilterSummary() {
    List<String> activeFilters = [];
    if (_selectedTagFilter != 'All') {
      activeFilters.add('Tag: $_selectedTagFilter');
    }
    if (_sortBy != 'Recent' || _sortBy != 'Default') {
      activeFilters.add('Sorted by: $_sortBy');
    }
    if (_searchController.text.isNotEmpty) {
      activeFilters.add('Search: "${_searchController.text}"');
    }
    return activeFilters.isEmpty
        ? 'No active filters'
        : activeFilters.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasActiveFilters =
        _selectedTagFilter != 'All' ||
        _sortBy != 'Recent' || _sortBy != 'Default' ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 1.0,
              color: theme.canvasColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search posts, authors, or tags...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        filled: true,
                        // Assuming theme.colorScheme.surfaceContainerHighest.withValues is a custom extension or should be .withOpacity() or .withAlpha()
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.6), // Corrected to use withOpacity
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                        ),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged();
                                  },
                                ) // Ensure _onSearchChanged is called
                                : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showAdvancedFilters = !_showAdvancedFilters;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showAdvancedFilters
                                      ? Icons.tune_rounded
                                      : Icons.tune_outlined,
                                  color:
                                      hasActiveFilters
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showAdvancedFilters
                                      ? 'Hide Filters'
                                      : 'Show Filters',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color:
                                        hasActiveFilters
                                            ? theme.colorScheme.primary
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (hasActiveFilters &&
                                    !_showAdvancedFilters) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.circle,
                                    color: theme.colorScheme.primary,
                                    size: 8,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 0.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(
                                    alpha: 0.5,
                                  ), // Corrected to use withOpacity
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: Icon(
                                Icons.sort,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              dropdownColor: theme.cardColor,
                              items:
                                  <String>['Recent', 'Popular', 'Default']
                                      .map<DropdownMenuItem<String>>(
                                        (String value) =>
                                            DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ),
                                      )
                                      .toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _sortBy = newValue;
                                    _applyFiltersAndSort();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Visibility(
                        visible: _showAdvancedFilters,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filter by Tag:',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (_selectedTagFilter != 'All')
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: theme.colorScheme.error,
                                      ),
                                      label: Text(
                                        'Clear Tag',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                      onPressed:
                                          () => setState(() {
                                            _selectedTagFilter = 'All';
                                            _applyFiltersAndSort();
                                          }),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 38,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      _availableFilterTags.map((tag) {
                                        final isSelected =
                                            _selectedTagFilter == tag;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: FilterChip(
                                            label: Text(
                                              tag,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            selected: isSelected,
                                            onSelected:
                                                (bool sel) => setState(() {
                                                  _selectedTagFilter =
                                                      sel ? tag : 'All';
                                                  _applyFiltersAndSort();
                                                }),
                                            selectedColor:
                                                theme
                                                    .colorScheme
                                                    .primaryContainer,
                                            checkmarkColor:
                                                theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                            labelStyle: TextStyle(
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              fontSize: 12,
                                              color:
                                                  isSelected
                                                      ? theme
                                                          .colorScheme
                                                          .onPrimaryContainer
                                                      : theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color,
                                            ),
                                            backgroundColor: theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(0.3), // Corrected
                                            shape: StadiumBorder(
                                              side: BorderSide(
                                                color:
                                                    isSelected
                                                        ? theme
                                                            .colorScheme
                                                            .primary
                                                            .withOpacity(0.7)
                                                        : Colors.grey.shade400,
                                                width: 0.8,
                                              ),
                                            ), // Corrected
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                              if (hasActiveFilters &&
                                  !_showAdvancedFilters) // Show summary if collapsed and filters are active
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _getActiveFilterSummary(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadPosts(isRefresh: true),
                color: theme.colorScheme.primary,
                child:
                    _isLoading &&
                            _posts
                                .isEmpty // Show main loader only if truly initial loading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                          ),
                        )
                        : _loadError != null &&
                            _posts
                                .isEmpty // Show error if initial load failed and no posts are available
                        ? LayoutBuilder(
                          builder:
                              (context, constraints) => SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 70,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Failed to Load Posts',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _loadError ??
                                                'An unknown error occurred. Pull down to try again.',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        )
                        : _filteredPosts.isEmpty &&
                            !_isLoading // Show "no posts" only if not loading and no error preventing display
                        ? LayoutBuilder(
                          builder:
                              (context, constraints) => SingleChildScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(), // Make it scrollable for refresh
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.filter_drama_outlined,
                                            size: 70,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            _searchController.text.isNotEmpty ||
                                                    _selectedTagFilter != 'All'
                                                ? 'No Posts Match Your Criteria'
                                                : 'No Posts Yet!',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _searchController.text.isNotEmpty ||
                                                    _selectedTagFilter != 'All'
                                                ? 'Try adjusting your search or filters.'
                                                : 'Be the first to share something interesting!',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          if (!(_searchController
                                                  .text
                                                  .isNotEmpty ||
                                              _selectedTagFilter != 'All'))
                                            ElevatedButton.icon(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              label: const Text('Add a Post'),
                                              onPressed: _showAddPostDialog,
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          itemCount:
                              _filteredPosts.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _filteredPosts.length &&
                                _isLoadingMore) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (index >= _filteredPosts.length)
                              return const SizedBox.shrink(); // Should not happen if itemCount is correct

                            final post = _filteredPosts[index];
                            return PostCard(
                              post: post,
                              onUpvote: () => _upvotePost(post.id),
                              onComment: () => _showAddCommentDialog(post.id),
                              onShare: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sharing post: "${post.content.substring(0, post.content.length > 20 ? 20 : post.content.length)}..." (mock)',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPostDialog,
        tooltip: 'Add New Post',
        icon: const Icon(Icons.edit_outlined),
        label: const Text(
          'Post',
        ), // Changed from Text('') to 'Post' for better UX
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showAddCommentDialog(int? postId) {
    if (postId == null) return;
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Comment'),
            content: TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Your comment',
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              minLines: 1,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (commentController.text.isNotEmpty) {
                    _addComment(postId, commentController.text);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment cannot be empty.'),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  }
                },
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }
}
