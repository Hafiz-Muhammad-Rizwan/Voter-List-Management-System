import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:polling_app/features/officers/presentation/manage_officers_screen.dart';
import '../../../core/data/officers_repository.dart';
import 'station_detail_screen_copy.dart';

class ManageStationsScreen extends StatefulWidget {
  const ManageStationsScreen({super.key});

  @override
  State<ManageStationsScreen> createState() => _ManageStationsScreenState();
}

class _ManageStationsScreenState extends State<ManageStationsScreen> {
  final List<String> _stations = [
    "toba GOVT 11",
    "Govt School",
    "Community Center",
  ];

  final Map<String, String?> _assignments = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polling Stations"),
        actions: [
          IconButton(
            tooltip: 'Officers',
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOfficersScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 183, 192, 201),
        icon: const Icon(Icons.add),
        label: const Text("Add Station"),
        onPressed: () => _showAddStation(context),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, index) {
          final station = _stations[index];
          final assigned = _assignments[station];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.location_city, color: Colors.white),
              ),
              title: Text(
                station,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                assigned == null
                    ? "Officer: Not Assigned"
                    : "Officer: $assigned",
                style: TextStyle(
                  color: assigned == null
                      ? AppColors.accent
                      : AppColors.secondary,
                ),
              ),

            
              trailing: PopupMenuButton<String>(
                 icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                onSelected: (value) async {
                  if (value == 'view') {
                    final result = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StationDetailScreen(
                          stationName: station,
                          assignedOfficer: assigned,
                          officers: OfficersRepository.instance.names,
                        ),
                      ),
                    );

                    if (result != null) {
                      if (!mounted) return;
                      // conflict check same as tap handler
                      final existing = _assignments.entries.firstWhere(
                        (e) => e.value == result,
                        orElse: () => MapEntry('', null),
                      );

                      if (existing.value != null && existing.key != station) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Officer already assigned'),
                            content: Text('$result is currently assigned to ${existing.key}. Reassign to $station?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            _assignments.remove(existing.key);
                            _assignments[station] = result;
                          });
                        }
                      } else {
                        setState(() {
                          _assignments[station] = result;
                        });
                      }
                    }
                  } else if (value == 'delete') {
                    _confirmDeleteStation(context, station);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: Text('View'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),

              onTap: () async {
                final result = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(
                        builder: (_) => StationDetailScreen(
                          stationName: station,
                          assignedOfficer: assigned,
                          officers: OfficersRepository.instance.names,
                        ),
                  ),
                );

                        if (result != null) {
                          // Check if the selected officer is already assigned to another station
                          final existing = _assignments.entries.firstWhere(
                            (e) => e.value == result,
                            orElse: () => MapEntry('', null),
                          );

                          if (existing.value != null && existing.key != station) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Officer already assigned'),
                                content: Text('$result is currently assigned to ${existing.key}. Reassign to $station?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              setState(() {
                                _assignments.remove(existing.key);
                                _assignments[station] = result;
                              });
                            }
                          } else {
                            setState(() {
                              _assignments[station] = result;
                            });
                          }
                        }
              },
            ),
          );
        },
      ),
    );
  }

  

  void _showAddStation(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Polling Station",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Station Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      _stations.add(name);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Create Station",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  void _confirmDeleteStation(BuildContext context, String station) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Station'),
        content: Text('Delete "$station"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _stations.remove(station);
        _assignments.remove(station);
      });
    }
  }
}
