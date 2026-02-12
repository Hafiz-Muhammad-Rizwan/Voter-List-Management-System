import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:polling_app/features/officers/presentation/manage_officers_screen.dart';
import '../../../core/services/firebase_service.dart';
import '../../../models/station.dart';
import '../../../models/user.dart';
import 'station_detail_screen_copy.dart';
import 'package:uuid/uuid.dart';

class ManageStationsScreen extends StatefulWidget {
  const ManageStationsScreen({super.key});

  @override
  State<ManageStationsScreen> createState() => _ManageStationsScreenState();
}

class _ManageStationsScreenState extends State<ManageStationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  List<Station> _stations = [];
  List<User> _officers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stations = await _firebaseService.getStations();
      final users = await _firebaseService.getUsers();
      final officers = users.where((user) => user.isOfficer).toList();

      setState(() {
        _stations = stations;
        _officers = officers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  String? _getAssignedOfficerName(String? officerId) {
    if (officerId == null) return null;
    final officer = _officers.firstWhere(
      (o) => o.id == officerId,
      orElse: () =>
          User(id: '', email: '', name: 'Unknown Officer', role: 'officer'),
    );
    return officer.name != 'Unknown Officer' ? officer.name : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polling Stations"),
        actions: [
          IconButton(
            tooltip: 'Officers',
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOfficersScreen()),
              );
              _loadData(); // Refresh data when returning
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:
            AppColors.primary, // Fixed: Changed from faded color to primary
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add),
        label: const Text("Add Station"),
        onPressed: () => _showAddStationDialog(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _stations.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _stations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, index) =>
                          _buildStationCard(_stations[index]),
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Stations Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first polling station to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStationDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Station'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(Station station) {
    final assignedOfficerName = _getAssignedOfficerName(
      station.assignedOfficerId,
    );

    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.location_city, color: Colors.white),
        ),
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${station.city} • ${station.constituency}'),
            const SizedBox(height: 2),
            Text(
              assignedOfficerName == null
                  ? "Officer: Not Assigned"
                  : "Officer: $assignedOfficerName",
              style: TextStyle(
                color: assignedOfficerName == null
                    ? AppColors.accent
                    : AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onSelected: (value) => _handleMenuAction(value, station),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _handleMenuAction('view', station),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, Station station) async {
    switch (action) {
      case 'view':
        await _navigateToStationDetail(station);
        break;
      case 'edit':
        await _showEditStationDialog(station);
        break;
      case 'delete':
        await _confirmDeleteStation(station);
        break;
    }
  }

  Future<void> _navigateToStationDetail(Station station) async {
    final officerNames = _officers.map((o) => o.name).toList();
    final assignedOfficer = _getAssignedOfficerName(station.assignedOfficerId);

    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => StationDetailScreen(
          station: station,
          assignedOfficer: assignedOfficer,
          officers: officerNames,
        ),
      ),
    );

    if (result != null) {
      final selectedOfficer = _officers.firstWhere(
        (o) => o.name == result,
        orElse: () => User(id: '', email: '', name: '', role: 'officer'),
      );

      if (selectedOfficer.id.isNotEmpty) {
        await _assignOfficerToStation(selectedOfficer.id, station.id);
      }
    }
  }

  Future<void> _assignOfficerToStation(
    String officerId,
    String stationId,
  ) async {
    try {
      await _firebaseService.assignOfficerToStation(officerId, stationId);
      await _loadData(); // Refresh data

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Officer assigned successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error assigning officer: $e')));
    }
  }

  void _showAddStationDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final constituencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add New Polling Station",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Station Name *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Station name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "City *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: constituencyController,
                    decoration: const InputDecoration(
                      labelText: "Constituency *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Constituency is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createStation(
              context,
              formKey,
              nameController,
              cityController,
              constituencyController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Station'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditStationDialog(Station station) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: station.name);
    final cityController = TextEditingController(text: station.city);
    final constituencyController = TextEditingController(
      text: station.constituency,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit Station",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Station Name *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Station name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "City *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: constituencyController,
                    decoration: const InputDecoration(
                      labelText: "Constituency *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Constituency is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateStation(
              context,
              formKey,
              station,
              nameController,
              cityController,
              constituencyController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Station'),
          ),
        ],
      ),
    );
  }

  Future<void> _createStation(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController cityController,
    TextEditingController constituencyController,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final station = Station(
      id: _uuid.v4(),
      name: nameController.text.trim(),
      city: cityController.text.trim(),
      constituency: constituencyController.text.trim(),
    );

    try {
      await _firebaseService.addStation(station);
      await _loadData(); // Refresh data

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating station: $e')));
    }
  }

  Future<void> _updateStation(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Station originalStation,
    TextEditingController nameController,
    TextEditingController cityController,
    TextEditingController constituencyController,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final updatedStation = originalStation.copyWith(
      name: nameController.text.trim(),
      city: cityController.text.trim(),
      constituency: constituencyController.text.trim(),
    );

    try {
      await _firebaseService.updateStation(updatedStation);
      await _loadData(); // Refresh data

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating station: $e')));
    }
  }

  Future<void> _confirmDeleteStation(Station station) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${station.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This will also:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text('• Remove any officer assignments'),
            const Text('• This action cannot be undone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteStation(station.id);
        await _loadData(); // Refresh data

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Station deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting station: $e')));
      }
    }
  }
}
