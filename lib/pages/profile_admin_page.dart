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
            const SizedBox(height: 20), // Padding bawah agar tidak terlalu mepet
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
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            "Admin Wisata",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
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

  // ================= MENU UTAMA =================
  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        // SEKSI: MANAJEMEN DATA
        _sectionTitle("Manajemen Konten"),
        _menuItem(Icons.category, "Kelola Kategori", () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const KategoriPage()));
        }),
        _menuItem(Icons.inventory, "Kelola Produk / Paket", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProdukPage()));
        }),
        
        const Divider(height: 30, indent: 20, endIndent: 20),
        
        // SEKSI: DATA PENGGUNA & TRANSAKSI
        _sectionTitle("Administrasi"),
        _menuItem(Icons.people, "Data User", () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
        }),
        _menuItem(Icons.receipt_long, "Data Transaksi", () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TransaksiPage()));
        }),
        _menuItem(Icons.account_circle, "Data Profile Saya", () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailProfilePage()));
        }),

        const Divider(height: 30, indent: 20, endIndent: 20),

        // SEKSI: SISTEM
        _sectionTitle("Sistem"),
        _menuItem(Icons.settings, "Pengaturan App", () {}),
        _menuItem(Icons.logout, "Keluar", () {}, isLogout: true),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ================= MENU ITEM COMPONENT =================
  Widget _menuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.deepOrange),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400])
          ],
        ),
      ),
    );
  }
}

// --- HALAMAN-HALAMAN BARU ---

class KategoriPage extends StatelessWidget {
  const KategoriPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> kategori = [

      {
        "nama": "Wisata Alam",
        "icon": Icons.forest,
        "wisata": [
          {
            "nama": "Kebun Raya Liwa",
            "lokasi": "Lampung Barat",
          },
        ]
      },

      {
        "nama": "Wisata Hiburan",
        "icon": Icons.park,
        "wisata": [
          {
            "nama": "Lembah Hijau",
            "lokasi": "Bandar Lampung",
          },
        ]
      },

      {
        "nama": "Wisata Pantai",
        "icon": Icons.beach_access,
        "wisata": [
          {
            "nama": "Pantai Pahawang",
            "lokasi": "Pesawaran",
          },
        ]
      },

    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Kategori"),
        backgroundColor: Colors.deepOrange,
      ),

      body: ListView.builder(
        itemCount: kategori.length,

        itemBuilder: (context, index) {

          final item = kategori[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: ExpansionTile(

              leading: Icon(
                item['icon'],
                color: Colors.deepOrange,
              ),

              title: Text(
                item['nama'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              children: [

                ...(item['wisata'] as List).map((wisata) {

                  return ListTile(

                    leading: const Icon(
                      Icons.place,
                      color: Colors.orange,
                    ),

                    title: Text(wisata['nama']),

                    subtitle: Text(wisata['lokasi']),

                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                    ),

                    onTap: () {

                      ScaffoldMessenger.of(context).showSnackBar(

                        SnackBar(
                          content: Text(
                            "Membuka ${wisata['nama']}",
                          ),
                        ),

                      );

                    },
                  );

                }).toList(),

              ],
            ),
          );
        },
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data User"), backgroundColor: Colors.deepOrange),
      body: ListView(
        children: const [
          ListTile(leading: CircleAvatar(child: Text("B")), title: Text("Budi Santoso"), subtitle: Text("Customer")),
          ListTile(leading: CircleAvatar(child: Text("S")), title: Text("Siti Aminah"), subtitle: Text("Customer")),
        ],
      ),
    );
  }
}

class DetailProfilePage extends StatelessWidget {
  const DetailProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Admin"), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50))),
            const SizedBox(height: 20),
            const Card(
              child: Column(
                children: [
                  ListTile(title: Text("Nama"), subtitle: Text("Admin Wisata")),
                  ListTile(title: Text("Email"), subtitle: Text("admin@wisata.com")),
                  ListTile(title: Text("Role"), subtitle: Text("Super Admin")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Halaman Produk & Transaksi tetap sama seperti kode Anda sebelumnya...
// Halaman Produk & Transaksi
class ProdukPage extends StatelessWidget {
  const ProdukPage({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> paketWisata = [
      {
        "nama": "Kebun Raya Liwa",
        "harga": "Rp 20.000",
      },
      {
        "nama": "Lembah Hijau",
        "harga": "Rp 25.000",
      },
      {
        "nama": "Pantai Pahawang",
        "harga": "Rp 30.000",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Paket Wisata"),
        backgroundColor: Colors.deepOrange,
      ),

      body: ListView.builder(
        itemCount: paketWisata.length,

        itemBuilder: (context, index) {

          final wisata = paketWisata[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            child: ListTile(

              leading: const Icon(
                Icons.place,
                color: Colors.deepOrange,
              ),

              title: Text(
                wisata['nama']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                wisata['harga']!,
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),

              onTap: () {

                ScaffoldMessenger.of(context).showSnackBar(

                  SnackBar(
                    content: Text(
                      "Membuka ${wisata['nama']}",
                    ),
                  ),

                );

              },
            ),
          );
        },
      ),
    );
  }
}
class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Transaksi"), backgroundColor: Colors.deepOrange),
      body: ListView(
        children: const [
          ListTile(leading: Icon(Icons.receipt), title: Text("User A"), subtitle: Text("Pesan tiket Desa A"), trailing: Text("Selesai")),
          ListTile(leading: Icon(Icons.receipt), title: Text("User B"), subtitle: Text("Pesan tiket Desa B"), trailing: Text("Pending")),
        ],
      ),
    );
  }
}