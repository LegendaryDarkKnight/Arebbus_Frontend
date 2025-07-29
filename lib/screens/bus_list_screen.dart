import 'package:flutter/material.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/bus_response.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/screens/bus_detail_screen.dart';
import 'package:arebbus/screens/add_bus_screen.dart';
import 'package:arebbus/screens/home_screen.dart';
import 'package:arebbus/services/location_tracking_service.dart';
import 'package:geolocator/geolocator.dart';

/// Bus listing screen for the Arebbus application.
/// 
/// This screen displays a comprehensive list of buses available in the system,
/// supporting both all buses and user-installed buses views. It provides
/// features for browsing, searching, and managing buses with infinite scrolling
/// pagination for efficient data loading.
/// 
/// The screen integrates with location services to show distance-based
/// information and supports navigation to detailed bus views and bus creation.
class BusListScreen extends StatefulWidget {
  /// Flag to filter and show only user-installed buses
  final bool showInstalledOnly;
  
  /// Flag to control bottom navigation visibility
  final bool showBottomNav;

  /// Creates a new BusListScreen instance.
  /// 
  /// Parameters:
  /// - [showInstalledOnly]: If true, shows only buses installed by the user
  /// - [showBottomNav]: If true, displays the bottom navigation bar
  const BusListScreen({
    super.key,
    this.showInstalledOnly = false,
    this.showBottomNav = true,
  });

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

/// State class for the BusListScreen widget.
/// 
/// Manages bus data loading, pagination, user interactions, and location-based
/// features. Handles infinite scrolling, error states, and navigation to
/// detailed bus information screens.
class _BusListScreenState extends State<BusListScreen> {
  /// API service instance for backend communications
  final ApiService _apiService = ApiService.instance;
  
  /// Scroll controller for implementing infinite scrolling pagination
  final ScrollController _scrollController = ScrollController();

  /// List of buses currently loaded and displayed
  List<Bus> _buses = [];
  
  /// Current page number for pagination (0-based)
  int _currentPage = 0;
  
  /// Loading state indicator for API operations
  bool _isLoading = false;
  
  /// Flag indicating if more data is available for loading
  bool _hasMore = true;
  
  /// Error message to display when data loading fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBuses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreBuses();
    }
  }

  Future<void> _loadBuses() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final BusResponse response =
          widget.showInstalledOnly
              ? await _apiService.getInstalledBuses(page: 0, size: 3)
              : await _apiService.getAllBuses(page: 0, size: 3);

      setState(() {
        _buses = response.buses;
        _currentPage = response.page;
        _hasMore = response.page < response.totalPages - 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreBuses() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final BusResponse response =
          widget.showInstalledOnly
              ? await _apiService.getInstalledBuses(
                page: _currentPage + 1,
                size: 2,
              )
              : await _apiService.getAllBuses(page: _currentPage + 1, size: 2);

      setState(() {
        _buses.addAll(response.buses);
        _currentPage = response.page;
        _hasMore = response.page < response.totalPages - 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _toggleInstallation(Bus bus) async {
    try {
      if (bus.installed) {
        await _apiService.uninstallBus(bus.id!);
        _showSuccessSnackBar('${bus.name} uninstalled successfully');
      } else {
        await _apiService.installBus(bus.id!);
        _showSuccessSnackBar('${bus.name} installed successfully');
      }

      // Clear current list and refresh with fresh data
      setState(() {
        _buses.clear();
        _currentPage = 0;
        _hasMore = true;
      });
      
      // Small delay to ensure server has updated the bus status
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Refresh the list
      await _loadBuses();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _navigateToBusDetail(Bus bus) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BusDetailScreen(bus: bus)),
    );
  }

  void _navigateToAddBus() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddBusScreen()),
    );

    // Refresh the list if a bus was created
    if (result == true) {
      _loadBuses();
    }
  }

  Future<void> _waitForBus(Bus bus) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Please enable location services to wait for a bus.');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission is required to wait for a bus.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Please enable location permission in app settings.');
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Get current position
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );

        // Set waiting status
        final userLocation = await _apiService.setUserWaiting(
          latitude: position.latitude,
          longitude: position.longitude,
          busId: bus.id!,
        );

        // Start location tracking service
        LocationTrackingService.instance.updateCachedUserStatus(userLocation);

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Navigate to home screen with location tab selected
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(initialTabIndex: 3), // Location tab
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        _showErrorSnackBar('Failed to set waiting status: ${e.toString()}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to get location: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton:
          widget.showInstalledOnly
              ? null
              : FloatingActionButton(
                onPressed: _navigateToAddBus,
                tooltip: 'Add New Bus',
                child: const Icon(Icons.add),
              ),
      bottomNavigationBar:
          widget.showBottomNav ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _buses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _buses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading buses',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadBuses, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_buses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.showInstalledOnly
                  ? 'No installed buses'
                  : 'No buses available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.showInstalledOnly
                  ? 'Install some buses to see them here'
                  : 'Check back later for available buses',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBuses,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _buses.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _buses.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final bus = _buses[index];
          return _buildBusCard(bus);
        },
      ),
    );
  }

  Widget _buildBusCard(Bus bus) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ), // Increased from 4,8 to 16,16
      elevation: 4, // Added elevation for better visual separation
      child: InkWell(
        onTap: () => _navigateToBusDetail(bus),
        child: Container(
          height:
              MediaQuery.of(context).size.height *
              0.25, // Takes 25% of screen height
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30, // Increased size
                backgroundColor:
                    bus.installed ? Colors.green : Colors.grey[300],
                child: Icon(
                  Icons.directions_bus,
                  color: bus.installed ? Colors.white : Colors.grey[600],
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${bus.authorName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Route: ${bus.route?.name ?? 'Unknown'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${bus.capacity} seats'),
                        const SizedBox(width: 16),
                        Icon(Icons.download, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${bus.numInstall} installs'),
                        const SizedBox(width: 16),
                        Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('${bus.numUpvote} upvotes'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      bus.installed ? Icons.delete : Icons.download,
                      color: bus.installed ? Colors.red : Colors.green,
                      size: 28,
                    ),
                    onPressed: () => _toggleInstallation(bus),
                  ),
                  if (widget.showInstalledOnly && bus.installed)
                    SizedBox(
                      width: 60,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => _waitForBus(bus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(60, 30),
                        ),
                        child: const Text(
                          'Wait',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor:
            widget.showInstalledOnly ? Colors.orange : Colors.green,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: widget.showInstalledOnly ? 2 : 1, // Current tab index
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              if (widget.showInstalledOnly) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const BusListScreen(
                          showBottomNav: true,
                          showInstalledOnly: false,
                        ),
                  ),
                );
              }
              // Already on all buses page if showInstalledOnly is false
              break;
            case 2:
              if (!widget.showInstalledOnly) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const BusListScreen(
                          showBottomNav: true,
                          showInstalledOnly: true,
                        ),
                  ),
                );
              }
              // Already on installed buses page if showInstalledOnly is true
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/home');
              break;
          }
        },
        items: const [
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
      ),
    );
  }
}
