import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/voter.dart';
import '../models/station.dart';
import '../core/theme/app_colors.dart';

class AdminVotersScreen extends StatefulWidget {
  const AdminVotersScreen({super.key});

  @override
  State<AdminVotersScreen> createState() => _AdminVotersScreenState();
}

class _AdminVotersScreenState extends State<AdminVotersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Voter> _allVoters = [];
  List<Voter> _filteredVoters = [];
  List<Station> _stations = [];
  bool _isLoading = true;
  String? _selectedStationFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterVoters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _firebaseService.getVoters(),
        _firebaseService.getStations(),
      ]);

      setState(() {
        _allVoters = results[0] as List<Voter>;
        _stations = results[1] as List<Station>;
        _filteredVoters = _allVoters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading voters: $e')));
    }
  }

  void _filterVoters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVoters = _allVoters.where((voter) {
        final matchesSearch =
            voter.name.toLowerCase().contains(query) ||
            voter.cnic.contains(query) ||
            voter.fatherName.toLowerCase().contains(query);

        final matchesStation =
            _selectedStationFilter == null ||
            voter.stationId == _selectedStationFilter;

        return matchesSearch && matchesStation;
      }).toList();
    });
  }

  String _getStationName(String stationId) {
    try {
      final station = _stations.firstWhere((s) => s.id == stationId);
      return station.name;
    } catch (e) {
      return 'Unknown Station';
    }
  }

  Future<void> _confirmDeleteVoter(Voter voter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Voter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this voter?'),
            const SizedBox(height: 16),
            Text(
              'Name: ${voter.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('CNIC: ${voter.cnic}'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteVoter(voter);
    }
  }

  Future<void> _deleteVoter(Voter voter) async {
    try {
      await _firebaseService.deleteVoter(voter.id);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voter deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting voter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVoterDetails(Voter voter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voter Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', voter.name),
              const Divider(),
              _buildDetailRow('Father\'s Name', voter.fatherName),
              const Divider(),
              _buildDetailRow('CNIC', voter.cnic),
              const Divider(),
              _buildDetailRow('Address', voter.address),
              const Divider(),
              _buildDetailRow('Station', _getStationName(voter.stationId)),
              const Divider(),
              _buildDetailRow(
                'Eligibility',
                voter.isEligible ? 'Eligible' : 'Not Eligible',
              ),
              const Divider(),
              _buildDetailRow('Status', voter.hasVoted ? 'VOTED' : 'NOT VOTED'),
              if (voter.hasVoted && voter.votedAt != null) ...[
                const Divider(),
                _buildDetailRow(
                  'Voted At',
                  '${voter.votedAt!.day}/${voter.votedAt!.month}/${voter.votedAt!.year} '
                      '${voter.votedAt!.hour.toString().padLeft(2, '0')}:'
                      '${voter.votedAt!.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildVoterCard(Voter voter) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: voter.hasVoted ? Colors.red[300]! : Colors.green[300]!,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.grey[100],
            backgroundImage: voter.photoUrl != null
                ? NetworkImage(voter.photoUrl!)
                : null,
            child: voter.photoUrl == null
                ? const Icon(Icons.person, color: Colors.black54, size: 24)
                : null,
          ),
        ),
        title: Text(
          voter.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "CNIC: ${voter.cnic}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Station: ${_getStationName(voter.stationId)}",
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: voter.hasVoted ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: voter.hasVoted ? Colors.red[300]! : Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                voter.hasVoted ? "VOTED" : "PENDING",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: voter.hasVoted ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _showVoterDetails(voter);
                } else if (value == 'delete') {
                  _confirmDeleteVoter(voter);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
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
    final votedCount = _allVoters.where((v) => v.hasVoted).length;
    final pendingCount = _allVoters.length - votedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Database'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Stats Banner
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', _allVoters.length, Colors.blue),
                Container(height: 30, width: 1, color: Colors.grey[400]),
                _buildStatItem('Voted', votedCount, Colors.red),
                Container(height: 30, width: 1, color: Colors.grey[400]),
                _buildStatItem('Pending', pendingCount, Colors.green),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, CNIC, or father name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                // Station Filter
                DropdownButtonFormField<String?>(
                  value: _selectedStationFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter by Station',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Stations'),
                    ),
                    ..._stations.map((station) {
                      return DropdownMenuItem(
                        value: station.id,
                        child: Text(station.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStationFilter = value;
                      _filterVoters();
                    });
                  },
                ),
              ],
            ),
          ),

          // Voters List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVoters.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      itemCount: _filteredVoters.length,
                      itemBuilder: (_, index) =>
                          _buildVoterCard(_filteredVoters[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            _searchController.text.isNotEmpty
                ? 'No voters found'
                : 'No voters in database',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try different search terms'
                : 'Voters are added through station management',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
