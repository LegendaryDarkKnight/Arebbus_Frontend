import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/foundation.dart';

class FeedScreenUtils {
  
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

  List<Post> _parsePosts(dynamic rawPosts) {
    if (rawPosts is! List) {
      debugPrint("Expected List but got: ${rawPosts.runtimeType}");
      return [];
    }
    
    try {
      return rawPosts.map<Post>((postData) {
        // if (postData is! Map<String, dynamic>) {
        //   debugPrint("Invalid post data format: $postData");
        //   return [];
        // }
        
        return Post(
          id: postData['postId']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
          content: postData['content']?.toString() ?? '',
          numUpvote: postData['numUpvote']?.toInt() ?? 0,
          timestamp: _parseDateTime(postData['createdAt']),
          tags: _parseTags(postData['tags']),
          comments: _parseComments(postData['comments']),
          author: User(
            name: postData['authorName']?.toString() ?? 'Anonymous',
            image: 'https://picsum.photos/seed/picsum/200/300',
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error parsing posts: $e");
      return [];
    }
  }

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

  List<Comment> _parseComments(dynamic comments) {
    if (comments is! List) return [];
    
    try {
      return comments
          .map<Comment?>((commentData) {
            if (commentData is! Map<String, dynamic>) return null;
            
            return Comment(
              id: commentData['id']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
              content: commentData['content']?.toString() ?? '',
              postId: commentData['postId']?.toInt() ?? 0,
              numUpvote: commentData['numUpvote']?.toInt() ?? 0,
              timestamp: _parseDateTime(commentData['createdAt']),
              author: User(
                name: commentData['authorName']?.toString() ?? 'Anonymous',
                image: 'https://picsum.photos/seed/picsum/200/300',
              ),
              authorId: commentData['authorId']?.toInt() ?? 1,
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
  }) async {
    try {
      // For refresh, always start from page 0
      final requestPage = isRefresh ? 0 : currentPage;
      
      debugPrint("Loading posts - Page: $requestPage, PageSize: $pageSize, IsRefresh: $isRefresh");
      
      final data = await ApiService.instance.fetchPosts(requestPage, pageSize);
      
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
        final newPosts = fetchedPosts.where((p) => !existingIds.contains(p.id)).toList();
        resultPosts = [...existingPosts, ...newPosts];
      }
      
      debugPrint("Successfully loaded ${fetchedPosts.length} posts. Total posts: ${resultPosts.length}");
      
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
  }) async {
    try {
      // Request the next page
      final nextPage = currentPage + 1;
      
      debugPrint("Loading more posts - NextPage: $nextPage, PageSize: $pageSize");
      
      final data = await ApiService.instance.fetchPosts(nextPage, pageSize);
      
      
      debugPrint("Load more API Response: $data");
      
      final fetchedPosts = _parsePosts(data['posts']);
      final newCurrentPage = data['page']?.toInt() ?? nextPage;
      final totalPages = data['totalPages']?.toInt() ?? currentPage + 1;
      
      // Merge posts, avoiding duplicates
      final existingIds = existingPosts.map((p) => p.id).toSet();
      final newPosts = fetchedPosts.where((p) => !existingIds.contains(p.id)).toList();
      final resultPosts = [...existingPosts, ...newPosts];
      
      debugPrint("Successfully loaded ${newPosts.length} new posts. Total posts: ${resultPosts.length}");
      
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

  List<Post> applyFiltersAndSort({
    required List<Post> posts,
    required String selectedTagFilter,
    required String searchQuery,
    required String sortBy,
  }) {
    List<Post> filteredPosts = List.from(posts);

    // Apply tag filter
    if (selectedTagFilter != 'All') {
      filteredPosts = filteredPosts.where((post) {
        return post.tags?.any((tag) => tag.name == selectedTagFilter) ?? false;
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filteredPosts = filteredPosts.where((post) {
        return post.content.toLowerCase().contains(query) ||
            (post.author?.name.toLowerCase().contains(query) ?? false) ||
            (post.tags?.any((tag) => tag.name.toLowerCase().contains(query)) ?? false);
      }).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'Recent':
        filteredPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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

  Map<String, List<Post>> upvotePost({
    required List<Post> posts,
    required List<Post> filteredPosts,
    required int? postId,
  }) {
    if (postId == null) {
      return {'posts': posts, 'filteredPosts': filteredPosts};
    }

    final updatedPosts = posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(numUpvote: post.numUpvote + 1);
      }
      return post;
    }).toList();

    final updatedFilteredPosts = filteredPosts.map((post) {
      if (post.id == postId) {
        return post.copyWith(numUpvote: post.numUpvote + 1);
      }
      return post;
    }).toList();

    return {
      'posts': updatedPosts, 
      'filteredPosts': updatedFilteredPosts
    };
  }

  Map<String, List<Post>> addComment({
    required List<Post> posts,
    required List<Post> filteredPosts,
    required int? postId,
    required String commentContent,
  }) {
    if (postId == null || commentContent.trim().isEmpty) {
      return {'posts': posts, 'filteredPosts': filteredPosts};
    }

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      content: commentContent.trim(),
      authorId: 1, // Mock user ID
      postId: postId,
      numUpvote: 0,
      timestamp: DateTime.now(),
      author: User(
        name: 'Anonymous', // Mock author name
        image: 'https://picsum.photos/seed/picsum/200/300',
      ),
    );

    final updatedPosts = posts.map((post) {
      if (post.id == postId) {
        final updatedComments = [...?post.comments, newComment];
        return post.copyWith(comments: updatedComments);
      }
      return post;
    }).toList();

    final updatedFilteredPosts = filteredPosts.map((post) {
      if (post.id == postId) {
        final updatedComments = [...?post.comments, newComment];
        return post.copyWith(comments: updatedComments);
      }
      return post;
    }).toList();

    return {
      'posts': updatedPosts, 
      'filteredPosts': updatedFilteredPosts
    };
  }

  Future<Map<String, dynamic>> addPost({
    required String content,
    required List<String> tagNames,
    required List<Post> existingPosts,
    required List<String> availableFilterTags,
  }) async {
    try {
      final trimmedContent = content.trim();
      final cleanTagNames = tagNames.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      
      if (trimmedContent.isEmpty) {
        throw Exception('Post content cannot be empty');
      }
      
      debugPrint("Creating post with content: $trimmedContent, tags: $cleanTagNames");
      
      final data = await ApiService.instance.createPost(trimmedContent, cleanTagNames);
      
      final newPost = Post(
        id: data['postId']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        content: trimmedContent,
        numUpvote: 0,
        timestamp: DateTime.now(),
        tags: cleanTagNames.map((name) => Tag(id: null, name: name)).toList(),
        comments: [],
        author: User(
          name: data['authorName']?.toString() ?? 'Anonymous',
          image: 'https://picsum.photos/seed/picsum/200/300',
        ),
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
}