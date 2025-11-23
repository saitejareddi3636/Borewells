import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../models/user_model.dart';
import '../services/vehicle_service.dart';
import '../services/organization_service.dart';
import 'add_edit_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

/// Complex Vehicle List Screen with advanced filtering, sorting, and search
/// 
/// Features:
/// - Multi-criteria search (name, license plate, model)
/// - Filter by type, status, and assignment
/// - Sort by multiple fields
/// - Grid/List view toggle
/// - Bulk operations support
/// - Export functionality placeholder
/// - Advanced statistics
class VehicleListScreenComplex extends StatefulWidget {
  final UserModel? currentUser;
  final bool showOnlyAssigned;
  
  const VehicleListScreenComplex({
    super.key,
    this.currentUser,
    this.showOnlyAssigned = false,
  });

  @override
  State<VehicleListScreenComplex> createState() => _VehicleListScreenComplexState();
}

class _VehicleListScreenComplexState extends State<VehicleListScreenComplex> {
  final VehicleService _vehicleService = VehicleService();
  
  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _filteredVehicles = [];
  
  bool _isLoading = true;
  bool _isGridView = false;
  
  // Search and filter state
  String _searchQuery = '';
  VehicleType? _filterType;
  VehicleStatus? _filterStatus;
  String _sortBy = 'name'; // name, status, type, updated
  bool _sortAscending = true;
  
