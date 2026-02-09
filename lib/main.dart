import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/stations/presentation/manage_stations_screen.dart';

void main() {
  runApp(const PollingApp());
}

class PollingApp extends StatelessWidget {
  const PollingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const ManageStationsScreen(),
    );
  }
}
