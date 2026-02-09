import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/officers_repository.dart';
import 'create_officer_screen.dart';

class ManageOfficersScreen extends StatefulWidget {
  const ManageOfficersScreen({super.key});

  @override
  State<ManageOfficersScreen> createState() => _ManageOfficersScreenState();
}

class _ManageOfficersScreenState extends State<ManageOfficersScreen> {
  List<String> get _officers => OfficersRepository.instance.names;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Officers")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add),
        label: const Text("Create Officer", style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final result = await Navigator.push<String?>(
            context,
            MaterialPageRoute(builder: (_) => const CreateOfficerScreen()),
          );

          if (result != null && result.isNotEmpty) {
            // creation already added in CreateOfficerScreen, just refresh
            setState(() {});
          }
        },
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _officers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final name = _officers[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(name),
              subtitle: Text(OfficersRepository.instance.officers.firstWhere((o) => o.name == name).email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, name),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String name) async {
    final del = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Officer'),
        content: Text('Delete $name? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (del == true) {
      OfficersRepository.instance.removeByName(name);
      setState(() {});
    }
  }
}
