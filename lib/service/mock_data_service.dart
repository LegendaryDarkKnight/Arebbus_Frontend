// lib/services/mock_data_service.dart
import 'package:arebbus/models/bus_model.dart';
import 'package:arebbus/models/post_model.dart';
import 'package:arebbus/models/user_model.dart';
import 'package:arebbus/models/addon_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng

class MockDataService {
  static final ArebbuUser currentUser = ArebbuUser(
    id: 'user123',
    name: 'Imtiaz',
    email: 'imtiaz@buet.ac.bd',
    profileImageUrl:
        'https://placehold.co/100x100/00ACC1/FFFFFF?text=I', // Teal background, white text
    reputationPoints: 150,
    subscribedRoutes: ['Rayerbag-Bakshibazar'],
    contributedAddons: ['BUET-Signboard'],
  );

  static List<Bus> getMockBuses() {
    return [
      Bus(
        id: 'bus001',
        name: 'Thikana',
        routeName: 'Rayerbag to Bakshibazar (Flyover)',
        totalSeats: 60,
        availableSeats: 25,
        currentStatus: 'Running on time',
        currentLocation: const LatLng(
          23.7263,
          90.3929,
        ), // Mock: Dhaka University area
        stoppages: [
          'Rayerbag',
          'Janapath',
          'Flyover Entry',
          'Chankharpool',
          'Bakshibazar',
        ],
        fareInfo: {
          'Rayerbag': 0,
          'Janapath': 10,
          'Flyover Entry': 15,
          'Chankharpool': 25,
          'Bakshibazar': 30,
        },
      ),
      Bus(
        id: 'bus002',
        name: 'Moumita',
        routeName: 'Mirpur 10 to Gulistan',
        totalSeats: 50,
        availableSeats: 10,
        currentStatus: 'Slightly Delayed',
        currentLocation: const LatLng(23.7530, 90.3765), // Mock: Farmgate area
        stoppages: [
          'Mirpur 10',
          'Kazipara',
          'Shewrapara',
          'Farmgate',
          'Press Club',
          'Gulistan',
        ],
        fareInfo: {
          'Mirpur 10': 0,
          'Kazipara': 10,
          'Shewrapara': 15,
          'Farmgate': 25,
          'Press Club': 30,
          'Gulistan': 35,
        },
      ),
      Bus(
        id: 'bus003',
        name: 'Nilachol',
        routeName: 'Gazipur to Azimpur',
        totalSeats: 55,
        availableSeats: 40,
        currentStatus: 'Running',
        currentLocation: const LatLng(23.7776, 90.3945), // Mock: Mohakhali area
        stoppages: [
          'Gazipur Chowrasta',
          'Airport',
          'Mohakhali',
          'Farmgate',
          'Science Lab',
          'Azimpur',
        ],
        fareInfo: {
          'Gazipur Chowrasta': 0,
          'Airport': 20,
          'Mohakhali': 35,
          'Farmgate': 45,
          'Science Lab': 55,
          'Azimpur': 60,
        },
      ),
      Bus(
        id: 'bus004',
        name: 'BUET Staff Bus',
        routeName: 'Signboard to BUET Campus',
        totalSeats: 40,
        availableSeats: 15,
        currentStatus: 'Scheduled',
        currentLocation: const LatLng(23.7099, 90.4071), // Mock: Near Signboard
        stoppages: [
          'Signboard',
          'Rayerbag',
          'Gulistan',
          'Chankharpool',
          'BUET Campus',
        ],
        fareInfo: {
          'Signboard': 0,
          'Rayerbag': 5,
          'Gulistan': 15,
          'Chankharpool': 20,
          'BUET Campus': 25,
        },
      ),
    ];
  }

