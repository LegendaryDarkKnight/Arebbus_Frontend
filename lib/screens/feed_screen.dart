import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/utils/feed_screen_utils.dart';
import 'package:arebbus/widgets/post_card.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  String _selectedTagFilter = 'All';
  String _sortBy = 'Default';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  late FeedScreenUtils _feedScreenUtils;
  bool _showAdvancedFilters = false;
  List<String> _availableFilterTags = [];
  int _currentPage = 0;
  int _totalPages = 10;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  String? _loadError;
  bool _useBackendFiltering = false;
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _feedScreenUtils = FeedScreenUtils();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _loadAvailableTags();
    _loadPosts(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // UI Event Handlers
  void _onSearchChanged() {
    _applyFiltersAndSort();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 300 &&
        !_isLoadingMore &&
        !_isLoading) {
      if (_currentPage < _totalPages - 1) {
        _loadMorePosts();
      }
    }
  }

  // Data Loading Methods
  Future<void> _loadAvailableTags() async {
    try {
      final tags = await _feedScreenUtils.loadAllAvailableTags();
      if (mounted) {
        setState(() {
          _availableFilterTags = tags;
        });
      }
    } catch (e) {
      debugPrint('Error loading available tags: $e');
    }
  }

  Future<void> _loadPosts({bool isRefresh = false}) async {
    if (!mounted) return;

    // Determine filter tags for backend call
    List<String>? filterTags;
    if (_useBackendFiltering && _selectedTags.isNotEmpty) {
      filterTags = _selectedTags;
    }

    final result = await _feedScreenUtils.loadPosts(
      currentPage: isRefresh ? 0 : _currentPage,
      pageSize: isRefresh || _currentPage == 0 ? 4 : 2,
      isRefresh: isRefresh,
      existingPosts: _posts,
      filterTags: filterTags,
    );

    if (!mounted) return;

    setState(() {
      _posts = result['posts'];
      _currentPage = result['currentPage'];
      _totalPages = result['totalPages'];
      _isLoading = result['isLoading'];
      _loadError = result['error'];

      if (!_useBackendFiltering) {
        _updateAvailableFilterTags();
        _applyFiltersAndSort();
      } else {
        _filteredPosts = _posts;
      }
    });

    if (result['error'] != null) {
      _showErrorSnackBar(
        'Failed to load posts: ${result['error']}',
        Colors.redAccent,
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore ||
        _isLoading ||
        !mounted ||
        _currentPage >= _totalPages - 1) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadError = null;
    });

    // Determine filter tags for backend call
    List<String>? filterTags;
    if (_useBackendFiltering && _selectedTags.isNotEmpty) {
      filterTags = _selectedTags;
    }

    final result = await _feedScreenUtils.loadMorePosts(
      currentPage: _currentPage,
      pageSize: 2,
      existingPosts: _posts,
      filterTags: filterTags,
    );

    if (!mounted) return;

    setState(() {
      _posts = result['posts'];
      _currentPage = result['currentPage'];
      _totalPages = result['totalPages'];
      _isLoading = false;
      _isLoadingMore = false;
      _loadError = result['error'];

      if (!_useBackendFiltering) {
        _updateAvailableFilterTags();
        _applyFiltersAndSort();
      } else {
        _filteredPosts = _posts;
      }
    });

    if (result['error'] != null) {
      _showErrorSnackBar('Failed to load more posts.', Colors.orangeAccent);
    }
  }

  // Filtering and Sorting
  void _updateAvailableFilterTags() {
    _availableFilterTags = _feedScreenUtils.getAvailableFilterTags(_posts);
  }

  void _applyFiltersAndSort() {
    if (!mounted) return;
    setState(() {
      _filteredPosts = _feedScreenUtils.applyFiltersAndSort(
        posts: _posts,
        selectedTagFilter: _selectedTagFilter,
        searchQuery: _searchController.text,
        sortBy: _sortBy,
      );
    });
  }

  void _toggleBackendFiltering() {
    setState(() {
      _useBackendFiltering = !_useBackendFiltering;
      if (_useBackendFiltering) {
        // Switch to backend filtering
        if (_selectedTagFilter != 'All') {
          _selectedTags = [_selectedTagFilter];
        } else {
          _selectedTags = [];
        }
        _loadPosts(isRefresh: true);
      } else {
        // Switch back to frontend filtering
        _selectedTags = [];
        _loadPosts(isRefresh: true);
      }
    });
  }

  void _onTagSelectionChanged(String tag, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedTags.contains(tag)) {
          _selectedTags.add(tag);
        }
      } else {
        _selectedTags.remove(tag);
      }

      if (_useBackendFiltering) {
        _loadPosts(isRefresh: true);
      } else {
        _selectedTagFilter = _selectedTags.isEmpty ? 'All' : _selectedTags.first;
        _applyFiltersAndSort();
      }
    });
  }

  void _clearTagSelection() {
    setState(() {
      _selectedTags.clear();
      _selectedTagFilter = 'All';

      if (_useBackendFiltering) {
        _loadPosts(isRefresh: true);
      } else {
        _applyFiltersAndSort();
      }
    });
  }

  // Post Actions
  Future<void> _upvotePost(int? postId) async {
    if (postId == null) return;

    final result = await _feedScreenUtils.upvotePost(
      posts: _posts,
      filteredPosts: _filteredPosts,
      postId: postId,
      onErrorReload: () => _loadPosts(isRefresh: true),
    );

    setState(() {
      _posts = result['posts'] as List<Post>;
      _filteredPosts = result['filteredPosts'] as List<Post>;
      if (_sortBy == 'Popular') _applyFiltersAndSort();
    });
  }

  Future<void> _addCommentBackendFirst(
    int? postId,
    String commentContent,
  ) async {
    if (postId == null || commentContent.trim().isEmpty) return;

    try {
      // Call backend first
      final backendComment = await ApiService.instance.createComment(
        postId,
        commentContent.trim(),
      );

      // Convert backend response to local Comment object
      final localComment = Comment(
        id: backendComment.id,
        content: backendComment.content,
        authorName: backendComment.authorName,
        postId: backendComment.postId.toInt(),
        createdAt: _parseDateTime(backendComment.createdAt),
        numUpvote: backendComment.numUpvote.toInt(),
        upvoted: backendComment.upvoted,
      );

      // Update local state
      final result = _feedScreenUtils.addBackendComment(
        posts: _posts,
        filteredPosts: _filteredPosts,
        comment: localComment,
      );

      setState(() {
        _posts = result['posts'] as List<Post>;
        _filteredPosts = result['filteredPosts'] as List<Post>;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to add comment: ${e.toString()}', Colors.red);
    }
  }

  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is DateTime) {
      return dateTime;
    } else if (dateTime is String) {
      return DateTime.parse(dateTime);
    } else {
      return DateTime.now(); // Fallback to current time
    }
  }

  Future<void> _addPost(String content, List<String> tagNames) async {
    if (content.trim().isEmpty) return;

    try {
      final result = await _feedScreenUtils.addPost(
        content: content,
        tagNames: tagNames,
        existingPosts: _posts,
        availableFilterTags: _availableFilterTags,
      );

      setState(() {
        _posts = result['posts'];
        _availableFilterTags = result['availableFilterTags'];
        _applyFiltersAndSort();
      });
    } catch (e) {
      _showErrorSnackBar("Error in adding post: $e", Colors.redAccent);
    }
  }

  void _showErrorSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getActiveFilterSummary() {
    return _feedScreenUtils.getActiveFilterSummary(
      selectedTagFilter: _selectedTagFilter,
      sortBy: _sortBy,
      searchQuery: _searchController.text,
    );
  }

  // Dialog Methods
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
                    _buildAddPostHeader(),
                    const SizedBox(height: 20),
                    _buildContentTextField(contentController),
                    const SizedBox(height: 16),
                    _buildTagSelection(selectedTagsInDialog, setModalState),
                    const SizedBox(height: 12),
                    _buildCustomTagField(customTagController),
                    const SizedBox(height: 24),
                    _buildPostActions(
                      contentController,
                      customTagController,
                      selectedTagsInDialog,
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
                    _addCommentBackendFirst(postId, commentController.text);
                    Navigator.pop(context);
                  } else {
                    _showErrorSnackBar(
                      'Comment cannot be empty.',
                      Colors.orangeAccent,
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

  // Widget Building Methods
  Widget _buildAddPostHeader() {
    return Text(
      'Create New Post',
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildContentTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'What\'s on your mind?',
        hintText: 'Share an update or ask a question...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(150),
      ),
      maxLines: 5,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildTagSelection(
    Set<String> selectedTags,
    StateSetter setModalState,
  ) {
    final defaultTags = _feedScreenUtils.getDefaultTags();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Tags:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children:
              defaultTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setModalState(() {
                      if (selected) {
                        selectedTags.add(tag);
                      } else {
                        selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomTagField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Custom Tags',
        hintText: 'e.g., Event, Suggestion (comma-separated)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withAlpha(150),
      ),
    );
  }

  Widget _buildPostActions(
    TextEditingController contentController,
    TextEditingController customTagController,
    Set<String> selectedTags,
  ) {
    return Row(
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (contentController.text.isNotEmpty) {
              final customTags =
                  customTagController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();
              final allTags = {...selectedTags, ...customTags}.toList();
              _addPost(contentController.text, allTags);
              Navigator.pop(context);
            } else {
              _showErrorSnackBar(
                'Post content cannot be empty.',
                Colors.redAccent,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search posts, authors, or tags...',
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(153),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        suffixIcon:
            _searchController.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                : null,
      ),
    );
  }

  Widget _buildFilterControls() {
    final theme = Theme.of(context);
    final hasActiveFilters = _useBackendFiltering
        ? _selectedTags.isNotEmpty ||
          _sortBy != 'Recent' ||
          _sortBy != 'Default' ||
          _searchController.text.isNotEmpty
        : _selectedTagFilter != 'All' ||
          _sortBy != 'Recent' ||
          _sortBy != 'Default' ||
          _searchController.text.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterToggle(theme, hasActiveFilters),
        _buildSortDropdown(theme),
      ],
    );
  }

  Widget _buildFilterToggle(ThemeData theme, bool hasActiveFilters) {
    return InkWell(
      onTap: () {
        setState(() {
          _showAdvancedFilters = !_showAdvancedFilters;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showAdvancedFilters ? Icons.tune_rounded : Icons.tune_outlined,
              color:
                  hasActiveFilters
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _showAdvancedFilters ? 'Hide Filters' : 'Show Filters',
              style: theme.textTheme.labelLarge?.copyWith(
                color:
                    hasActiveFilters
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasActiveFilters && !_showAdvancedFilters) ...[
              const SizedBox(width: 4),
              Icon(Icons.circle, color: theme.colorScheme.primary, size: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(ThemeData theme) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(127),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: DropdownButton<String>(
          value: _sortBy,
          icon: Icon(Icons.sort, color: theme.colorScheme.primary, size: 20),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          dropdownColor: theme.cardColor,
          items:
              <String>['Recent', 'Popular', 'Default']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
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
    );
  }

  Widget _buildAdvancedFilters(ThemeData theme, bool hasActiveFilters) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Visibility(
        visible: _showAdvancedFilters,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTagFilterChips(theme),
              if (hasActiveFilters && !_showAdvancedFilters)
                _buildFilterSummary(theme),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTagFilterChips(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Backend filtering toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _useBackendFiltering ? 'Backend Tag Search' : 'Filter by Tag:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Switch.adaptive(
                  value: _useBackendFiltering,
                  onChanged: (value) => _toggleBackendFiltering(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  'API',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tag chips
        SizedBox(
          height: _useBackendFiltering ? 76 : 38,
          child: _useBackendFiltering 
              ? _buildMultiSelectTagChips(theme)
              : _buildSingleSelectTagChips(theme),
        ),
      ],
    );
  }

  Widget _buildSingleSelectTagChips(ThemeData theme) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: _availableFilterTags.map((tag) {
        final isSelected = _selectedTagFilter == tag;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(tag, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (bool sel) => setState(() {
              _selectedTagFilter = sel ? tag : 'All';
              _applyFiltersAndSort();
            }),
            selectedColor: theme.colorScheme.primaryContainer,
            checkmarkColor: theme.colorScheme.onPrimaryContainer,
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.textTheme.bodySmall?.color,
            ),
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(178)
                    : Colors.grey.shade400,
                width: 0.8,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectTagChips(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _availableFilterTags.where((tag) => tag != 'All').map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (bool sel) => _onTagSelectionChanged(tag, sel),
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.textTheme.bodySmall?.color,
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary.withAlpha(178)
                          : Colors.grey.shade400,
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  'Selected: ${_selectedTags.join(", ")}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearTagSelection,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFilterSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        _getActiveFilterSummary(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPostsList() {
    final theme = Theme.of(context);

    if (_isLoading && _posts.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_loadError != null && _posts.isEmpty) {
      return _buildErrorState(theme);
    }

    if (_filteredPosts.isEmpty && !_isLoading) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      itemCount: _filteredPosts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredPosts.length && _isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (index >= _filteredPosts.length) {
          return const SizedBox.shrink();
        }

        final post = _filteredPosts[index];
        return PostCard(
          post: post,
          onUpvote: () => _upvotePost(post.id),
          onComment: () => _showAddCommentDialog(post.id),
          onShare: () => _showShareSnackBar(post),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Failed to Load Posts',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _loadError ??
                            'An unknown error occurred. Pull down to try again.',
                        style: theme.textTheme.bodyLarge?.copyWith(
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
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasFilters =
        _searchController.text.isNotEmpty || _selectedTagFilter != 'All';

    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_drama_outlined,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        hasFilters
                            ? 'No Posts Match Your Criteria'
                            : 'No Posts Yet!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hasFilters
                            ? 'Try adjusting your search or filters.'
                            : 'Be the first to share something interesting!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (!hasFilters)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add a Post'),
                          onPressed: _showAddPostDialog,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
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
    );
  }

  void _showShareSnackBar(Post post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing post: "${post.content.substring(0, post.content.length > 20 ? 20 : post.content.length)}..." (mock)',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _useBackendFiltering
        ? _selectedTags.isNotEmpty ||
          _sortBy != 'Recent' ||
          _sortBy != 'Default' ||
          _searchController.text.isNotEmpty
        : _selectedTagFilter != 'All' ||
          _sortBy != 'Recent' ||
          _sortBy != 'Default' ||
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
                    _buildSearchBar(),
                    const SizedBox(height: 8),
                    _buildFilterControls(),
                    _buildAdvancedFilters(theme, hasActiveFilters),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _loadPosts(isRefresh: true),
                color: theme.colorScheme.primary,
                child: _buildPostsList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPostDialog,
        tooltip: 'Add New Post',
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Post'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
