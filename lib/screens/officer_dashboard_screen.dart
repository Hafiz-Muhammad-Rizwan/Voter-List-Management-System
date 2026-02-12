import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/election_provider.dart';
import '../core/services/firebase_service.dart';
import '../models/voter.dart';
import '../models/user.dart';

class OfficerDashboardScreen extends StatefulWidget {
  final User? officer; // Optional: pass officer details if available

  const OfficerDashboardScreen({super.key, this.officer});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Voter> _voters = [];
  User? _currentOfficer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // In a real app, get the current logged-in officer's ID
      // For now, we'll use the passed officer or fetch based on station
      User? officer = widget.officer;

      // If no officer passed, try to get from provider or fetch from Firebase
      if (officer == null) {
        final provider = Provider.of<ElectionProvider>(context, listen: false);
        // Load voters for the officer's station (using provider's stationId for now)
        final voters = await _firebaseService.getVoters(
          stationId: provider.stationId,
        );
        setState(() {
          _voters = voters;
          _currentOfficer = officer;
          _isLoading = false;
        });
      } else {
        // Load voters for officer's assigned station
        final voters = await _firebaseService.getVoters(
          stationId: officer.stationId ?? '',
        );
        setState(() {
          _voters = voters;
          _currentOfficer = officer;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  int get verifiedCount => _voters.where((v) => v.hasVoted).length;
  int get pendingCount =>
      _voters.where((v) => !v.hasVoted && v.isEligible).length;

  Widget _buildCounterCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ElectionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Officer Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Section
                      const Text(
                        "Welcome, Officer",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Station: ${_currentOfficer?.stationId ?? provider.stationName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Statistics
                      const Text(
                        "Voting Statistics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCounterCard(
                              "Votes\nVerified",
                              verifiedCount,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCounterCard(
                              "Pending\nVerification",
                              pendingCount,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Progress Bar
                      const Text(
                        "Verification Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Completion Rate",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "${_voters.isEmpty ? 0 : ((verifiedCount / _voters.length) * 100).toInt()}%",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: _voters.isEmpty
                                    ? 0
                                    : verifiedCount / _voters.length,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Start Verification Button
                      SizedBox(
                        height: 64,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/voter-list');
                            // Refresh data when coming back
                            _loadData();
                          },
                          icon: const Icon(Icons.how_to_vote, size: 28),
                          label: const Text(
                            "Start Voter Verification",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
