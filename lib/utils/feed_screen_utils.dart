import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/foundation.dart';

/// Utility class for managing feed screen operations and data processing.
/// 
/// FeedScreenUtils provides comprehensive functionality for the social feed
/// feature of the Arebbus app, including:
/// 
/// - Post loading with pagination and filtering
/// - Tag management and filtering
/// - Data parsing and validation
/// - Upvote/downvote functionality
/// - Comment management
/// - Search and sorting capabilities
/// - Error handling and data transformation
/// 
/// This class handles the complex business logic for feed operations,
/// separating concerns from the UI layer and providing a clean interface
/// for feed-related data operations.
class FeedScreenUtils {
  /// Returns a list of default tag categories for post classification.
  /// 
  /// These tags represent common topics and issues related to bus transportation
  /// that users can associate with their posts. The tags help categorize and
  /// filter content in the social feed.
  /// 
  /// @return List of predefined tag strings covering transportation-related topics
  List<String> getDefaultTags() {
    return const [
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
  }

  /// Parses raw post data from API response into Post objects.
  /// 
  /// This method safely transforms API response data into typed Post objects,
  /// handling potential null values and data type mismatches. It includes
  /// comprehensive error handling to ensure app stability.
  /// 
  /// @param rawPosts Raw data from API response (expected to be List)
  /// @return List of parsed Post objects, empty list if parsing fails
  List<Post> _parsePosts(dynamic rawPosts) {
    if (rawPosts is! List) {
      debugPrint("Expected List but got: ${rawPosts.runtimeType}");
      return [];
    }

    try {
      return rawPosts.map<Post>((postData) {
        return Post(
          id: postData['postId']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
          authorName: postData['authorName']?.toString() ?? 'Anonymous',
          authorImage: 'https://picsum.photos/seed/picsum/200/300',
          content: postData['content']?.toString() ?? '',
          numUpvote: postData['numUpvote']?.toInt() ?? 0,
          createdAt: _parseDateTime(postData['createdAt']),
          tags: _parseTags(postData['tags']),
          comments: _parseComments(postData['comments']),
          upvoted: postData['upvoted'],
        );
      }).toList();
    } catch (e) {
      debugPrint("Error parsing posts: $e");
      return [];
    }
  }

  /// Safely parses datetime from various input formats.
  /// 
  /// Handles string and other datetime representations from API responses,
  /// providing fallback to current time if parsing fails.
  /// 
  /// @param dateTime Raw datetime value from API
  /// @return Parsed DateTime object or current time as fallback
  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();

    try {
      if (dateTime is String) {
        return DateTime.parse(dateTime);
      }
      return DateTime.now();
    } catch (e) {
      debugPrint("Error parsing datetime: $e");
      return DateTime.now();
    }
  }

  /// Parses tag data from API response into Tag objects.
  /// 
  /// Safely processes tag data, filtering out null or empty values
  /// and creating proper Tag objects for post classification.
  /// 
  /// @param tags Raw tag data from API response
  /// @return List of parsed Tag objects
  List<Tag> _parseTags(dynamic tags) {
    if (tags is! List) return [];

    try {
      return tags
          .map<Tag?>((tagData) {
            if (tagData == null) return null;
            String tagName = tagData.toString().trim();
            return tagName.isNotEmpty ? Tag(id: null, name: tagName) : null;
          })
          .where((tag) => tag != null)
          .cast<Tag>()
          .toList();
    } catch (e) {
      debugPrint("Error parsing tags: $e");
      return [];
    }
  }

