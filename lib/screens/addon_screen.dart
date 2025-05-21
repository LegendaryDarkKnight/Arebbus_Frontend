import 'package:flutter/material.dart';
import 'package:arebbus/models/addon_model.dart';
import 'package:arebbus/service/mock_data_service.dart';

class AddonScreen extends StatefulWidget {
  const AddonScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddonScreenState();
}

class _AddonScreenState extends State<AddonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<Addon> _allAddons;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _allAddons = MockDataService.getMockAddons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search add-ons...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),

          // Tab bar for filters
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Installed'),
              Tab(text: 'My Add-ons'),
              Tab(text: 'Category'),
            ],
          ),

          // Tab bar views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddonList(filterType: 'All'),
                _buildAddonList(filterType: 'Installed'),
                _buildAddonList(filterType: 'My Add-ons'),
                _buildAddonList(filterType: 'Category'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new bus/route (addon) - Mock')),
          );
        },
        label: const Text('Add an Addon'),
        icon: const Icon(Icons.add_road),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  Widget _buildAddonList({required String filterType}) {
    List<Addon> filteredAddons = _getFilteredAddons(filterType);

    if (filteredAddons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No add-ons found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredAddons.length,
      itemBuilder: (context, index) {
        final addon = filteredAddons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getCategoryColor(addon.category),
                      child: Text(
                        addon.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addon.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${addon.author.username} • ${addon.category}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    addon.isInstalled
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : OutlinedButton(
                          onPressed: () {
                            // Handle install action
                            setState(() {
                              // In a real app, we would call a service to install the addon
                              // For now, let's just update the UI
                              filteredAddons[index] = Addon(
                                id: addon.id,
                                name: addon.name,
                                description: addon.description,
                                category: addon.category,
                                author: addon.author,
                                installs: addon.installs + 1,
                                rating: addon.rating,
                                isInstalled: true,
                                createdAt: addon.createdAt,
                                updatedAt: addon.updatedAt,
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text('Install'),
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(addon.description),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${addon.rating}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.download,
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text('${addon.installs} installs'),
                      ],
                    ),
                    Text(
                      'Updated ${_getTimeAgo(addon.updatedAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Addon> _getFilteredAddons(String filterType) {
    // Filter based on selected tab
    List<Addon> filteredAddons = [];

    switch (filterType) {
      case 'All':
        filteredAddons = _allAddons;
        break;
      case 'Installed':
        filteredAddons =
            _allAddons.where((addon) => addon.isInstalled).toList();
        break;
      case 'My Add-ons':
        // Filter addons created by the current user
        filteredAddons =
            _allAddons
                .where(
                  (addon) => addon.author.id == MockDataService.currentUser.id,
                )
                .toList();
        break;
      case 'Category':
        // Show all categories or we could further filter by a specific category
        filteredAddons = _allAddons;
        break;
    }

    // Apply search filter if search query exists
    if (_searchQuery.isNotEmpty) {
      filteredAddons =
          filteredAddons
              .where(
                (addon) =>
                    addon.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    addon.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    addon.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filteredAddons;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bus Service':
        return Colors.blue;
      case 'Navigation':
        return Colors.orange;
      case 'Community':
        return Colors.green;
      case 'Alerts':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
