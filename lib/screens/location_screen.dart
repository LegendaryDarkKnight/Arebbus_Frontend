import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;
  List<Marker> _markers = [];
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them in your device settings.';
          _isLoading = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied. Please grant location access to use this feature.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied. Please enable them in app settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _markers = [
          Marker(
            point: _currentLocation!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 40,
            ),
          ),
        ];
        _isLoading = false;
      });

      // Move map to current location only if map is ready
      if (_mapReady && _currentLocation != null) {
        _moveToCurrentLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLocation() async {
    await _getCurrentLocation();
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
        title: const Text('Your Location'),
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
        // Location info card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Current Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
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
        ),
        
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
}