  /// Parses comment data from API response into Comment objects.
  /// 
  /// Safely processes comment data associated with posts, handling
  /// nested data structures and potential null values.
  /// 
  /// @param comments Raw comment data from API response
  /// @return List of parsed Comment objects
  List<Comment> _parseComments(dynamic comments) {
    if (comments is! List) return [];

    try {
      return comments
          .map<Comment?>((commentData) {
            if (commentData is! Map<String, dynamic>) return null;

            return Comment(
              id: commentData['id'],
              content: commentData['content'],
              postId: commentData['postId'],
              authorName: commentData['authorName'],
              numUpvote: commentData['numUpvote'],
              createdAt: _parseDateTime(commentData['createdAt']),
              upvoted: commentData['upvoted'],
            );
          })
          .where((comment) => comment != null)
          .cast<Comment>()
          .toList();
    } catch (e) {
      debugPrint("Error parsing comments: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> loadPosts({
    required int currentPage,
    required int pageSize,
    required bool isRefresh,
    required List<Post> existingPosts,
    List<String>? filterTags,
  }) async {
    try {
      // For refresh, always start from page 0
      final requestPage = isRefresh ? 0 : currentPage;

      debugPrint(
        "Loading posts - Page: $requestPage, PageSize: $pageSize, IsRefresh: $isRefresh, FilterTags: $filterTags",
      );

      Map<String, dynamic> data;
      if (filterTags != null && filterTags.isNotEmpty) {
        data = await ApiService.instance.fetchPostsByTags(
          filterTags,
          requestPage,
          pageSize,
        );
      } else {
        data = await ApiService.instance.fetchPosts(requestPage, pageSize);
      }

      // debugPrint("API Response: $data");

      final fetchedPosts = _parsePosts(data['posts']);
      final newCurrentPage = data['page']?.toInt() ?? requestPage;
      final totalPages = data['totalPages']?.toInt() ?? 1;

      // Handle post merging correctly
      List<Post> resultPosts;
      if (isRefresh) {
        resultPosts = fetchedPosts;
      } else {
        // Merge with existing posts, avoiding duplicates
        final existingIds = existingPosts.map((p) => p.id).toSet();
        final newPosts =
            fetchedPosts.where((p) => !existingIds.contains(p.id)).toList();
        resultPosts = [...existingPosts, ...newPosts];
      }

      debugPrint(
        "Successfully loaded ${fetchedPosts.length} posts. Total posts: ${resultPosts.length}",
      );

      return {
        'posts': resultPosts,
        'currentPage': newCurrentPage,
        'totalPages': totalPages,
        'isLoading': false,
        'error': null,
      };
    } catch (e) {
      debugPrint("Error loading posts: $e");

      // Return existing posts with error info
      return {
        'posts': existingPosts,
        'currentPage': currentPage,
        'totalPages': 1,
        'isLoading': false,
        'error': _formatError(e),
      };
    }
  }

  Future<Map<String, dynamic>> loadMorePosts({
    required int currentPage,
    required int pageSize,
    required List<Post> existingPosts,
    List<String>? filterTags,
  }) async {
    try {
      // Request the next page
      final nextPage = currentPage + 1;

      debugPrint(
        "Loading more posts - NextPage: $nextPage, PageSize: $pageSize, FilterTags: $filterTags",
      );

      Map<String, dynamic> data;
      if (filterTags != null && filterTags.isNotEmpty) {
        data = await ApiService.instance.fetchPostsByTags(
          filterTags,
          nextPage,
          pageSize,
        );
      } else {
        data = await ApiService.instance.fetchPosts(nextPage, pageSize);
      }

      debugPrint("Load more API Response: $data");

      final fetchedPosts = _parsePosts(data['posts']);
      final newCurrentPage = data['page']?.toInt() ?? nextPage;
      final totalPages = data['totalPages']?.toInt() ?? currentPage + 1;

      // Merge posts, avoiding duplicates
      final existingIds = existingPosts.map((p) => p.id).toSet();
      final newPosts =
          fetchedPosts.where((p) => !existingIds.contains(p.id)).toList();
      final resultPosts = [...existingPosts, ...newPosts];

      debugPrint(
        "Successfully loaded ${newPosts.length} new posts. Total posts: ${resultPosts.length}",
      );

      return {
        'posts': resultPosts,
        'currentPage': newCurrentPage,
        'totalPages': totalPages,
        'isLoading': false,
        'error': null,
      };
    } catch (e) {
      debugPrint("Error loading more posts: $e");

      // Return existing posts with error info
      return {
        'posts': existingPosts,
        'currentPage': currentPage,
        'totalPages': currentPage + 1,
        'isLoading': false,
        'error': _formatError(e),
      };
    }
  }

  String _formatError(dynamic error) {
    final errorString = error.toString();
    return errorString.length > 100
        ? "${errorString.substring(0, 100)}..."
        : errorString;
  }

  List<String> getAvailableFilterTags(List<Post> posts) {
    final defaultTags = getDefaultTags();
    final allPostTags = <String>{};

    for (var post in posts) {
      post.tags?.forEach((tag) {
        final tagName = tag.name.trim();
        if (tagName.isNotEmpty) {
          allPostTags.add(tagName);
        }
      });
    }

    // Combine all tags and remove duplicates
    final allTags = <String>{
      'All',
      ...defaultTags,
      ...allPostTags.where((tag) => !defaultTags.contains(tag) && tag != 'All'),
    };

    final sortedTags = allTags.toList();
    sortedTags.sort((a, b) {
      if (a == "All") return -1;
      if (b == "All") return 1;
      return a.compareTo(b);
    });

    return sortedTags;
  }

  Future<List<String>> loadAllAvailableTags() async {
    try {
      final backendTags = await ApiService.instance.fetchAllTags();
      final defaultTags = getDefaultTags();
      
      // Combine backend tags with default tags, ensuring "All" is first
      final allTags = <String>{
        'All',
        ...defaultTags,
        ...backendTags.where((tag) => !defaultTags.contains(tag) && tag != 'All'),
      };

      final sortedTags = allTags.toList();
      sortedTags.sort((a, b) {
        if (a == "All") return -1;
        if (b == "All") return 1;
        return a.compareTo(b);
      });

      return sortedTags;
    } catch (e) {
      debugPrint("Error loading tags from backend: $e");
      // Fallback to default tags if backend fails
      return ['All', ...getDefaultTags()];
    }
  }

  List<Post> applyFiltersAndSort({
    required List<Post> posts,
    required String selectedTagFilter,
    required String searchQuery,
    required String sortBy,
  }) {
    List<Post> filteredPosts = List.from(posts);

    // Apply tag filter
    if (selectedTagFilter != 'All') {
      filteredPosts =
          filteredPosts.where((post) {
            return post.tags?.any((tag) => tag.name == selectedTagFilter) ??
                false;
          }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filteredPosts =
          filteredPosts.where((post) {
            return post.content.toLowerCase().contains(query) ||
                (post.tags?.any(
                      (tag) => tag.name.toLowerCase().contains(query),
                    ) ??
                    false);
          }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'Recent':
        filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Popular':
        filteredPosts.sort((a, b) => b.numUpvote.compareTo(a.numUpvote));
        break;
      case 'Default':
      default:
        // Keep original order or sort by timestamp if needed
        break;
    }

    return filteredPosts;
  }

  Future<Map<String, List<Post>>> upvotePost({
    required List<Post> posts,
    required List<Post> filteredPosts,
    required int? postId,
    required VoidCallback onErrorReload, // Call this on failure
  }) async {
    if (postId == null) {
      return {'posts': posts, 'filteredPosts': filteredPosts};
    }

    // Optimistically update the UI first
    late bool newUpvoteStatus;
    late List<Post> updatedPosts;
    late List<Post> updatedFilteredPosts;

    updatedPosts =
        posts.map((post) {
          if (post.id == postId) {
            final isUpvoted = post.upvoted;
            newUpvoteStatus = !isUpvoted;
            return post.copyWith(
              numUpvote: isUpvoted ? post.numUpvote - 1 : post.numUpvote + 1,
              upvoted: newUpvoteStatus,
            );
          }
          return post;
        }).toList();

    updatedFilteredPosts =
        filteredPosts.map((post) {
          if (post.id == postId) {
            final isUpvoted = post.upvoted;
            return post.copyWith(
              numUpvote: isUpvoted ? post.numUpvote - 1 : post.numUpvote + 1,
              upvoted: !isUpvoted,
            );
          }
          return post;
        }).toList();

    // Now make the API call
    try {
      final result = await ApiService.instance.togglePostUpvote(postId);

      // Optional: you can verify server response with optimistic update
      final bool serverUpvoteStatus = result['upvoteStatus'] ?? false;
      if (serverUpvoteStatus != newUpvoteStatus) {
        debugPrint('Mismatch with server state, consider sync handling');
      }
    } catch (e) {
      debugPrint('Error during upvote toggle: $e');
      onErrorReload(); // Trigger reload and show alert in UI
    }

    return {'posts': updatedPosts, 'filteredPosts': updatedFilteredPosts};
  }

  Future<Map<String, dynamic>> addPost({
    required String content,
    required List<String> tagNames,
    required List<Post> existingPosts,
    required List<String> availableFilterTags,
  }) async {
    try {
      final trimmedContent = content.trim();
      final cleanTagNames =
          tagNames
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();

      if (trimmedContent.isEmpty) {
        throw Exception('Post content cannot be empty');
      }

      debugPrint(
        "Creating post with content: $trimmedContent, tags: $cleanTagNames",
      );

      final data = await ApiService.instance.createPost(
        trimmedContent,
        cleanTagNames,
      );

      final newPost = Post(
        id: data['postId']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        authorName: data['authorName']?.toString() ?? 'Anonymous',
        authorImage: 'https://picsum.photos/seed/picsum/200/300',
        content: trimmedContent,
        numUpvote: 0,
        createdAt: DateTime.now(),
        tags: cleanTagNames.map((name) => Tag(id: null, name: name)).toList(),
        comments: [],
        upvoted: false,
      );

      // Update available filter tags
      final updatedTags = Set<String>.from(availableFilterTags);
      bool newTagsAdded = false;

      for (String tagName in cleanTagNames) {
        if (!updatedTags.contains(tagName)) {
          updatedTags.add(tagName);
          newTagsAdded = true;
        }
      }

      List<String> sortedTags = updatedTags.toList();
      if (newTagsAdded) {
        sortedTags.sort((a, b) {
          if (a == "All") return -1;
          if (b == "All") return 1;
          return a.compareTo(b);
        });
      }

      debugPrint("Successfully created post with ID: ${newPost.id}");

      return {
        'posts': [newPost, ...existingPosts],
        'availableFilterTags': sortedTags,
      };
    } catch (e) {
      debugPrint("Error adding post: $e");
      throw Exception('Failed to add post: ${_formatError(e)}');
    }
  }

  String getActiveFilterSummary({
    required String selectedTagFilter,
    required String sortBy,
    required String searchQuery,
  }) {
    List<String> activeFilters = [];

    if (selectedTagFilter != 'All') {
      activeFilters.add('Tag: $selectedTagFilter');
    }
    if (sortBy != 'Recent' && sortBy != 'Default') {
      activeFilters.add('Sorted by: $sortBy');
    }
    if (searchQuery.trim().isNotEmpty) {
      activeFilters.add('Search: "${searchQuery.trim()}"');
    }

    return activeFilters.isEmpty
        ? 'No active filters'
        : activeFilters.join(' • ');
  }

  Map<String, List<Post>> updateCommentWithBackendData({
    required List<Post> posts,
    required List<Post> filteredPosts,
    required int postId,
    required int optimisticCommentId,
    required Comment backendComment,
  }) {
    final updatedPosts =
        posts.map((post) {
          if (post.id == postId) {
            final updatedComments =
                post.comments?.map((comment) {
                  if (comment.id == optimisticCommentId) {
                    return backendComment;
                  }
                  return comment;
                }).toList() ??
                [];
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

    final updatedFilteredPosts =
        filteredPosts.map((post) {
          if (post.id == postId) {
            final updatedComments =
                post.comments?.map((comment) {
                  if (comment.id == optimisticCommentId) {
                    return backendComment;
                  }
                  return comment;
                }).toList() ??
                [];
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

    return {'posts': updatedPosts, 'filteredPosts': updatedFilteredPosts};
  }

  Map<String, List<Post>> addBackendComment({
    required List<Post> posts,
    required List<Post> filteredPosts,
    required Comment comment,
  }) {
    final updatedPosts =
        posts.map((post) {
          if (post.id == comment.postId) {
            final updatedComments = [...?post.comments, comment];
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

    final updatedFilteredPosts =
        filteredPosts.map((post) {
          if (post.id == comment.postId) {
            final updatedComments = [...?post.comments, comment];
            return post.copyWith(comments: updatedComments);
          }
          return post;
        }).toList();

    return {'posts': updatedPosts, 'filteredPosts': updatedFilteredPosts};
  }
}
