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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMenu(context),
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
            child: Icon(Icons.person, size: 50, color: Colors.white),
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
  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _menuItem(Icons.add_location_alt, "Tambah Desa Wisata", () {}),
        _menuItem(Icons.edit, "Edit Data Desa", () {}),
        _menuItem(Icons.delete, "Hapus Desa", () {}),
        _menuItem(Icons.list, "Daftar Semua Desa", () {}),

        // 🔥 SUDAH TERHUBUNG
        _menuItem(Icons.inventory, "Kelola Paket Wisata", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProdukPage()),
          );
        }),

        _menuItem(Icons.receipt_long, "Data Transaksi", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransaksiPage()),
          );
        }),

        _menuItem(Icons.confirmation_number, "Kelola Tiket", () {}),
        _menuItem(Icons.bar_chart, "Laporan Pengunjung", () {}),
        _menuItem(Icons.settings, "Pengaturan", () {}),
        _menuItem(Icons.logout, "Logout", () {}),
      ],
    );
  }

  // ================= MENU ITEM =================
  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 HALAMAN PRODUK (MANAGEMENT PRODUK)
////////////////////////////////////////////////////////////
class ProdukPage extends StatelessWidget {
  const ProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Paket Wisata"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.place),
            title: Text("Desa A - Paket Wisata"),
            subtitle: Text("Rp 50.000"),
          ),
          ListTile(
            leading: Icon(Icons.place),
            title: Text("Desa B - Paket Wisata"),
            subtitle: Text("Rp 75.000"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🔥 HALAMAN TRANSAKSI
////////////////////////////////////////////////////////////
class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Transaksi"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text("User A"),
            subtitle: Text("Pesan tiket Desa A"),
            trailing: Text("Selesai"),
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text("User B"),
            subtitle: Text("Pesan tiket Desa B"),
            trailing: Text("Pending"),
          ),
        ],
      ),
    );
  }
}