import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/election_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/officer_dashboard_screen.dart';
import 'screens/voter_list_screen.dart';
import 'screens/voter_detail_screen.dart';
import 'screens/admin_voters_screen.dart';
import 'features/stations/presentation/manage_stations_screen.dart';
import 'features/officers/presentation/manage_officers_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VoterManagementApp());
}

class VoterManagementApp extends StatelessWidget {
  const VoterManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ElectionProvider()..loadMockData(),
        ),
      ],
      child: MaterialApp(
        title: 'Voter Management System',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),

        // Define all routes for proper navigation
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/officer-dashboard': (context) => const OfficerDashboardScreen(),
          '/voter-list': (context) => const VoterListScreen(),
          '/admin-voters': (context) => const AdminVotersScreen(),
          '/manage-stations': (context) => const ManageStationsScreen(),
          '/manage-officers': (context) => const ManageOfficersScreen(),
        },

        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name?.startsWith('/voter-detail/') == true) {
            final voterId = settings.name?.split('/')[2];
            if (voterId != null) {
              return MaterialPageRoute(
                builder: (context) => Consumer<ElectionProvider>(
                  builder: (context, provider, child) {
                    final voter = provider.voters.firstWhere(
                      (v) => v.id == voterId,
                      orElse: () => throw Exception('Voter not found'),
                    );
                    return VoterDetailScreen(voter: voter);
                  },
                ),
                settings: settings,
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
