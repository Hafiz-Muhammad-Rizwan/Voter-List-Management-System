import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      bool isLoggedIn = false; 
      String role = "admin";
      // ignore: dead_code
      if (isLoggedIn) {
        if (role == "admin") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.how_to_vote, size: 80, color: Color(0xFF1E3A8A)),
            SizedBox(height: 16),
            Text(
              "Voter Admin System",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
