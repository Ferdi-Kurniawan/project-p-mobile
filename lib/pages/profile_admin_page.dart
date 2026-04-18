import 'package:flutter/material.dart';

class ProfileAdminPage extends StatelessWidget {
  const ProfileAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMenu(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/admin.jpg'),
          ),
          SizedBox(height: 10),
          Text(
            "Admin Wisata",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "admin@wisata.com",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= MENU =================
  Widget _buildMenu() {
    return Column(
      children: [
        _menuItem(Icons.add_location_alt, "Tambah Desa Wisata"),
        _menuItem(Icons.edit, "Edit Data Desa"),
        _menuItem(Icons.delete, "Hapus Desa"),
        _menuItem(Icons.list, "Daftar Semua Desa"),
        _menuItem(Icons.confirmation_number, "Kelola Tiket"),
        _menuItem(Icons.bar_chart, "Laporan Pengunjung"),
        _menuItem(Icons.settings, "Pengaturan"),
        _menuItem(Icons.logout, "Logout"),
        
      ],
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16)
        ],
      ),
    );
  }
}