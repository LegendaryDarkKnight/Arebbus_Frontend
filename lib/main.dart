import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const ArebbusApp());
}

class ArebbusApp extends StatelessWidget {
  const ArebbusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arebbus Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Mock Data Models
class Bus {
  final String id;
  final String name;
  final String route;
  final int totalSeats;
  int availableSeats;
  double latitude;
  double longitude;
  bool isMoving;

  Bus({
    required this.id,
    required this.name,
    required this.route,
    required this.totalSeats,
    required this.availableSeats,
    required this.latitude,
    required this.longitude,
    this.isMoving = true,
  });
}

// Main Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Bus> _buses = [];
  Timer? _busMovementTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initMockBuses();
    _startBusMovement();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busMovementTimer?.cancel();
    super.dispose();
  }

  void _initMockBuses() {
    // Create some mock buses for Dhaka city
    _buses.add(Bus(
      id: '1',
      name: 'Thikana Paribahan',
      route: 'Rayerbag → Bakshibazar',
      totalSeats: 50,
      availableSeats: 12,
      latitude: 23.7795,
      longitude: 90.4068,
    ));
    
    _buses.add(Bus(
      id: '2',
      name: 'Moumita Transport',
      route: 'Gulistan → BUET',
      totalSeats: 45,
      availableSeats: 5,
      latitude: 23.7730,
      longitude: 90.4200,
    ));
    
    _buses.add(Bus(
      id: '3',
      name: 'Nilachol Paribahan',
      route: 'Mohammadpur → Motijheel',
      totalSeats: 60,
      availableSeats: 22,
      latitude: 23.7650,
      longitude: 90.3900,
    ));
    
    _buses.add(Bus(
      id: '4',
      name: 'BUET Transport',
      route: 'Signboard → BUET',
      totalSeats: 40,
      availableSeats: 18,
      latitude: 23.7625,
      longitude: 90.4150,
    ));
  }
  
  void _startBusMovement() {
    // Simulate buses moving around Dhaka
    _busMovementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        for (var bus in _buses) {
          if (bus.isMoving) {
            // Random movement within Dhaka area
            bus.latitude += (_random.nextDouble() - 0.5) * 0.005;
            bus.longitude += (_random.nextDouble() - 0.5) * 0.005;
            
            // Randomly update available seats
            if (_random.nextBool() && bus.availableSeats > 0) {
              bus.availableSeats -= 1;
            } else if (_random.nextBool() && bus.availableSeats < bus.totalSeats) {
              bus.availableSeats += 1;
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arebbus'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Buses'),
            Tab(icon: Icon(Icons.forum), text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MapViewScreen(buses: _buses),
          BusListScreen(buses: _buses),
          const CommunityScreen(),
        ],
      ),
    );
  }
}

// Map View Screen
class MapViewScreen extends StatelessWidget {
  final List<Bus> buses;
  
  const MapViewScreen({super.key, required this.buses});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Mock Map (we'll use a simple container with a grid pattern)
        Container(
          color: Colors.grey[200],
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemCount: 200,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
              );
            },
          ),
        ),
        
        // Bus markers
        ...buses.map((bus) {
          // Calculate position based on lat/lng
          // This is a simplified version just for demo
          final top = 400 - (bus.latitude - 23.7500) * 10000;
          final left = (bus.longitude - 90.3700) * 10000;
          
          return Positioned(
            top: top,
            left: left,
            child: GestureDetector(
              onTap: () {
                _showBusDetails(context, bus);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }),
        
        // Location legend
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dhaka City',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Tap on a bus to see details'),
              ],
            ),
          ),
        ),
        
        // Search button
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              _showSearchDialog(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Search for buses or routes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBusDetails(BuildContext context, Bus bus) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus,
                    color: Colors.green,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          bus.route,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Total Seats',
                    '${bus.totalSeats}',
                    Icons.event_seat,
                  ),
                  _buildInfoItem(
                    'Available',
                    '${bus.availableSeats}',
                    Icons.airline_seat_recline_normal,
                  ),
                  _buildInfoItem(
                    'Fare',
                    '30 Tk',
                    Icons.attach_money,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You\'re now waiting for this bus'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.access_time),
                      label: const Text('Wait for Bus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You\'re now on this bus'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.directions_bus),
                      label: const Text('On the Bus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Find a Route'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'From',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'To',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Route searched'),
                  ),
                );
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

