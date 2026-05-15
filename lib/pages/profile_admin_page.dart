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
      child: const Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 60),
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
          )
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [

        _sectionTitle("Manajemen Konten"),

        _menuItem(
          Icons.category,
          "Kelola Kategori",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const KategoriPage(),
              ),
            );
          },
        ),

        _menuItem(
          Icons.inventory,
          "Kelola Paket",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProdukPage(),
              ),
            );
          },
        ),

        const Divider(),

        _sectionTitle("Administrasi"),

        _menuItem(
          Icons.people,
          "Data User",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserPage(),
              ),
            );
          },
        ),

        _menuItem(
          Icons.receipt_long,
          "Data Transaksi",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransaksiPage(),
              ),
            );
          },
        ),

        _menuItem(
          Icons.person,
          "Profil Saya",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DetailProfilePage(),
              ),
            );
          },
        ),

        const Divider(),

        _sectionTitle("Sistem"),

        _menuItem(
          Icons.settings,
          "Pengaturan",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PengaturanPage(),
              ),
            );
          },
        ),

        _menuItem(
          Icons.logout,
          "Keluar",
          () {
            _logout(context);
          },
          isLogout: true,
        ),

        const SizedBox(height: 20)
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [

            Icon(
              icon,
              color: isLogout
                  ? Colors.red
                  : Colors.deepOrange,
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 15,
            )
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Yakin ingin keluar?"
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                        Text("Logout berhasil"),
                  ),
                );
              },
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
}


// HALAMAN KATEGORI
class KategoriPage extends StatelessWidget {
  const KategoriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kategori"),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.forest),
            title: Text("Wisata Alam"),
            subtitle: Text("Kebun Raya Liwa"),
          ),

          ListTile(
            leading: Icon(Icons.beach_access),
            title: Text("Wisata Pantai"),
            subtitle: Text("Pantai Pahawang"),
          ),

        ],
      ),
    );
  }
}


// HALAMAN PRODUK
class ProdukPage extends StatelessWidget {
  const ProdukPage({super.key});

  @override
  Widget build(BuildContext context) {

    List data=[
      "Kebun Raya Liwa",
      "Lembah Hijau",
      "Pantai Pahawang"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paket Wisata",
        ),
        backgroundColor:
            Colors.deepOrange,
      ),

      body: ListView.builder(
        itemCount: data.length,
        itemBuilder:(c,i){

          return ListTile(
            leading: const Icon(
              Icons.place
            ),
            title: Text(data[i]),
          );

        },
      ),
    );
  }
}


// USER
class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Data User"),
      ),

      body: ListView(
        children: const [

          ListTile(
            leading: CircleAvatar(
              child: Text("B"),
            ),
            title: Text(
              "Budi"
            ),
          ),

          ListTile(
            leading: CircleAvatar(
              child: Text("S"),
            ),
            title: Text(
              "Siti"
            ),
          ),

        ],
      ),
    );
  }
}


// TRANSAKSI
class TransaksiPage extends StatelessWidget {
  const TransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
                "Transaksi"),
      ),

      body: ListView(
        children: const [

          ListTile(
            leading:
                Icon(Icons.receipt),
            title: Text("User A"),
            subtitle:
                Text("Selesai"),
          ),

          ListTile(
            leading:
                Icon(Icons.receipt),
            title: Text("User B"),
            subtitle:
                Text("Pending"),
          ),

        ],
      ),
    );
  }
}


// PROFIL
class DetailProfilePage
    extends StatelessWidget {
  const DetailProfilePage(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Profil"),
      ),

      body: const Center(
        child: Text(
          "Admin Wisata\nadmin@wisata.com",
          textAlign:
              TextAlign.center,
        ),
      ),
    );
  }
}


// PENGATURAN
class PengaturanPage
    extends StatelessWidget {
  const PengaturanPage(
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Pengaturan"),
        backgroundColor:
            Colors.deepOrange,
      ),

      body: ListView(
        children: const [

          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text(
                "Mode Gelap"),
          ),

          ListTile(
            leading:
                Icon(Icons.info),
            title:
                Text("Versi App"),
            subtitle:
                Text("1.0.0"),
          )
        ],
      ),
    );
  }
}