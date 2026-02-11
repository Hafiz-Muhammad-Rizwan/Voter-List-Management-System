import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
      body: SingleChildScrollView(
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
            LayoutBuilder(
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
                        "120",
                        Icons.location_city,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        "Active Officers",
                        "45",
                        Icons.badge,
                        Colors.green,
                      ),
                      _buildStatCard(
                        "Total Voters",
                        "12,430",
                        Icons.people,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        "Votes Cast",
                        "8,245",
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
                        "120",
                        Icons.location_city,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        "Active Officers",
                        "45",
                        Icons.badge,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        "Total Voters",
                        "12,430",
                        Icons.people,
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        "Votes Cast",
                        "8,245",
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
              "View and manage voter information",
              Icons.people,
              () => Navigator.pushNamed(context, '/voter-list'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              "Election Reports",
              "Generate and view election reports",
              Icons.analytics,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reports feature coming soon")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
