import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StationDetailScreen extends StatelessWidget {
  final String stationName;

  const StationDetailScreen({super.key, required this.stationName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stationName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoSection(
              title: "Assigned Officer",
              value: "Not Assigned",
              borderColor: AppColors.primary,
              buttonText: "Assign / Change Officer",
            ),
            const SizedBox(height: 24),
            _infoSection(
              title: "Voters",
              value: "Total Voters: 500",
              borderColor: AppColors.secondary,
              buttonText: "View / Import Voters",
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
              onPressed: () {},
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
