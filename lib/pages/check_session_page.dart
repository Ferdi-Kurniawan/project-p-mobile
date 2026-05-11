import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/pages/profile.dart';
import 'package:flutter_application_2/pages/profile_admin_page.dart';


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
  String? role = prefs.getString('role'); // Ambil role dari disk

  if (role == 'ADMIN') {
    // Jika admin, lempar ke halaman admin saja
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileAdminPage()),
    );
  } else if (role == 'USER') {
    // Jika user, lempar ke halaman profil biasa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  } else {
    // Jika tidak ada session, kembali ke login
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