import 'package:arebbus/screens/addon_screen.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/screens/bus_list_screen.dart';
import 'package:arebbus/screens/feed_screen.dart';
import 'package:arebbus/screens/map_screen.dart';
import 'package:arebbus/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    BusListScreen(),
    MapScreen(),
    AddonScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Community Feed';
      case 1:
        return 'Available Buses';
      case 2:
        return 'Live Map';
      case 3:
        return 'Addons';
      case 4:
        return 'My Profile';
      default:
        return 'Arebbus';
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.feed;
      case 1:
        return Icons.directions_bus;
      case 2:
        return Icons.map;
      case 3:
        return Icons.extension;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  Future<void> _logout() async {
    _isLoading = true;
    ApiService apiService = ApiService();
    try {
      await apiService.logout();
      if (mounted){
        Navigator.pushReplacementNamed(context, '/login');
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _getColorForIndex(_selectedIndex),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(_getIconForIndex(_selectedIndex), size: 24),
            SizedBox(width: 8),
            Text(
              _getTitleForIndex(_selectedIndex),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.white),
                      SizedBox(width: 8),
                      Text('No new notifications'),
                    ],
                  ),
                  backgroundColor: Colors.grey[800],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
          ),
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDependencyInfo(context),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed),
              activeIcon: Icon(Icons.feed),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined),
              activeIcon: Icon(Icons.directions_bus),
              label: 'Buses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.extension_outlined),
              activeIcon: Icon(Icons.extension),
              label: 'Addons',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _getColorForIndex(_selectedIndex),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showDependencyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('How Add-ons Work'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add-ons have dependencies:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('🚏 Stops: Base locations for buses'),
                  SizedBox(height: 8),
                  Text('🛣️ Routes: Connect multiple stops'),
                  SizedBox(height: 8),
                  Text('🚌 Bus Services: Operate on routes'),
                  SizedBox(height: 16),
                  Text(
                    'You must create them in order: Stop → Route → Bus',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}