// Bus List Screen
class BusListScreen extends StatelessWidget {
  final List<Bus> buses;
  
  const BusListScreen({super.key, required this.buses});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search buses',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Buses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showAddBusDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Bus Addon'),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return BusCard(bus: bus);
            },
          ),
        ),
      ],
    );
  }
  
  void _showAddBusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bus Addon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Bus Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Route',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Total Seats',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bus addon added successfully'),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Bus Card
class BusCard extends StatelessWidget {
  final Bus bus;
  
  const BusCard({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    // Calculate fill percentage
    final fillPercentage = 1 - (bus.availableSeats / bus.totalSeats);
    final Color fillColor = fillPercentage > 0.8
        ? Colors.red
        : (fillPercentage > 0.5 ? Colors.orange : Colors.green);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        bus.route,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Seats: ${bus.availableSeats}/${bus.totalSeats}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fillPercentage,
                          backgroundColor: Colors.grey[200],
                          color: fillColor,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Show bus options
                    _showBusOptions(context, bus);
                  },
                  child: const Text('Actions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBusOptions(BuildContext context, Bus bus) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map, color: Colors.blue),
                title: const Text('View on Map'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text('Wait for Bus'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You\'re now waiting for ${bus.name}'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.airline_seat_recline_normal, color: Colors.green),
                title: const Text('On the Bus'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You\'re now on ${bus.name}'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text('Left the Bus'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You\'ve left ${bus.name}'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Community Screen
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> _tags = [
    'Congestion',
    'Accident',
    'BUET',
    'Flyover',
    'Rayerbag',
    'New Bus',
  ];
  
  final List<Post> _posts = [
    Post(
      id: '1',
      author: 'Imtiaz Ahmed',
      content: 'Heavy traffic on the flyover right now. Better take the Gulistan route if you\'re heading to Bakshibazar.',
      tags: ['Congestion', 'Flyover'],
      location: 'Rayerbag Flyover',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      upvotes: 15,
    ),
    Post(
      id: '2',
      author: 'Farhan Khan',
      content: 'Nilachol Paribahan has added 5 new buses on the Mohammadpur route. Much better service now!',
      tags: ['New Bus', 'Nilachol'],
      location: 'Mohammadpur',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      upvotes: 8,
    ),
    Post(
      id: '3',
      author: 'Nishat Rahman',
      content: 'BUET university buses are running on time today. No delays reported.',
      tags: ['BUET', 'On Time'],
      location: 'BUET Campus',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      upvotes: 12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search community posts',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        
        // Tags row
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(_tags[index]),
                  backgroundColor: Colors.green,
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              );
            },
          ),
        ),
        
        // Posts
        Expanded(
          child: ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return PostCard(post: post);
            },
          ),
        ),
      ],
    );
  }
}

// Post model
class Post {
  final String id;
  final String author;
  final String content;
  final List<String> tags;
  final String location;
  final DateTime timestamp;
  int upvotes;
  
  Post({
    required this.id,
    required this.author,
    required this.content,
    required this.tags,
    required this.location,
    required this.timestamp,
    this.upvotes = 0,
  });
}

// Post Card
class PostCard extends StatelessWidget {
  final Post post;
  
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with author and location
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    post.author[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(post.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Content
            Text(post.content),
            const SizedBox(height: 12),
            
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up),
                      color: Colors.green,
                      iconSize: 20,
                    ),
                    Text('${post.upvotes}'),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment, size: 20),
                  label: const Text('Comment'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text('Share'),
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
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}