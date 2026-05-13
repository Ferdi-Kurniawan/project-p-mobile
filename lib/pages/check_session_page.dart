import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/pages/profile.dart';
import 'package:flutter_application_2/pages/profile_admin_page.dart';
import 'package:flutter_application_2/pages/home_page.dart';

class CheckSessionPage extends StatefulWidget {
  const CheckSessionPage({super.key});

  @override
  State<CheckSessionPage> createState() => _CheckSessionPageState();
}

class _CheckSessionPageState extends State<CheckSessionPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    String fullname = prefs.getString('fullname') ?? '';
    String email = prefs.getString('email') ?? '';

    if (role == 'ADMIN') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileAdminPage()),
      );
    } else if (role == 'USER') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userData: {
              'fullname': fullname,
              'email': email,
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}