  // Selection for bulk operations
  Set<String> _selectedVehicleIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    
    try {
      List<VehicleModel> vehicles;
      
      if (widget.currentUser != null) {
        // Load based on user permissions
        final allVehicles = await _vehicleService.getAllVehicles();
        vehicles = OrganizationService.filterVehiclesByUserAccess(
          allVehicles,
          widget.currentUser!,
        );
      } else {
        // Load all vehicles
        vehicles = await _vehicleService.getAllVehicles();
      }
      
      setState(() {
        _allVehicles = vehicles;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    }
  }

  void _applyFiltersAndSort() {
    var filtered = List<VehicleModel>.from(_allVehicles);
    
    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((v) {
        return v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               v.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (v.model?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (v.driverName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    // Apply type filter
    if (_filterType != null) {
      filtered = filtered.where((v) => v.type == _filterType).toList();
    }
    
    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered.where((v) => v.status == _filterStatus).toList();
    }
    
    // Apply sort
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case 'type':
          comparison = a.type.index.compareTo(b.type.index);
          break;
        case 'updated':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredVehicles = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          _buildStatsBar(),
          Expanded(
            child: _isLoading ? _buildLoadingView() : _buildVehicleView(),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Vehicles'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        // View toggle
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
          tooltip: _isGridView ? 'List View' : 'Grid View',
        ),
        // Selection mode toggle
        IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
          onPressed: () {
            setState(() {
              _isSelectionMode = !_isSelectionMode;
              if (!_isSelectionMode) {
                _selectedVehicleIds.clear();
              }
            });
          },
          tooltip: _isSelectionMode ? 'Exit Selection' : 'Select Multiple',
        ),
        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadVehicles,
          tooltip: 'Refresh',
        ),
        // More options
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'export', child: Text('Export Data')),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.grey[100],
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search vehicles...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFiltersAndSort();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Type filter
            _buildFilterChip(
              label: _filterType?.name ?? 'All Types',
              onPressed: () => _showTypeFilter(),
              isActive: _filterType != null,
            ),
            const SizedBox(width: 8),
            // Status filter
            _buildFilterChip(
              label: _filterStatus?.name ?? 'All Status',
              onPressed: () => _showStatusFilter(),
              isActive: _filterStatus != null,
            ),
            const SizedBox(width: 8),
            // Sort
            _buildFilterChip(
              label: 'Sort: $_sortBy ${_sortAscending ? '↑' : '↓'}',
              onPressed: () => _showSortOptions(),
              isActive: true,
            ),
            const SizedBox(width: 8),
            // Clear filters
            if (_filterType != null || _filterStatus != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filterType = null;
                    _filterStatus = null;
                    _applyFiltersAndSort();
                  });
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: isActive ? Colors.blue[100] : Colors.white,
      side: BorderSide(color: isActive ? Colors.blue : Colors.grey[300]!),
    );
  }

  Widget _buildStatsBar() {
    final total = _filteredVehicles.length;
    final available = _filteredVehicles.where((v) => v.status == VehicleStatus.available).length;
    final inUse = _filteredVehicles.where((v) => v.status == VehicleStatus.inUse).length;
    final maintenance = _filteredVehicles.where((v) => v.status == VehicleStatus.maintenance).length;
    
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total, Colors.blue),
          _buildStatItem('Available', available, Colors.green),
          _buildStatItem('In Use', inUse, Colors.orange),
          _buildStatItem('Maintenance', maintenance, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildVehicleView() {
    if (_filteredVehicles.isEmpty) {
      return _buildEmptyView();
    }
    
    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No vehicles found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (_searchQuery.isNotEmpty || _filterType != null || _filterStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _filterType = null;
                    _filterStatus = null;
                    _applyFiltersAndSort();
                  });
                },
                child: const Text('Clear filters'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        return _buildListItem(_filteredVehicles[index]);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_filteredVehicles[index]);
      },
    );
  }

  Widget _buildListItem(VehicleModel vehicle) {
    final isSelected = _selectedVehicleIds.contains(vehicle.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          onTap: () => _handleVehicleTap(vehicle),
          onLongPress: () => _handleVehicleLongPress(vehicle),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(vehicle.id),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vehicle.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(vehicle.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.licensePlate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.category, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.typeDisplayName,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          if (vehicle.driverName != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              vehicle.driverName!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(VehicleModel vehicle) {
    final isSelected = _selectedVehicleIds.contains(vehicle.id);
    
    return Material(
      color: isSelected ? Colors.blue[50] : Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleVehicleTap(vehicle),
        onLongPress: () => _handleVehicleLongPress(vehicle),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (_isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(vehicle.id),
                    )
                  else
                    Icon(
                      _getVehicleIcon(vehicle.type),
                      size: 32,
                      color: Colors.blue,
                    ),
                  const Spacer(),
                  _buildStatusBadge(vehicle.status),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.licensePlate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (vehicle.driverName != null)
                    Text(
                      vehicle.driverName!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VehicleStatus status) {
    Color color;
    switch (status) {
      case VehicleStatus.available:
        color = Colors.green;
        break;
      case VehicleStatus.inUse:
        color = Colors.orange;
        break;
      case VehicleStatus.maintenance:
        color = Colors.red;
        break;
      case VehicleStatus.outOfService:
        color = Colors.grey;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
    }
  }

  Widget? _buildFAB() {
    if (_isSelectionMode && _selectedVehicleIds.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: _handleBulkAction,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.delete),
        label: Text('Delete ${_selectedVehicleIds.length}'),
      );
    }
    
    if (widget.currentUser?.isAdmin ?? true) {
      return FloatingActionButton.extended(
        onPressed: _navigateToAddVehicle,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      );
    }
    
    return null;
  }

  void _handleVehicleTap(VehicleModel vehicle) {
    if (_isSelectionMode) {
      _toggleSelection(vehicle.id);
    } else {
      _navigateToVehicleDetails(vehicle);
    }
  }

  void _handleVehicleLongPress(VehicleModel vehicle) {
    setState(() {
      _isSelectionMode = true;
      _toggleSelection(vehicle.id);
    });
  }

  void _toggleSelection(String vehicleId) {
    setState(() {
      if (_selectedVehicleIds.contains(vehicleId)) {
        _selectedVehicleIds.remove(vehicleId);
      } else {
        _selectedVehicleIds.add(vehicleId);
      }
    });
  }

  void _navigateToVehicleDetails(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDetailsScreen(vehicleId: vehicle.id),
      ),
    );
  }

  void _navigateToAddVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditVehicleScreen(),
      ),
    ).then((_) => _loadVehicles());
  }

  void _showTypeFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Types'),
              onTap: () {
                setState(() {
                  _filterType = null;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
            ),
            ...VehicleType.values.map((type) => ListTile(
              title: Text(type.name),
              onTap: () {
                setState(() {
                  _filterType = type;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              onTap: () {
                setState(() {
                  _filterStatus = null;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
            ),
            ...VehicleStatus.values.map((status) => ListTile(
              title: Text(status.name),
              onTap: () {
                setState(() {
                  _filterStatus = status;
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name'),
              trailing: _sortBy == 'name' 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () => _changeSortOrder('name'),
            ),
            ListTile(
              title: const Text('Status'),
              trailing: _sortBy == 'status' 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () => _changeSortOrder('status'),
            ),
            ListTile(
              title: const Text('Type'),
              trailing: _sortBy == 'type' 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () => _changeSortOrder('type'),
            ),
            ListTile(
              title: const Text('Last Updated'),
              trailing: _sortBy == 'updated' 
                  ? Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : null,
              onTap: () => _changeSortOrder('updated'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeSortOrder(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = true;
      }
      _applyFiltersAndSort();
    });
    Navigator.pop(context);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _showComingSoon('Export functionality');
        break;
      case 'settings':
        _showComingSoon('Settings');
        break;
    }
  }

  void _handleBulkAction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${_selectedVehicleIds.length} vehicle(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Bulk delete functionality');
              setState(() {
                _isSelectionMode = false;
                _selectedVehicleIds.clear();
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
