import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/models/user_location.dart';
import 'package:arebbus/models/bus_location.dart';
import 'package:arebbus/models/waiting_users_count.dart';
import 'package:arebbus/services/location_tracking_service.dart';
import 'dart:async';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  final ApiService _apiService = ApiService.instance;
  final LocationTrackingService _trackingService = LocationTrackingService.instance;
  
  LatLng? _currentLocation;
  UserLocation? _userLocationStatus;
  BusLocationResponse? _busLocations;
  WaitingUsersCount? _waitingUsersCount;
  bool _isLoading = true;
  String? _errorMessage;
  List<Marker> _markers = [];
  bool _mapReady = false;
  Timer? _waitingCountTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    // Don't stop location tracking service - let it continue in background
    // But stop the waiting count timer
    _waitingCountTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First get user's tracking status
      try {
        _userLocationStatus = await _apiService.getUserLocation();
      } catch (e) {
        // If user has no location history, we'll get current location and show NO_TRACK state
        debugPrint('No user location found, will get current GPS location');
      }

      // Get current GPS location
      await _getCurrentGPSLocation();
      
      // If user is waiting for a bus, get bus locations and waiting count
      if (_userLocationStatus != null && _userLocationStatus!.isWaiting) {
        await _getBusLocations();
        await _getWaitingUsersCount();
        _startWaitingCountTimer();
      } else {
        _stopWaitingCountTimer();
      }

      _updateMarkers();
      
      // Start or update tracking service based on user status
      _updateTrackingService();
      
      setState(() {
        _isLoading = false;
      });

      // Move map to current location if ready
      if (_mapReady && _currentLocation != null) {
        _moveToCurrentLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentGPSLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them in your device settings.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please grant location access to use this feature.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _currentLocation = LatLng(position.latitude, position.longitude);
  }

  Future<void> _getBusLocations() async {
    if (_userLocationStatus?.busId != null) {
      try {
        _busLocations = await _apiService.getBusLocations(_userLocationStatus!.busId!);
      } catch (e) {
        debugPrint('Failed to get bus locations: $e');
      }
    }
  }

  Future<void> _getWaitingUsersCount() async {
    if (_userLocationStatus?.isWaiting == true) {
      try {
        _waitingUsersCount = await _apiService.getWaitingUsersCount();
      } catch (e) {
        debugPrint('Failed to get waiting users count: $e');
        _waitingUsersCount = null;
      }
    }
  }

  void _startWaitingCountTimer() {
    _stopWaitingCountTimer(); // Stop any existing timer
    
    // Update waiting count every 30 seconds
    _waitingCountTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_userLocationStatus?.isWaiting == true) {
        await _getWaitingUsersCount();
        if (mounted) {
          setState(() {}); // Refresh UI with new count
        }
      } else {
        _stopWaitingCountTimer();
      }
    });
  }

  void _stopWaitingCountTimer() {
    _waitingCountTimer?.cancel();
    _waitingCountTimer = null;
    _waitingUsersCount = null;
  }

  void _updateMarkers() {
    _markers.clear();

    // Add user location marker
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          point: _currentLocation!,
          width: 40,
          height: 40,
          child: Icon(
            Icons.my_location,
            color: _getUserMarkerColor(),
            size: 40,
          ),
        ),
      );
    }

    // Add bus location markers if waiting
    if (_userLocationStatus?.isWaiting == true && _busLocations != null) {
      for (int i = 0; i < _busLocations!.locations.length; i++) {
        final busLocation = _busLocations!.locations[i];
        _markers.add(
          Marker(
            point: LatLng(busLocation.latitude, busLocation.longitude),
            width: 60,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 20,
                    ),
                    Text(
                      '${busLocation.userCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Color _getUserMarkerColor() {
    if (_userLocationStatus == null) return Colors.blue;
    switch (_userLocationStatus!.status) {
      case 'WAITING':
        return Colors.orange;
      case 'ON_BUS':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Future<void> _refreshLocation() async {
    await _initializeLocation();
  }

  Future<void> _setOnBus() async {
    if (_currentLocation == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      UserLocation updatedStatus = await _apiService.setUserOnBus(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      
      // Update tracking service with new status
      _trackingService.updateCachedUserStatus(updatedStatus);
      
      // Refresh the page
      await _initializeLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to set on-bus status: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _stopTracking() async {
    if (_currentLocation == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      UserLocation updatedStatus = await _apiService.setUserNoTrack(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      
      // Update tracking service with new status (this will stop tracking)
      _trackingService.updateCachedUserStatus(updatedStatus);
      
      // Refresh the page
      await _initializeLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to stop tracking: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateTrackingService() {
    if (_userLocationStatus != null) {
      _trackingService.updateCachedUserStatus(_userLocationStatus!);
    }
  }

  void _openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null && _mapReady) {
      _mapController.move(_currentLocation!, 15);
    }
  }

  void _onMapReady() {
    setState(() {
      _mapReady = true;
    });
    // If we already have location, move to it
    if (_currentLocation != null) {
      _moveToCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  String _getAppBarTitle() {
    if (_userLocationStatus == null) return 'Your Location';
    switch (_userLocationStatus!.status) {
      case 'WAITING':
        return 'Waiting for ${_userLocationStatus!.busName ?? 'Bus'}';
      case 'ON_BUS':
        return 'On ${_userLocationStatus!.busName ?? 'Bus'}';
      default:
        return 'Your Location';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Location Access Required',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _refreshLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  if (_errorMessage!.contains('denied'))
                    ElevatedButton.icon(
                      onPressed: _openAppSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  if (_errorMessage!.contains('disabled'))
                    ElevatedButton.icon(
                      onPressed: _openLocationSettings,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Enable'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_currentLocation == null) {
      return const Center(
        child: Text('Unable to determine your location'),
      );
    }

    return Column(
      children: [
        // Status info card
        _buildStatusCard(),
        
        // Action buttons
        _buildActionButtons(),
        
        // Map
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation!,
                  initialZoom: 15,
                  minZoom: 1,
                  maxZoom: 18,
                  onMapReady: _onMapReady,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.arebbus',
                  ),
                  MarkerLayer(markers: _markers),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.my_location,
              color: _getUserMarkerColor(),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_userLocationStatus != null) ...[
                    Text(
                      'Status: ${_userLocationStatus!.status}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_userLocationStatus!.busName != null)
                      Text(
                        'Bus: ${_userLocationStatus!.busName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    // Show waiting users count if available
                    if (_userLocationStatus!.isWaiting && _waitingUsersCount != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_waitingUsersCount!.waitingCount} people waiting',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  Text(
                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _moveToCurrentLocation,
              tooltip: 'Center on Location',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_userLocationStatus == null || _userLocationStatus!.isNoTrack) {
      return const SizedBox.shrink(); // No buttons for NO_TRACK state
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_userLocationStatus!.isWaiting) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _setOnBus,
                  icon: const Icon(Icons.directions_bus),
                  label: const Text('I\'m On Bus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _stopTracking,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusTitle() {
    if (_userLocationStatus == null) return 'Your Current Location';
    switch (_userLocationStatus!.status) {
      case 'WAITING':
        return 'Waiting for Bus';
      case 'ON_BUS':
        return 'On Bus';
      default:
        return 'Your Current Location';
    }
  }
}