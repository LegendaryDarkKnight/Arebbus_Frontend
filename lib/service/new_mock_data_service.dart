// lib/services/mock_data_service.dart
import 'package:arebbus/models/addon_category.dart';
import 'package:arebbus/models/comment.dart';
import 'package:arebbus/models/post.dart';
import 'package:arebbus/models/tag.dart';
import 'package:arebbus/models/user.dart';
import 'package:arebbus/models/addon.dart';

class NewMockDataService {
  static final String placeHolder = 'https://picsum.photos/200';
  static final User currentUser = User(
    id: 1,
    name: 'Imtiaz',
    email: 'imtiaz@buet.ac.bd',
    image: placeHolder, // Teal background, white text
    reputation: 150,
    valid: true,
  );


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
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
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
        author: User(name: "Jaden Smith",email: "jadensmith@gmail.com", reputation: 100, image: placeHolder, valid: true),
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
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
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
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
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
        category:AddonCategory.stop,
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
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
        author: User(name: "Jane Smith",email: "janesmith@gmail.com", reputation: 10, image: placeHolder, valid: true),
        installs: 400,
        rating: 3.9,
        isInstalled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
static List<Post> getMockPosts() {
    // Mock users with realistic data
    final users = [
      User(
        id: 1,
        name: 'Alice Smith',
        email: 'alice.smith@example.com',
        image: placeHolder,
        reputation: 120,
        valid: true,
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime(2024, 10, 15),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      User(
        id: 2,
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com',
        image: placeHolder,
        reputation: 85,
        valid: true,
        latitude: 40.7300,
        longitude: -73.9900,
        createdAt: DateTime(2024, 9, 20),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      User(
        id: 3,
        name: 'Charlie Brown',
        email: 'charlie.brown@example.com',
        image: placeHolder,
        reputation: 50,
        valid: true,
        latitude: 40.7500,
        longitude: -73.9800,
        createdAt: DateTime(2025, 1, 10), // This is in the past from current date (May 2025)
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      User(
        id: 4,
        name: 'Diana Lee',
        email: 'diana.lee@example.com',
        image: placeHolder,
        reputation: 200,
        valid: true,
        latitude: 40.7200,
        longitude: -74.0100,
        createdAt: DateTime(2024, 8, 5),
        updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];

    // Mock tags
    final tags = [
      Tag(id: 1, name: 'Congestion'),     // index 0
      Tag(id: 2, name: 'Bus Delay'),      // index 1
      Tag(id: 3, name: 'New Bus Info'),   // index 2
      Tag(id: 4, name: 'Route Update'),   // index 3
      Tag(id: 5, name: 'Accident'),       // index 4
      Tag(id: 6, name: 'Service Alert'),  // index 5
    ];

    // Base time for posts to make comment timestamps relative and logical
    final post1Time = DateTime.now().subtract(const Duration(hours: 3));
    final post2Time = DateTime.now().subtract(const Duration(days: 2));
    final post3Time = DateTime.now().subtract(const Duration(minutes: 45));
    final post5Time = DateTime.now().subtract(const Duration(minutes: 20));


    // Mock comments with timestamps
    final comments = [
      Comment(
        id: 1,
        content: 'Thanks for the heads-up! Taking the subway instead.',
        authorId: 2,
        postId: 1,
        numUpvote: 5,
        author: users[1],
        timestamp: post1Time.add(const Duration(minutes: 5)), // After post
      ),
      Comment(
        id: 2,
        content: 'Is this still ongoing? Need to plan my commute.',
        authorId: 3,
        postId: 1,
        numUpvote: 2,
        author: users[2],
        timestamp: post1Time.add(const Duration(minutes: 15)), // After post & first comment
      ),
      Comment(
        id: 3,
        content: 'Awesome! The new route looks much faster.',
        authorId: 1,
        postId: 2,
        numUpvote: 4,
        author: users[0],
        timestamp: post2Time.add(const Duration(hours: 1)), // After post
      ),
      Comment(
        id: 4,
        content: 'Any updates on the delay duration?',
        authorId: 4,
        postId: 3,
        numUpvote: 1,
        author: users[3],
        timestamp: post3Time.add(const Duration(minutes: 10)), // After post
      ),
      Comment(
        id: 5,
        content: 'This explains the delay I saw this morning!',
        authorId: 2,
        postId: 5,
        numUpvote: 3,
        author: users[1],
        timestamp: post5Time.add(const Duration(minutes: 5)), // After post
      ),
    ];

    // Mock posts with varied and realistic data
    return [
      Post(
        id: 1,
        authorId: 1,
        content: 'Major congestion on Main Street due to road construction near City Hall. Buses rerouted via Elm St. Plan for extra 20-30 min travel time.',
        numUpvote: 18,
        timestamp: post1Time,
        author: users[0],
        // Corrected tags based on descriptive comments: Congestion, Bus Delay, Accident
        tags: [tags[0], tags[1], tags[4]], 
        comments: [comments[0], comments[1]],
      ),
      Post(
        id: 2,
        authorId: 2,
        content: 'New express bus route #47 launching Monday! Connects Downtown to Northside in under 25 minutes. Check transit app for schedule.',
        numUpvote: 30,
        timestamp: post2Time,
        author: users[1],
        tags: [tags[2], tags[3]], // New Bus Info, Route Update (Matches comment)
        comments: [comments[2]],
      ),
      Post(
        id: 3,
        authorId: 3,
        content: 'Bus #12 delayed by 45 minutes due to emergency roadwork on Oak Avenue. Alternate routes advised.',
        numUpvote: 10,
        timestamp: post3Time,
        author: users[2],
        // Corrected tags based on descriptive comments: Bus Delay, Accident
        tags: [tags[1], tags[4]], 
        comments: [comments[3]],
      ),
      Post(
        id: 4,
        authorId: 4,
        content: 'Route #9 now has extended evening service until 11 PM starting next week. Great for late commuters!',
        numUpvote: 22,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        author: users[3],
        tags: [tags[3], tags[2]], // Route Update, New Bus Info (Matches comment)
        comments: [],
      ),
      Post(
        id: 5,
        authorId: 1,
        content: 'Accident at 5th and Pine causing delays for routes #3, #15, and #22. Police on scene, expect 30 min delays.',
        numUpvote: 12,
        timestamp: post5Time,
        author: users[0],
        // Corrected tags based on descriptive comments: Congestion, Bus Delay, Accident
        tags: [tags[0], tags[1], tags[4]],
        comments: [comments[4]],
      ),
      Post(
        id: 6,
        authorId: 2,
        content: 'Service alert: All buses on Route #30 will skip Jefferson Stop due to street festival this weekend. Temporary stop added at Maple St.',
        numUpvote: 15,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        author: users[1],
        tags: [tags[3], tags[5]], // Route Update, Service Alert (Matches comment)
        comments: [],
      ),
      Post(
        id: 7,
        authorId: 3,
        content: 'Lost my wallet on Bus #18 this morning. If found, please contact transit authority. Reward offered!',
        numUpvote: 8,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        author: users[2],
        tags: [tags[5]], // Service Alert (Matches comment, though could be 'Lost & Found' if that tag existed)
        comments: [],
      ),
      Post(
        id: 8,
        authorId: 4,
        content: 'New real-time bus tracking feature added to the transit app. Now you can see exact bus locations!',
        numUpvote: 35,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        author: users[3],
        tags: [tags[2], tags[3]], // New Bus Info, Route Update (Matches comment)
        comments: [],
      ),
    ];
  }
  
}