  static List<Post> getMockPosts() {
    return [
      Post(
        id: 'post001',
        userId: 'user002',
        userName: 'Traffic Hero',
        userProfileImageUrl:
            'https://placehold.co/50x50/FF7043/FFFFFF?text=TH', // Deep Orange background
        content:
            'Heavy congestion on the Mayor Hanif Flyover near Janapath turning. Avoid if possible!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        tags: ['congestion', 'flyover', 'janapath'],
        upvotes: 25,
        locationTag: 'Mayor Hanif Flyover',
        alertType: 'Congestion',
      ),
      Post(
        id: 'post002',
        userId: 'user003',
        userName: 'City Commuter',
        userProfileImageUrl:
            'https://placehold.co/50x50/4CAF50/FFFFFF?text=CC', // Green background
        content:
            'Nilachol bus (Gazipur to Azimpur) is running late by about 20 mins due to an issue at Mohakhali.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        tags: ['delay', 'nilachol', 'mohakhali'],
        upvotes: 12,
        locationTag: 'Mohakhali Bus Terminal',
        alertType: 'Bus Delay',
      ),
      Post(
        id: 'post003',
        userId: 'user123', // Current user's post
        userName: currentUser.name,
        userProfileImageUrl: currentUser.profileImageUrl,
        content:
            'Just added the BUET Signboard route bus to the community addons! Check it out and contribute if you use this route.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        tags: ['new bus', 'addon', 'buet', 'signboard route'],
        upvotes: 37,
        alertType: 'New Bus Info',
      ),
      Post(
        id: 'post004',
        userId: 'user004',
        userName: 'Daily Rider',
        userProfileImageUrl:
            'https://placehold.co/50x50/AB47BC/FFFFFF?text=DR', // Purple background
        content:
            'PSA: Alternative route via Gulistan is much clearer this morning if you are heading towards Old Dhaka from Rayerbag.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        tags: ['route suggestion', 'gulistan', 'old dhaka'],
        upvotes: 18,
        locationTag: 'Gulistan',
        alertType: 'Route Update',
      ),
    ];
  }

  static List<Addon> getMockAddons() {
    return [
      Addon(
        id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Thikana Transport Addon',
        description: 'Information about Thikana Transport bus service',
        category: 'Bus Service',
        author: Author(id: 'user001', username: 'imtiaz123', reputation: 120),
        installs: 357,
        rating: 4.7,
        isInstalled: true,
        createdAt: DateTime.parse('2023-01-15T12:00:00Z'),
        updatedAt: DateTime.parse('2023-04-10T08:30:00Z'),
      ),
      Addon(
        id: '660e8400-e29b-41d4-a716-446655440111',
        name: 'Dhaka Route Tracker',
        description:
            'Live updates and mapping for Dhaka city public transport routes.',
        category: 'Navigation',
        author: Author(id: 'user002', username: 'citymapper', reputation: 200),
        installs: 520,
        rating: 4.5,
        isInstalled: false,
        createdAt: DateTime.parse('2023-03-22T09:00:00Z'),
        updatedAt: DateTime.parse('2023-08-15T11:45:00Z'),
      ),
      Addon(
        id: '770e8400-e29b-41d4-a716-446655440222',
        name: 'BUET Signboard Route Addon',
        description:
            'Tracks and updates the BUET-Signboard bus routes used by students.',
        category: 'Community',
        author: Author(id: 'user123', username: 'buetian007', reputation: 95),
        installs: 289,
        rating: 4.9,
        isInstalled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Addon(
        id: '880e8400-e29b-41d4-a716-446655440333',
        name: 'Emergency Stop Alerts',
        description:
            'Get notified if your regular bus has unplanned stops or route changes.',
        category: 'Alerts',
        author: Author(
          id: 'user005',
          username: 'transitwatch',
          reputation: 180,
        ),
        installs: 410,
        rating: 4.6,
        isInstalled: false,
        createdAt: DateTime.parse('2023-06-01T07:30:00Z'),
        updatedAt: DateTime.parse('2023-07-20T13:15:00Z'),
      ),
    ];
  }
}
