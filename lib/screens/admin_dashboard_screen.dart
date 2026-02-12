import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/station.dart';
import '../models/user.dart';
import '../models/voter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  int _totalStations = 0;
  int _activeOfficers = 0;
  int _totalVoters = 0;
  int _votesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _firebaseService.getStations(),
        _firebaseService.getUsers(),
        _firebaseService.getVoters(),
      ]);

      final stations = results[0] as List<Station>;
      final users = results[1] as List<User>;
      final voters = results[2] as List<Voter>;

      final officers = users.where((user) => user.isOfficer).toList();
      final votedCount = voters.where((voter) => voter.hasVoted).length;

      setState(() {
        _totalStations = stations.length;
        _activeOfficers = officers.length;
        _totalVoters = voters.length;
        _votesCount = votedCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading statistics: $e')));
    }
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: color),
                Flexible(
                  child: Text(
                    count,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.black54,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Statistics',
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
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Text(
                "Welcome, Admin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage your electoral system efficiently",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              const Text(
                "Overview",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? _buildLoadingCards()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Use GridView for better responsive design
                        double cardWidth = (constraints.maxWidth - 12) / 2;
                        bool useGrid = cardWidth > 140; // Minimum card width

                        if (useGrid) {
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              _buildStatCard(
                                "Total Stations",
                                _totalStations.toString(),
                                Icons.location_city,
                                Colors.blue,
                              ),
                              _buildStatCard(
                                "Active Officers",
                                _activeOfficers.toString(),
                                Icons.badge,
                                Colors.green,
                              ),
                              _buildStatCard(
                                "Total Voters",
                                _formatNumber(_totalVoters),
                                Icons.people,
                                Colors.purple,
                              ),
                              _buildStatCard(
                                "Votes Cast",
                                _formatNumber(_votesCount),
                                Icons.how_to_vote,
                                Colors.orange,
                              ),
                            ],
                          );
                        } else {
                          // Fallback to column layout for very small screens
                          return Column(
                            children: [
                              _buildStatCard(
                                "Total Stations",
                                _totalStations.toString(),
                                Icons.location_city,
                                Colors.blue,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                "Active Officers",
                                _activeOfficers.toString(),
                                Icons.badge,
                                Colors.green,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                "Total Voters",
                                _formatNumber(_totalVoters),
                                Icons.people,
                                Colors.purple,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                "Votes Cast",
                                _formatNumber(_votesCount),
                                Icons.how_to_vote,
                                Colors.orange,
                              ),
                            ],
                          );
                        }
                      },
                    ),
              const SizedBox(height: 32),

              // Management Actions
              const Text(
                "Management",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                "Manage Stations",
                "Add, edit, and assign polling stations",
                Icons.location_city,
                () => Navigator.pushNamed(context, '/manage-stations'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                "Manage Officers",
                "Add, edit, and assign election officers",
                Icons.badge,
                () => Navigator.pushNamed(context, '/manage-officers'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                "Voter Database",
                "View, search, and manage voter information",
                Icons.people,
                () => Navigator.pushNamed(context, '/admin-voters').then(
                  (_) => _loadStatistics(),
                ), // Refresh stats when returning
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                "Election Reports",
                "Generate and view election reports",
                Icons.analytics,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Reports feature coming soon"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: List.generate(
        4,
        (index) => Card(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
