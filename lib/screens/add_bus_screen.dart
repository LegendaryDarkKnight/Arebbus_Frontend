import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:arebbus/models/route.dart' as model;
import 'package:arebbus/models/stop.dart';
import 'package:arebbus/service/api_service.dart';

class AddBusScreen extends StatefulWidget {
  const AddBusScreen({super.key});

  @override
  State<AddBusScreen> createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final ApiService _apiService = ApiService.instance;
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _busNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _routeNameController = TextEditingController();
  final _stopNameController = TextEditingController();
  
  // Route selection state
  bool _useExistingRoute = true;
  model.Route? _selectedRoute;
  List<model.Route> _availableRoutes = [];
  bool _isLoadingRoutes = false;
  
  // Custom route creation state
  final List<Stop> _customStops = [];
  LatLng? _pendingStopLocation;
  final bool _isCreatingStop = false;
  
  // Map state
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  final LatLng _initialCenter = const LatLng(40.7128, -74.0060); // NYC default
  
  // UI state
  bool _isCreatingBus = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableRoutes();
  }

  @override
  void dispose() {
    _busNameController.dispose();
    _capacityController.dispose();
    _routeNameController.dispose();
    _stopNameController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableRoutes() async {
    setState(() {
      _isLoadingRoutes = true;
    });

    try {
      final response = await _apiService.getAllRoutes(page: 0, size: 100);
      setState(() {
        _availableRoutes = response.routes;
        _isLoadingRoutes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRoutes = false;
      });
      _showErrorSnackBar('Failed to load routes: $e');
    }
  }

  void _onRouteSelectionChanged(bool useExisting) {
    setState(() {
      _useExistingRoute = useExisting;
      _selectedRoute = null;
      _customStops.clear();
      _pendingStopLocation = null;
      _updateMapDisplay();
    });
  }

  void _onExistingRouteSelected(model.Route? route) {
    setState(() {
      _selectedRoute = route;
      _updateMapDisplay();
    });
  }

  void _updateMapDisplay() {
    _markers.clear();
    _polylines.clear();

    if (_useExistingRoute && _selectedRoute != null) {
      _displayExistingRoute(_selectedRoute!);
    } else if (!_useExistingRoute) {
      _displayCustomRoute();
    }

    setState(() {});
  }

  void _displayExistingRoute(model.Route route) {
    final stops = route.stops;
    
    // Add markers for each stop
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      _markers.add(
        Marker(
          point: LatLng(stop.latitude, stop.longitude),
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_on,
            color: i == 0 ? Colors.green : 
                   i == stops.length - 1 ? Colors.red : 
                   Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Create polyline
    if (stops.length > 1) {
      _polylines.add(
        Polyline(
          points: stops.map((stop) => LatLng(stop.latitude, stop.longitude)).toList(),
          color: Colors.blue,
          strokeWidth: 3,
        ),
      );
    }

    // Fit map to show all stops
    if (stops.isNotEmpty) {
      _fitMapToStops(stops.map((s) => LatLng(s.latitude, s.longitude)).toList());
    }
  }

  void _displayCustomRoute() {
    // Add markers for custom stops
    for (int i = 0; i < _customStops.length; i++) {
      final stop = _customStops[i];
      _markers.add(
        Marker(
          point: LatLng(stop.latitude, stop.longitude),
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Icon(
                Icons.location_on,
                color: i == 0 ? Colors.green : 
                       i == _customStops.length - 1 ? Colors.red : 
                       Colors.blue,
                size: 40,
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    '${i + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add pending stop marker
    if (_pendingStopLocation != null) {
      _markers.add(
        Marker(
          point: _pendingStopLocation!,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.add_location,
            color: Colors.orange,
            size: 40,
          ),
        ),
      );
    }

    // Create polyline connecting custom stops
    if (_customStops.length > 1) {
      _polylines.add(
        Polyline(
          points: _customStops.map((stop) => LatLng(stop.latitude, stop.longitude)).toList(),
          color: Colors.blue,
          strokeWidth: 3,
        ),
      );
    }
  }

  void _fitMapToStops(List<LatLng> points) {
    if (points.isEmpty) return;
    
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (!_useExistingRoute && !_isCreatingStop) {
      setState(() {
        _pendingStopLocation = point;
      });
      _updateMapDisplay();
      _showAddStopDialog();
    }
  }

  void _showAddStopDialog() {
    _stopNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _stopNameController,
              decoration: const InputDecoration(
                labelText: 'Stop Name',
                hintText: 'Enter stop name',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lat: ${_pendingStopLocation?.latitude.toStringAsFixed(6)}\n'
              'Lng: ${_pendingStopLocation?.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _pendingStopLocation = null;
              });
              _updateMapDisplay();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _addCustomStop,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addCustomStop() {
    if (_stopNameController.text.trim().isEmpty || _pendingStopLocation == null) {
      return;
    }

    final stop = Stop(
      name: _stopNameController.text.trim(),
      latitude: _pendingStopLocation!.latitude,
      longitude: _pendingStopLocation!.longitude,
      authorId: 0, // Will be set by the server
    );

    setState(() {
      _customStops.add(stop);
      _pendingStopLocation = null;
    });

    _updateMapDisplay();
    Navigator.pop(context);
  }

  void _removeCustomStop(int index) {
    setState(() {
      _customStops.removeAt(index);
    });
    _updateMapDisplay();
  }

  Future<void> _createBus() async {
    if (!_formKey.currentState!.validate()) return;

    if (_useExistingRoute && _selectedRoute == null) {
      _showErrorSnackBar('Please select a route');
      return;
    }

    if (!_useExistingRoute && _customStops.length < 2) {
      _showErrorSnackBar('Please add at least 2 stops for custom route');
      return;
    }

    setState(() {
      _isCreatingBus = true;
    });

    try {
      int routeId;

      if (_useExistingRoute) {
        routeId = _selectedRoute!.id!;
      } else {
        // Create custom route
        routeId = await _createCustomRoute();
      }

      // Create the bus
      final bus = await _apiService.createBus(
        name: _busNameController.text.trim(),
        routeId: routeId,
        capacity: int.parse(_capacityController.text.trim()),
      );

      if (mounted) {
        _showSuccessSnackBar('Bus "${bus.name}" created successfully!');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        _isCreatingBus = false;
      });
    }
  }

  Future<int> _createCustomRoute() async {
    // First, create all the stops
    List<int> stopIds = [];
    
    for (final stop in _customStops) {
      final createdStop = await _apiService.createStop(
        name: stop.name,
        latitude: stop.latitude,
        longitude: stop.longitude,
      );
      stopIds.add(createdStop.id!);
    }

    // Then create the route
    final route = await _apiService.createRoute(
      name: _routeNameController.text.trim(),
      stopIds: stopIds,
    );

    return route.id!;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bus'),
        actions: [
          if (_isCreatingBus)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form inputs section
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bus basic info
                    _buildBusInfoSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Route selection
                    _buildRouteSelectionSection(),
                    
                    const SizedBox(height: 16),
                    
                    // Custom route stops list
                    if (!_useExistingRoute) _buildCustomStopsSection(),
                  ],
                ),
              ),
            ),
            
            // Map section
            Expanded(
              flex: 3,
              child: _buildMapSection(),
            ),
            
            // Create bus button
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bus Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _busNameController,
              decoration: const InputDecoration(
                labelText: 'Bus Name',
                hintText: 'Enter bus name',
                prefixIcon: Icon(Icons.directions_bus),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a bus name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity',
                hintText: 'Enter seating capacity',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter capacity';
                }
                final capacity = int.tryParse(value.trim());
                if (capacity == null || capacity <= 0) {
                  return 'Please enter a valid capacity';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Selection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Route type selection
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Existing Route'),
                    value: true,
                    groupValue: _useExistingRoute,
                    onChanged: (value) => _onRouteSelectionChanged(value!),
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Custom Route'),
                    value: false,
                    groupValue: _useExistingRoute,
                    onChanged: (value) => _onRouteSelectionChanged(value!),
                    dense: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Route selection/creation
            if (_useExistingRoute) _buildExistingRouteSelection() else _buildCustomRouteCreation(),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingRouteSelection() {
    if (_isLoadingRoutes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableRoutes.isEmpty) {
      return Column(
        children: [
          const Text('No routes available'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadAvailableRoutes,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<model.Route>(
      value: _selectedRoute,
      decoration: const InputDecoration(
        labelText: 'Select Route',
        prefixIcon: Icon(Icons.route),
      ),
      items: _availableRoutes.map((route) => DropdownMenuItem<model.Route>(
        value: route,
        child: Text('${route.name} (${route.stops.length} stops)'),
      )).toList(),
      onChanged: _onExistingRouteSelected,
      validator: (value) {
        if (_useExistingRoute && value == null) {
          return 'Please select a route';
        }
        return null;
      },
    );
  }

  Widget _buildCustomRouteCreation() {
    return TextFormField(
      controller: _routeNameController,
      decoration: const InputDecoration(
        labelText: 'Route Name',
        hintText: 'Enter custom route name',
        prefixIcon: Icon(Icons.route),
      ),
      validator: (value) {
        if (!_useExistingRoute && (value == null || value.trim().isEmpty)) {
          return 'Please enter a route name';
        }
        return null;
      },
    );
  }

  Widget _buildCustomStopsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Stops (${_customStops.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap on map to add stops',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_customStops.isEmpty)
              const Text('No stops added yet. Tap on the map to add stops.')
            else
              ...List.generate(_customStops.length, (index) {
                final stop = _customStops[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0 ? Colors.green : 
                                   index == _customStops.length - 1 ? Colors.red : 
                                   Colors.blue,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(stop.name),
                  subtitle: Text('${stop.latitude.toStringAsFixed(4)}, ${stop.longitude.toStringAsFixed(4)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeCustomStop(index),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: Colors.grey[100],
              child: Text(
                _useExistingRoute 
                    ? (_selectedRoute != null ? 'Route: ${_selectedRoute!.name}' : 'Select a route to preview')
                    : 'Tap on map to add stops',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 12,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.arebbus',
                  ),
                  if (_polylines.isNotEmpty)
                    PolylineLayer(polylines: _polylines),
                  if (_markers.isNotEmpty)
                    MarkerLayer(markers: _markers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isCreatingBus ? null : _createBus,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isCreatingBus 
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Creating Bus...'),
                ],
              )
            : const Text(
                'Create Bus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}