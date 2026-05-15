import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman user dan admin kamu
import '../pages/profile.dart';
import '../pages/profile_admin_page.dart';

class ProfileSwitcher extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileSwitcher({super.key, required this.userData});

  @override
  State<ProfileSwitcher> createState() => _ProfileSwitcherState();
}

class _ProfileSwitcherState extends State<ProfileSwitcher> {
  String _role = 'user';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil role dari session, ubah ke huruf kecil semua agar aman
      _role =
          prefs.getString('role')?.toLowerCase() ??
          widget.userData['role']?.toString().toLowerCase() ??
          'user';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Jika role adalah admin, tampilkan halaman khusus Admin
    if (_role == 'admin' || _role == 'superadmin') {
      return const ProfileAdminPage();
    }
    // Jika bukan admin, tampilkan halaman User biasa
    else {
      return ProfilePage(userData: widget.userData);
    }
  }
}
