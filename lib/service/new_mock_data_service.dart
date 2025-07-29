// lib/services/mock_data_service.dart
import 'package:arebbus/models/addon_category.dart';
import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/models/addon.dart';

/// Mock data service for providing test data during development and testing.
/// 
/// This service generates realistic mock data for various entities in the
/// Arebbus application, including users, posts, comments, addons, and tags.
/// It's primarily used for:
/// 
/// - Development and testing without requiring backend connectivity
/// - UI prototyping and design validation
/// - Feature demonstration and user testing
/// - Offline functionality testing
/// - Performance testing with consistent data sets
/// 
/// The service provides static methods that return pre-configured mock objects
/// with realistic data, relationships, and metadata that simulate real-world
/// usage scenarios in the transportation social network.
class NewMockDataService {
  /// Placeholder image URL for mock data objects
  static final String placeHolder = 'https://picsum.photos/200';

  /// Mock current user object for testing authentication and user features
  static final User currentUser = User(
    name: 'Imtiaz',
    email: 'imtiaz@buet.ac.bd',
    image: placeHolder,
    reputation: 150,
    valid: true,
  );

  /// Generates a list of mock addon objects for testing addon functionality.
  /// 
  /// This method creates a diverse set of addon objects representing different
  /// categories (stops, routes, buses) with varying popularity, ratings, and
  /// installation status. The mock data includes realistic metadata such as
  /// creation dates, update times, and user engagement metrics.
  /// 
  /// Returns: A list of mock Addon objects with complete test data
  static List<Addon> getMockAddons() {
    return [
      Addon(
        id: 'addon_1',
        name: 'City Center Stop',
        description: 'Main bus stop in downtown area',
        category: AddonCategory.stop,
        author: currentUser,
        installs: 1500,
        rating: 4.5,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Addon(
        id: 'addon_2',
        name: 'Suburban Route',
        description: 'Route connecting city to suburbs',
        category: AddonCategory.route,
        author: currentUser,
        installs: 800,
        rating: 4.2,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Addon(
        id: 'addon_3',
        name: 'Express Bus Service',
        description: 'Fast bus service for Route A',
        category: AddonCategory.route,
        author: User(
          name: "Jane Smith",
          email: "janesmith@gmail.com",
          reputation: 10,
          image: placeHolder,
          valid: true,
        ),
        installs: 2000,
        rating: 4.8,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Addon(
        id: 'addon_4',
        name: 'Real-time Navigation',
        description: 'Live navigation for bus routes',
        category: AddonCategory.stop,
        author: User(
          name: "Jaden Smith",
          email: "jadensmith@gmail.com",
          reputation: 100,
          image: placeHolder,
          valid: true,
        ),
        installs: 1200,
        rating: 4.0,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Addon(
        id: 'addon_5',
        name: 'Community Chat',
        description: 'Chat with other commuters',
        category: AddonCategory.bus,
        author: User(
          name: "Jane Smith",
          email: "janesmith@gmail.com",
          reputation: 10,
          image: placeHolder,
          valid: true,
        ),
        installs: 500,
        rating: 3.8,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Addon(
        id: 'addon_6',
        name: 'Traffic Alerts',
        description: 'Real-time traffic and delay alerts',
        category: AddonCategory.stop,
        author: User(
          name: "Jane Smith",
          email: "janesmith@gmail.com",
          reputation: 10,
          image: placeHolder,
          valid: true,
        ),
        installs: 3000,
        rating: 4.7,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Addon(
        id: 'addon_7',
        name: 'Northside Stop',
        description: 'Bus stop in north residential area',
        category: AddonCategory.stop,
        author: User(
          name: "Jane Smith",
          email: "janesmith@gmail.com",
          reputation: 10,
          image: placeHolder,
          valid: true,
        ),
        installs: 600,
        rating: 4.1,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Addon(
        id: 'addon_8',
        name: 'Night Route',
        description: 'Late-night bus route',
        category: AddonCategory.route,
        author: User(
          name: "Jane Smith",
          email: "janesmith@gmail.com",
          reputation: 10,
          image: placeHolder,
          valid: true,
        ),
        installs: 400,
        rating: 3.9,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Generates a list of mock post objects for testing social feed functionality.
  /// 
  /// This method creates realistic social media posts that would appear in the
  /// transportation community feed. The posts include various content types such as:
  /// - Traffic and congestion reports
  /// - Bus delay notifications and updates
  /// - New bus information and route changes
  /// - Accident reports and service alerts
  /// - Community discussions and questions
  /// 
  /// Each post includes complete metadata including tags, timestamps, user
  /// engagement metrics (upvotes), and associated comments to simulate
  /// real social interaction patterns.
  /// 
  /// Returns: A list of mock Post objects with realistic transportation-related content
  static List<Post> getMockPosts() {
    final tags = [
      Tag(id: 1, name: 'Congestion'),
      Tag(id: 2, name: 'Bus Delay'),
      Tag(id: 3, name: 'New Bus Info'),
      Tag(id: 4, name: 'Route Update'),
      Tag(id: 5, name: 'Accident'),
      Tag(id: 6, name: 'Service Alert'),
    ];

    final post1Time = DateTime.now().subtract(const Duration(hours: 3));
    final post2Time = DateTime.now().subtract(const Duration(days: 2));
    final post3Time = DateTime.now().subtract(const Duration(minutes: 45));
    final post5Time = DateTime.now().subtract(const Duration(minutes: 20));

    final comments = [
      Comment(
        id: 1,
        content: 'Thanks for the heads-up! Taking the subway instead.',
        authorName: 'John Doe',
        postId: 1,
        numUpvote: 5,
        createdAt: post1Time.add(const Duration(minutes: 5)),
        upvoted: true,
      ),
      Comment(
        id: 2,
        content: 'Is this still ongoing? Need to plan my commute.',
        authorName: 'Emily White',
        postId: 1,
        numUpvote: 2,
        createdAt: post1Time.add(const Duration(minutes: 15)),
        upvoted: false,
      ),
      Comment(
        id: 3,
        content: 'Awesome! The new route looks much faster.',
        authorName: 'Alice Smith',
        postId: 2,
        numUpvote: 4,
        createdAt: post2Time.add(const Duration(hours: 1)),
        upvoted: true,
      ),
      Comment(
        id: 4,
        content: 'Any updates on the delay duration?',
        authorName: 'Daniel Kim',
        postId: 3,
        numUpvote: 1,
        createdAt: post3Time.add(const Duration(minutes: 10)),
        upvoted: false,
      ),
      Comment(
        id: 5,
        content: 'This explains the delay I saw this morning!',
        authorName: 'John Doe',
        postId: 5,
        numUpvote: 3,
        createdAt: post5Time.add(const Duration(minutes: 5)),
        upvoted: true,
      ),
    ];

    return [
      Post(
        id: 1,
        authorName: 'Alice Smith',
        content:
            'Major congestion on Main Street due to road construction near City Hall. Buses rerouted via Elm St. Plan for extra 20-30 min travel time.',
        numUpvote: 18,
        createdAt: post1Time,
        tags: [tags[0], tags[1], tags[4]],
        comments: [comments[0], comments[1]],
        upvoted: false,
      ),
      Post(
        id: 2,
        authorName: 'Bob Johnson',
        content:
            'New express bus route #47 launching Monday! Connects Downtown to Northside in under 25 minutes. Check transit app for schedule.',
        numUpvote: 30,
        createdAt: post2Time,
        tags: [tags[2], tags[3]],
        comments: [comments[2]],
        upvoted: true,
      ),
      Post(
        id: 3,
        authorName: 'Charlie Brown',
        content:
            'Bus #12 delayed by 45 minutes due to emergency roadwork on Oak Avenue. Alternate routes advised.',
        numUpvote: 10,
        createdAt: post3Time,
        tags: [tags[1], tags[4]],
        comments: [comments[3]],
        upvoted: false,
      ),
      Post(
        id: 4,
        authorName: 'Diana Lee',
        content:
            'Route #9 now has extended evening service until 11 PM starting next week. Great for late commuters!',
        numUpvote: 22,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        tags: [tags[3], tags[2]],
        comments: [],
        upvoted: true,
      ),
      Post(
        id: 5,
        authorName: 'Alice Smith',
        content:
            'Accident at 5th and Pine causing delays for routes #3, #15, and #22. Police on scene, expect 30 min delays.',
        numUpvote: 12,
        createdAt: post5Time,
        tags: [tags[0], tags[1], tags[4]],
        comments: [comments[4]],
        upvoted: false,
      ),
      Post(
        id: 6,
        authorName: 'Bob Johnson',
        content:
            'Service alert: All buses on Route #30 will skip Jefferson Stop due to street festival this weekend. Temporary stop added at Maple St.',
        numUpvote: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        tags: [tags[3], tags[5]],
        comments: [],
        upvoted: true,
      ),
      Post(
        id: 7,
        authorName: 'Charlie Brown',
        content:
            'Lost my wallet on Bus #18 this morning. If found, please contact transit authority. Reward offered!',
        numUpvote: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        tags: [tags[5]],
        comments: [],
        upvoted: false,
      ),
      Post(
        id: 8,
        authorName: 'Diana Lee',
        content:
            'New real-time bus tracking feature added to the transit app. Now you can see exact bus locations!',
        numUpvote: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: [tags[2], tags[3]],
        comments: [],
        upvoted: true,
      ),
    ];
  }
}
