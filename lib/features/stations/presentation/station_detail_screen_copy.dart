import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StationDetailScreen extends StatefulWidget {
  final String stationName;
  final String? assignedOfficer;
  final List<String>? officers;

  const StationDetailScreen({super.key, required this.stationName, this.assignedOfficer, this.officers});

  @override
  State<StationDetailScreen> createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationDetailScreen> {
  String? _assignedOfficer;

  @override
  void initState() {
    super.initState();
    _assignedOfficer = widget.assignedOfficer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stationName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoSection(
              title: "Assigned Officer",
              value: _assignedOfficer == null ? "Not Assigned" : _assignedOfficer!,
              borderColor: AppColors.primary,
              buttonText: "Assign / Change Officer",
              onPressed: () async {
                final selected = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignOfficerScreen(officers: widget.officers),
                  ),
                );

                if (!mounted) return;
                if (selected != null) {
                  setState(() => _assignedOfficer = selected);
                  Navigator.pop(context, selected);
                }
              },
            ),
            const SizedBox(height: 24),
            _infoSection(
              title: "Voters",
              value: "Total Voters: 500",
              borderColor: AppColors.secondary,
              buttonText: "View / Import Voters",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection({
    required String title,
    required String value,
    required Color borderColor,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: borderColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class AssignOfficerScreen extends StatelessWidget {
  final List<String>? officers;

  const AssignOfficerScreen({super.key, this.officers});

  @override
  Widget build(BuildContext context) {
    final list = officers ?? ["ABUBAKAR", "MUBASHRA", "RIZWAN"];

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Officer')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) {
          final name = list[index];
          return ListTile(
            leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
            title: Text(name),
            onTap: () => Navigator.pop(context, name),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: list.length,
      ),
    );
  }
}
