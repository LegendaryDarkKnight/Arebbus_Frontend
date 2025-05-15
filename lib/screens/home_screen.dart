import 'package:arebbus/screens/addon_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    BusListScreen(),
    MapScreen(), 
    AddonScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications (mock).')),
                );
            },
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Buses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_card),
            label: 'Addons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
      ),
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post')),
                );
              },
              label: const Text('Add Post'),
              icon: const Icon(Icons.post_add),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            )
          : _selectedIndex == 3 
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add new bus/route (addon) - Mock')),
                );
              },
              label: const Text('Add an Addon'),
              icon: const Icon(Icons.add_road),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ): null,
    );
  }
}
