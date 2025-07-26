import 'package:arebbus/screens/addon_screen.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/screens/bus_list_screen.dart';
import 'package:arebbus/screens/feed_screen.dart';
import 'package:arebbus/screens/map_screen.dart';
import 'package:arebbus/screens/profile_screen.dart';
import 'package:arebbus/screens/location_screen.dart';

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
    BusListScreen(showBottomNav: false, showInstalledOnly: false),
    BusListScreen(showBottomNav: false, showInstalledOnly: true),
    LocationScreen(),
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
        return 'All Buses';
      case 2:
        return 'Installed Buses';
      case 3:
        return 'Your Location';
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
        return Icons.download_done;
      case 3:
        return Icons.my_location;
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
      default:
        return Colors.blue;
    }
  }

  Future<void> _logout() async {
    _isLoading = true;
    try {
      await ApiService.instance.logout();
      if (mounted) {
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
              label: 'All Buses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download_outlined),
              activeIcon: Icon(Icons.download_done),
              label: 'Installed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.my_location),
              label: 'Location',
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

}
