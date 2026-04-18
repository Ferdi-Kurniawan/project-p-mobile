import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isAdmin = false; // false = user, true = admin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Profile Admin" : "Profile Pengguna"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                isAdmin = !isAdmin;
              });
            },
          )
        ],
      ),
      body: isAdmin ? _buildAdminProfile() : _buildUserProfile(),
    );
  }

  // ================= ADMIN =================
  Widget _buildAdminProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),

          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/admin.jpg'),
          ),

          const SizedBox(height: 15),

          const Text(
            "Admin Wisata",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const Text("admin@wisata.com", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 25),

          _buildMenuCard(
            Icons.add_location_alt,
            "Tambah Desa Wisata",
          ),
          _buildMenuCard(
            Icons.edit_location,
            "Edit Data Desa",
          ),
          _buildMenuCard(
            Icons.delete,
            "Hapus Data Desa",
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= USER =================
  Widget _buildUserProfile() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),

          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/user.jpg'),
          ),

          const SizedBox(height: 15),

          const Text(
            "Pengguna",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const Text("user@gmail.com", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 25),

          _buildMenuCard(
            Icons.favorite,
            "Wisata Favorit",
          ),
          _buildMenuCard(
            Icons.history,
            "Riwayat Tiket",
          ),
          _buildMenuCard(
            Icons.logout,
            "Logout",
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ================= COMPONENT =================
  Widget _buildMenuCard(IconData icon, String title) {
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