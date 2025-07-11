import 'package:arebbus/models/addon_category.dart';
import 'package:flutter/material.dart';
import 'package:arebbus/models/addon.dart';
import 'package:arebbus/service/new_mock_data_service.dart';

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
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Bus', 'Route', 'Stop'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _allAddons = NewMockDataService.getMockAddons();
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
          // Search Bar
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

          // Category Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Installed'),
              Tab(text: 'My Add-ons'),
              Tab(text: 'Dependencies'),
            ],
          ),

          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAddonList(filterType: 'All'),
                _buildAddonList(filterType: 'Installed'),
                _buildAddonList(filterType: 'My Add-ons'),
                _buildDependencyView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAddonDialog(context),
        label: const Text('Create Add-on'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
            if (filterType == 'All' && _selectedCategory != 'All')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                    });
                  },
                  child: const Text('Clear filters'),
                ),
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
        return _buildAddonCard(addon, index, filteredAddons);
      },
    );
  }

  // Widget _buildAddonCard(Addon addon, int index, List<Addon> filteredAddons) {
  //   final dependencies = _checkDependencies(addon);
  //   final canInstall = dependencies.isEmpty;

  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12.0),
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               CircleAvatar(
  //                 backgroundColor: _getCategoryColor(addon.category),
  //                 child: Icon(
  //                   _getCategoryIcon(addon.category),
  //                   color: Colors.white,
  //                   size: 20,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       addon.name,
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'by ${addon.author.name} • ${addon.category}',
  //                       style: TextStyle(
  //                         color: Colors.grey.shade600,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               _buildInstallButton(addon, canInstall, dependencies),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Text(
  //             addon.description,
  //             style: TextStyle(color: Colors.grey.shade700),
  //           ),

  //           // Show dependencies if any
  //           if (dependencies.isNotEmpty) ...[
  //             const SizedBox(height: 12),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.orange.shade50,
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(color: Colors.orange.shade200),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Icon(
  //                         Icons.warning_amber,
  //                         color: Colors.orange.shade700,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 8),
  //                       Text(
  //                         'Missing Dependencies',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.orange.shade700,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),
  //                   ...dependencies.map(
  //                     (dep) => Padding(
  //                       padding: const EdgeInsets.only(bottom: 4),
  //                       child: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.fiber_manual_record,
  //                             size: 8,
  //                             color: Colors.orange.shade700,
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Expanded(child: Text(dep)),
  //                           TextButton(
  //                             onPressed: () => _navigateToCreateDependency(dep),
  //                             style: TextButton.styleFrom(
  //                               padding: const EdgeInsets.symmetric(
  //                                 horizontal: 8,
  //                               ),
  //                               minimumSize: const Size(60, 30),
  //                             ),
  //                             child: const Text(
  //                               'Create',
  //                               style: TextStyle(fontSize: 12),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],

  //           const SizedBox(height: 12),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   const Icon(Icons.star, size: 16, color: Colors.amber),
  //                   const SizedBox(width: 4),
  //                   Text('${addon.rating}'),
  //                 ],
  //               ),
  //               Row(
  //                 children: [
  //                   const Icon(Icons.download, size: 16, color: Colors.blue),
  //                   const SizedBox(width: 4),
  //                   Text('${addon.installs}'),
  //                 ],
  //               ),
  //               Text(
  //                 _getTimeAgo(addon.updatedAt),
  //                 style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAddonCard(Addon addon, int index, List<Addon> filteredAddons) {
    final dependencies = _checkDependencies(addon);
    final canInstall = dependencies.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCategoryColor(addon.category),
                  child: Icon(
                    _getCategoryIcon(addon.category),
                    color: Colors.white,
                    size: 20,
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
                        'by ${addon.author.name} • ${addon.category}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInstallButton(addon, canInstall, dependencies),
              ],
            ),
            const SizedBox(height: 12),
            // Limit description height
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 60),
              child: SingleChildScrollView(
                child: Text(
                  addon.description,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            // Show dependencies if any
            if (dependencies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Missing Dependencies',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Limit dependencies list height
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            dependencies
                                .map(
                                  (dep) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.fiber_manual_record,
                                          size: 8,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(dep)),
                                        TextButton(
                                          onPressed:
                                              () => _navigateToCreateDependency(
                                                dep,
                                              ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minimumSize: const Size(60, 30),
                                          ),
                                          child: const Text(
                                            'Create',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    const Icon(Icons.download, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${addon.installs}'),
                  ],
                ),
                Text(
                  _getTimeAgo(addon.updatedAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallButton(
    Addon addon,
    bool canInstall,
    List<String> dependencies,
  ) {
    if (addon.isInstalled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 4),
          const Text('Installed', style: TextStyle(color: Colors.green)),
        ],
      );
    }

    if (!canInstall) {
      return OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: Text('Need ${dependencies.length} deps'),
      );
    }

    return ElevatedButton(
      onPressed: () => _installAddon(addon),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: const Text('Install'),
    );
  }

  // Widget _buildDependencyView() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Dependency Chain',
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 16),
  //         Card(
  //           child: Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               children: [
  //                 _buildDependencyStep(
  //                   'Stop',
  //                   'Create bus stops for locations',
  //                   Icons.location_on,
  //                   Colors.red,
  //                   isFirst: true,
  //                 ),
  //                 _buildDependencyArrow(),
  //                 _buildDependencyStep(
  //                   'Route',
  //                   'Connect stops to create routes',
  //                   Icons.route,
  //                   Colors.orange,
  //                 ),
  //                 _buildDependencyArrow(),
  //                 _buildDependencyStep(
  //                   'Bus Service',
  //                   'Add buses that follow routes',
  //                   Icons.directions_bus,
  //                   Colors.blue,
  //                   isLast: true,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 24),
  //         const Text(
  //           'Quick Actions',
  //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 12),
  //         _buildQuickActionCard(
  //           'Create Stop',
  //           'Add a new bus stop location',
  //           Icons.add_location,
  //           Colors.red,
  //           () => _navigateToCreateDependency('Stop'),
  //         ),
  //         _buildQuickActionCard(
  //           'Create Route',
  //           'Connect existing stops',
  //           Icons.add_road,
  //           Colors.orange,
  //           () => _navigateToCreateDependency('Route'),
  //         ),
  //         _buildQuickActionCard(
  //           'Create Bus Service',
  //           'Add bus for existing route',
  //           Icons.add,
  //           Colors.blue,
  //           () => _navigateToCreateDependency('Bus Service'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDependencyView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dependency Chain',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDependencyStep(
                      'Stop',
                      'Create bus stops for locations',
                      Icons.location_on,
                      Colors.red,
                      isFirst: true,
                    ),
                    _buildDependencyArrow(),
                    _buildDependencyStep(
                      'Route',
                      'Connect stops to create routes',
                      Icons.route,
                      Colors.orange,
                    ),
                    _buildDependencyArrow(),
                    _buildDependencyStep(
                      'Bus Service',
                      'Add buses that follow routes',
                      Icons.directions_bus,
                      Colors.blue,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              'Create Stop',
              'Add a new bus stop location',
              Icons.add_location,
              Colors.red,
              () => _navigateToCreateDependency('Stop'),
            ),
            _buildQuickActionCard(
              'Create Route',
              'Connect existing stops',
              Icons.add_road,
              Colors.orange,
              () => _navigateToCreateDependency('Route'),
            ),
            _buildQuickActionCard(
              'Create Bus Service',
              'Add bus for existing route',
              Icons.add,
              Colors.blue,
              () => _navigateToCreateDependency('Bus Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDependencyStep(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDependencyArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey.shade400,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  List<String> _checkDependencies(Addon addon) {
    List<String> missing = [];

    if (addon.category.value == 'Bus Service') {
      // Check if user has any routes
      bool hasRoutes = _allAddons.any(
        (a) =>
            a.category.value == 'Route' &&
            a.author.id == NewMockDataService.currentUser.id &&
            a.isInstalled,
      );

      if (!hasRoutes) {
        missing.add('Route addon required');

        // Also check for stops since routes need stops
        bool hasStops = _allAddons.any(
          (a) =>
              a.category.value == 'Stop' &&
              a.author.id == NewMockDataService.currentUser.id &&
              a.isInstalled,
        );

        if (!hasStops) {
          missing.add('Stop addon required');
        }
      }
    } else if (addon.category.value == 'Route') {
      // Check if user has any stops
      bool hasStops = _allAddons.any(
        (a) =>
            a.category.value == 'Stop' &&
            a.author.id == NewMockDataService.currentUser.id &&
            a.isInstalled,
      );

      if (!hasStops) {
        missing.add('Stop addon required');
      }
    }

    return missing;
  }

  List<Addon> _getFilteredAddons(String filterType) {
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
        filteredAddons =
            _allAddons
                .where(
                  (addon) =>
                      addon.author.id == NewMockDataService.currentUser.id,
                )
                .toList();
        break;
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredAddons =
          filteredAddons
              .where((addon) => addon.category.value == _selectedCategory)
              .toList();
    }

    // Apply search filter
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
                    addon.category.value.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filteredAddons;
  }

  Color _getCategoryColor(AddonCategory category) {
    switch (category) {
      case AddonCategory.bus:
        return Colors.blue;
      case AddonCategory.route:
        return Colors.orange;
      case AddonCategory.stop:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(AddonCategory category) {
    switch (category) {
      case AddonCategory.bus:
        return Icons.directions_bus;
      case AddonCategory.route:
        return Icons.route;
      case AddonCategory.stop:
        return Icons.location_on;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _installAddon(Addon addon) {
    setState(() {
      // Update the addon to installed
      final index = _allAddons.indexWhere((a) => a.id == addon.id);
      if (index != -1) {
        _allAddons[index] = Addon(
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
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${addon.name} installed successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to addon details or configuration
          },
        ),
      ),
    );
  }

  void _navigateToCreateDependency(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to create $type addon'),
        action: SnackBarAction(
          label: 'Create',
          onPressed: () {
            // Navigate to appropriate creation screen
          },
        ),
      ),
    );
  }

  void _showCreateAddonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Add-on'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('Stop'),
                  subtitle: const Text('Create a bus stop location'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateDependency('Stop');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.route, color: Colors.orange),
                  title: const Text('Route'),
                  subtitle: const Text('Connect stops to create a route'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateDependency('Route');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_bus, color: Colors.blue),
                  title: const Text('Bus Service'),
                  subtitle: const Text('Add a bus service for a route'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCreateDependency('Bus Service');
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
