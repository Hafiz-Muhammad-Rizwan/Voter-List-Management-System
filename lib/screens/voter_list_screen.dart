// lib/screens/voter_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/election_provider.dart';
import '../models/voter.dart';
import 'voter_detail_screen.dart';

class VoterListScreen extends StatelessWidget {
  const VoterListScreen({super.key});

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VoterDetailScreen(voter: voter)),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    ElectionProvider provider,
  ) {
    final isSelected = provider.filter == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) provider.setFilter(label);
      },
      selectedColor: Colors.black,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ElectionProvider>(
      builder: (context, provider, child) {
        final voters = provider.filteredVoters;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Voter List'),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Search Section
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by CNIC or Name...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
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
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: provider.setSearchQuery,
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, "All", provider),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, "Voted", provider),
                          const SizedBox(width: 8),
                          _buildFilterChip(context, "Not Voted", provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          voters.length.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        Text(
                          provider.verifiedCount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Verified",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        Text(
                          provider.pendingCount.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Pending",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Voter List
              Expanded(
                child: voters.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.black26,
                            ),
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
                              "Try adjusting your search or filter",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: voters.length,
                        itemBuilder: (context, index) {
                          return _buildVoterCard(voters[index], context);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
