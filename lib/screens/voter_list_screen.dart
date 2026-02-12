// lib/screens/voter_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/election_provider.dart';
import '../models/voter.dart';
import '../core/services/firebase_service.dart';
import 'voter_detail_screen.dart';

class VoterListScreen extends StatefulWidget {
  const VoterListScreen({super.key});

  @override
  State<VoterListScreen> createState() => _VoterListScreenState();
}

class _VoterListScreenState extends State<VoterListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
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
      final voters = await _firebaseService.getVoters();
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

  Widget _buildVoterCard(Voter voter, BuildContext context) {
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Database'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Info Banner
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'View-only database. Import voters through Station Management.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search Section
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by CNIC, Name, or Father Name...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Statistics Bar
          if (_allVoters.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn("Total", _filteredVoters.length.toString()),
                  Container(height: 30, width: 1, color: Colors.white30),
                  _buildStatColumn(
                    "Voted",
                    _filteredVoters.where((v) => v.hasVoted).length.toString(),
                  ),
                  Container(height: 30, width: 1, color: Colors.white30),
                  _buildStatColumn(
                    "Pending",
                    _filteredVoters.where((v) => !v.hasVoted).length.toString(),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadVoters,
                    child: _allVoters.isEmpty
                        ? _buildEmptyState()
                        : _filteredVoters.isEmpty
                        ? _buildNoResultsState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredVoters.length,
                            itemBuilder: (context, index) {
                              return _buildVoterCard(
                                _filteredVoters[index],
                                context,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 120, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Voters Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import voters through Station Management',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Go to Stations → Select Station → Import Voters',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            "No voters found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try adjusting your search terms",
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
