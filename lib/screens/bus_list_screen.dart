import 'package:flutter/material.dart';
import 'package:arebbus/models/bus.dart';
import 'package:arebbus/models/bus_response.dart';
import 'package:arebbus/service/api_service.dart';
import 'package:arebbus/screens/bus_detail_screen.dart';
import 'package:arebbus/screens/add_bus_screen.dart';

class BusListScreen extends StatefulWidget {
  final bool showInstalledOnly;
  
  const BusListScreen({super.key, this.showInstalledOnly = false});
  
  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final ApiService _apiService = ApiService.instance;
  final ScrollController _scrollController = ScrollController();
  
  List<Bus> _buses = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
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
      final BusResponse response = widget.showInstalledOnly 
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
      final BusResponse response = widget.showInstalledOnly 
          ? await _apiService.getInstalledBuses(page: _currentPage + 1, size: 2)
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
      
      // Refresh the list
      await _loadBuses();
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
  
  void _navigateToBusDetail(Bus bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusDetailScreen(bus: bus),
      ),
    );
  }
  
  void _navigateToAddBus() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBusScreen(),
      ),
    );
    
    // Refresh the list if a bus was created
    if (result == true) {
      _loadBuses();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showInstalledOnly ? 'Installed Buses' : 'All Buses'),
        actions: [
          IconButton(
            icon: Icon(widget.showInstalledOnly ? Icons.public : Icons.download_done),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BusListScreen(showInstalledOnly: !widget.showInstalledOnly),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBuses,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: widget.showInstalledOnly ? null : FloatingActionButton(
        onPressed: _navigateToAddBus,
        tooltip: 'Add New Bus',
        child: const Icon(Icons.add),
      ),
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
            ElevatedButton(
              onPressed: _loadBuses,
              child: const Text('Retry'),
            ),
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
              widget.showInstalledOnly ? 'No installed buses' : 'No buses available',
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
    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Increased from 4,8 to 16,16
    elevation: 4, // Added elevation for better visual separation
    child: InkWell(
      onTap: () => _navigateToBusDetail(bus),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25, // Takes 25% of screen height
        padding: const EdgeInsets.all(16),
        child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Increased size
            backgroundColor: bus.installed ? Colors.green : Colors.grey[300],
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
          IconButton(
            icon: Icon(
              bus.installed ? Icons.delete : Icons.download,
              color: bus.installed ? Colors.red : Colors.green,
              size: 28,
            ),
            onPressed: () => _toggleInstallation(bus),
          ),
        ],
      ),
    ),
  ));
}
}
