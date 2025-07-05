import 'package:arebbus/models/route_model.dart';
import 'package:arebbus/models/stop.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AddonScreen extends StatefulWidget {
  const AddonScreen({super.key});

  @override
  State<AddonScreen> createState() => _AddonScreenState();
}

class _AddonScreenState extends State<AddonScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _locationPermissionGranted = false;

  // State for route and stop management
  RouteModel? _selectedRoute;
  late final List<RouteModel> _mockRoutes;
  final List<LatLng> _selectedPoints = [];
  final List<Marker> _routeMarkers = [];
  Polyline? _routePolyline;

  @override
  void initState() {
    super.initState();
    _generateMockRoutes();
    _initializeMap();
  }

  // Generate mock data for routes
  void _generateMockRoutes() {
    _mockRoutes = [
      RouteModel(
        id: 'R1',
        name: 'University Shuttle',
        stops: [
          Stop(
            id: 1,
            name: 'Main Gate',
            latitude: 22.4639,
            longitude: 91.9701,
            authorName: 'Admin',
          ),
          Stop(
            id: 2,
            name: 'Arts Faculty',
            latitude: 22.4658,
            longitude: 91.9715,
            authorName: 'Admin',
          ),
          Stop(
            id: 3,
            name: 'Central Library',
            latitude: 22.4682,
            longitude: 91.9732,
            authorName: 'Admin',
          ),
        ],
      ),
      RouteModel(
        id: 'R2',
        name: 'City Circular',
        stops: [
          Stop(
            id: 4,
            name: 'New Market',
            latitude: 22.3569,
            longitude: 91.8339,
            authorName: 'Admin',
          ),
          Stop(
            id: 5,
            name: 'GEC Circle',
            latitude: 22.3592,
            longitude: 91.8210,
            authorName: 'Admin',
          ),
          Stop(
            id: 6,
            name: '2 Number Gate',
            latitude: 22.3615,
            longitude: 91.8325,
            authorName: 'Admin',
          ),
        ],
      ),
    ];
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // ... (Your existing _getCurrentLocation method remains unchanged)
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog('Location services are disabled');
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog('Location permissions are permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationPermissionGranted = true;
          _isLoading = false;
        });
        _mapController.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showLocationDialog('Error getting location: ${e.toString()}');
      }
    }
  }

  void _showLocationDialog(String message) {
    // ... (Your existing _showLocationDialog method remains unchanged)
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Access'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _getCurrentLocation();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  // lib/screens/addon_screen.dart

  void _onRouteSelected(RouteModel? route) {
    setState(() {
      _selectedRoute = route;
      _routeMarkers.clear();
      _routePolyline = null;

      if (route != null) {
        // Create markers for each stop in the route
        _routeMarkers.addAll(
          route.stops.map(
            (stop) => Marker(
              point: LatLng(stop.latitude, stop.longitude),
              width: 80,
              height: 40,
              child: Column(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  Text(
                    stop.name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Create a polyline to connect the stops
        final points =
            route.stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
        _routePolyline = Polyline(
          points: points,
          color: Colors.deepPurpleAccent,
          strokeWidth: 4.0,
        );

        // Fit map to route bounds
        if (points.isNotEmpty) {
          // CORRECTED SECTION: Use LatLngBounds and CameraFit.bounds
          final bounds = LatLngBounds.fromPoints(points);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(
                50.0,
              ), // Add padding around the bounds
            ),
          );
        }
      }
    });
  }

  Future<void> _createStopsFromSelection() async {
    if (_selectedPoints.isEmpty) return;

    final pointsToProcess = List<LatLng>.from(_selectedPoints);
    int createdCount = 0;

    for (int i = 0; i < pointsToProcess.length; i++) {
      final point = pointsToProcess[i];
      final stopName = await _showAddStopNameDialog(point, i + 1);

      if (stopName != null && stopName.trim().isNotEmpty) {
        await createStop(stopName.trim(), point.latitude, point.longitude);
        createdCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$createdCount stop(s) created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    setState(() {
      _selectedPoints.clear();
    });
  }

  Future<String?> _showAddStopNameDialog(LatLng position, int stopNumber) {
    final TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Name Stop #$stopNumber'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Stop Name',
                    hintText: 'Enter a name for this stop',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop(nameController.text);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  // API service integration (Your existing createStop method)
  Future<void> createStop(
    String name,
    double latitude,
    double longitude,
  ) async {
    // ... (Your existing createStop method remains unchanged)
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
                const SizedBox(width: 16),
                Text('Creating stop "$name"...'),
              ],
            ),
            duration: const Duration(seconds: 4), // Kept open longer
          ),
        );
      }

      await ApiService.instance.createStop(name, latitude, longitude);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stop "$name" created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create stop: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      _getCurrentLocation();
    }
  }

  Widget _buildMapPanel() {
    if (_isLoading) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Getting your location...'),
            ],
          ),
        ),
      );
    }
    return Container(
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? const LatLng(22.46, 91.97),
            initialZoom: 14.0,
            onTap: (tapPosition, point) {
              setState(() {
                _selectedPoints.add(point);
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (_routePolyline != null)
              PolylineLayer(polylines: [_routePolyline!]),
            MarkerLayer(
              markers: [
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                // Markers for the selected route's stops
                ..._routeMarkers,
                // Markers for newly tapped points
                ..._selectedPoints.asMap().entries.map(
                  (entry) => Marker(
                    point: entry.value,
                    width: 80,
                    height: 50,
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_location,
                          color: Colors.orange[700],
                          size: 25,
                        ),
                        Text(
                          "New ${entry.key + 1}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stops and Routes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Route to Display",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RouteModel>(
              value: _selectedRoute,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose a route to see its stops',
              ),
              items:
                  _mockRoutes.map((route) {
                    return DropdownMenuItem(
                      value: route,
                      child: Text(route.name),
                    );
                  }).toList(),
              onChanged: _onRouteSelected,
            ),
            const SizedBox(height: 24),
            const Text(
              "Tap Map to Add New Stops",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                _buildMapPanel(),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _centerOnCurrentLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    mini: true,
                    heroTag: 'centerLocationFab',
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedPoints.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _createStopsFromSelection,
                      icon: const Icon(Icons.add_task),
                      label: Text('Create ${_selectedPoints.length} Stop(s)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedPoints.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear Selection'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Center(
                child: Text(
                  'Tap on the map to mark locations for new stops.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
