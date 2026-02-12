import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/voter_import_service.dart';
import '../../../models/voter.dart';
import '../../../models/station.dart';
import '../../../screens/voter_detail_screen.dart';

class StationVotersScreen extends StatefulWidget {
  final Station station;

  const StationVotersScreen({super.key, required this.station});

  @override
  State<StationVotersScreen> createState() => _StationVotersScreenState();
}

class _StationVotersScreenState extends State<StationVotersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final VoterImportService _importService = VoterImportService();
  final TextEditingController _searchController = TextEditingController();

  List<Voter> _allVoters = [];
  List<Voter> _filteredVoters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVoters();
    _searchController.addListener(_filterVoters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVoters() async {
    setState(() => _isLoading = true);
    try {
      // Load voters only for this station
      final voters = await _firebaseService.getVoters(
        stationId: widget.station.id,
      );
      setState(() {
        _allVoters = voters;
        _filteredVoters = voters;
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
      _filteredVoters = _allVoters
          .where(
            (voter) =>
                voter.name.toLowerCase().contains(query) ||
                voter.cnic.contains(query) ||
                voter.fatherName.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  Future<void> _showImportDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Voters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import voters for: ${widget.station.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text('This will import voters from a CSV or JSON file.'),
            const SizedBox(height: 8),
            const Text(
              'CSV Format:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'CNIC, Name, Father_Name, Address, Is_Eligible',
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _importVoters();
            },
            icon: const Icon(Icons.file_upload),
            label: const Text('Select File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importVoters() async {
    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Import voters with station ID
      final result = await _importService.importVotersFromFile(
        stationId: widget.station.id,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (result.success) {
        await _loadVoters(); // Reload voters
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Template'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CSV File Format:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'CNIC, Name, Father_Name, Address, Is_Eligible',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text(
                '3520212345678, Ahmed Raza, Raza Ali, House 10 Street 5, true',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
              const SizedBox(height: 8),
              const Text(
                '3520298765432, Sara Khan, Khan Ahmed, House 15 Street 2, true',
                style: TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• CNIC must be 13 digits'),
              const Text(
                '• Is_Eligible: true or false (optional, defaults to true)',
              ),
              Text(
                '• Station will be automatically set to: ${widget.station.name}',
              ),
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

  Widget _buildVoterCard(Voter voter) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: voter.hasVoted ? Colors.red[300]! : Colors.green[300]!,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey[100],
            backgroundImage: voter.photoUrl != null
                ? NetworkImage(voter.photoUrl!)
                : null,
            child: voter.photoUrl == null
                ? const Icon(Icons.person, color: Colors.black54)
                : null,
          ),
        ),
        title: Text(
          voter.name,
          style: const TextStyle(
            fontSize: 16,
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
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Father: ${voter.fatherName}",
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
            if (!voter.isEligible) ...[
              const SizedBox(height: 4),
              const Text(
                "NOT ELIGIBLE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: voter.hasVoted ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: voter.hasVoted ? Colors.red[300]! : Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Text(
                voter.hasVoted ? "VOTED" : "PENDING",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: voter.hasVoted ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VoterDetailScreen(voter: voter)),
          );
          // Refresh if voter was marked as voted
          if (result == true) {
            await _loadVoters();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final votedCount = _allVoters.where((v) => v.hasVoted).length;
    final pendingCount = _allVoters.length - votedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.station.name} - Voters'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'CSV Template',
            onPressed: _showTemplateDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImportDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.file_upload),
        label: const Text('Import Voters'),
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  _allVoters.length.toString(),
                  Colors.blue,
                ),
                _buildStatItem('Voted', votedCount.toString(), Colors.red),
                _buildStatItem(
                  'Pending',
                  pendingCount.toString(),
                  Colors.green,
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
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
          ),

          // Voters List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVoters.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadVoters,
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
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
                : 'No voters in this station',
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
                : 'Import voters using the button below',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
