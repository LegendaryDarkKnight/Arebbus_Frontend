import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/service/api_service.dart';

class BusDetailScreen extends StatefulWidget {
  final Bus bus;
  
  const BusDetailScreen({super.key, required this.bus});
  
  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  final ApiService _apiService = ApiService.instance;
  final MapController _mapController = MapController();
  
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  late LatLng _initialCenter;
  
  
  @override
  void initState() {
    super.initState();
    _setupMap();
  }
  
  void _setupMap() {
    _markers = [];
    _polylines = [];
    
    if (widget.bus.route != null && widget.bus.route!.stops.isNotEmpty) {
      final stops = widget.bus.route!.stops;
      
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
      
      // Create polyline connecting all stops
      if (stops.length > 1) {
        _polylines.add(
          Polyline(
            points: stops.map((stop) => LatLng(stop.latitude, stop.longitude)).toList(),
            color: Colors.blue,
            strokeWidth: 3,
          ),
        );
      }
      
      // Set initial center to the first stop
      _initialCenter = LatLng(stops.first.latitude, stops.first.longitude);
    } else {
      // Default center if no stops
      _initialCenter = const LatLng(40.7128, -74.0060); // Default to NYC
    }
  }
  
  Future<void> _toggleInstallation() async {
    try {
      if (widget.bus.installed) {
        await _apiService.uninstallBus(widget.bus.id!);
        _showSuccessSnackBar('${widget.bus.name} uninstalled successfully');
      } else {
        await _apiService.installBus(widget.bus.id!);
        _showSuccessSnackBar('${widget.bus.name} installed successfully');
      }
      
      // Navigate back to refresh the list
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
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
  
  void _fitMarkersInMap() {
    if (widget.bus.route == null || widget.bus.route!.stops.isEmpty) return;
    
    final stops = widget.bus.route!.stops;
    
    if (stops.length == 1) {
      _mapController.move(
        LatLng(stops.first.latitude, stops.first.longitude),
        15,
      );
      return;
    }
    
    double minLat = stops.first.latitude;
    double maxLat = stops.first.latitude;
    double minLng = stops.first.longitude;
    double maxLng = stops.first.longitude;
    
    for (final stop in stops) {
      minLat = stop.latitude < minLat ? stop.latitude : minLat;
      maxLat = stop.latitude > maxLat ? stop.latitude : maxLat;
      minLng = stop.longitude < minLng ? stop.longitude : minLng;
      maxLng = stop.longitude > maxLng ? stop.longitude : maxLng;
    }
    
    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
    
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bus.name),
        actions: [
          IconButton(
            icon: Icon(
              widget.bus.installed ? Icons.delete : Icons.download,
              color: widget.bus.installed ? Colors.red : Colors.green,
            ),
            onPressed: _toggleInstallation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bus information card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.bus.installed ? Colors.green : Colors.grey[300],
                        child: Icon(
                          Icons.directions_bus,
                          color: widget.bus.installed ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bus.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'By ${widget.bus.authorName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.bus.route != null) ...[
                    Text(
                      'Route: ${widget.bus.route!.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      _buildInfoChip(Icons.people, '${widget.bus.capacity} seats'),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.download, '${widget.bus.numInstall} installs'),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.thumb_up, '${widget.bus.numUpvote} upvotes'),
                    ],
                  ),
                  if (widget.bus.status != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.bus.status == 'ACTIVE' ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.bus.status!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Map section
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.bus.route != null && widget.bus.route!.stops.isNotEmpty
                    ? Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            color: Colors.grey[100],
                            child: Text(
                              'Route Map (${widget.bus.route!.stops.length} stops)',
                              style: const TextStyle(
                                fontSize: 16,
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
                                onMapReady: () {
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    _fitMarkersInMap();
                                  });
                                },
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
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No route information available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
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
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: 1, // Buses tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pop(context); // Go back to buses list
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 4:
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
      ),
    );
  }
}
