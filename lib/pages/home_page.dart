import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tiket_page.dart';
import 'detail_wisata.dart';
import 'profile.dart';
import 'profile_admin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int _currentIndex = 0;
  String role = "";

  final List<Map<String, String>> _villages = [
    {
      'name': 'Lembah Hijau',
      'loc': 'Bandar Lampung',
      'img': 'assets/images/lembahhijau.jpeg',
      'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
      'harga': 'Rp 25.000',
      'gallery':
          'assets/images/lembahhijau1.jpg,assets/images/lembahhijau2.jpg,assets/images/lembahhijau3.jpg',
    },
    {
      'name': 'Kebun Liwa',
      'loc': 'Lampung Barat',
      'img': 'assets/images/kebunliwa.jpeg',
      'deskripsi': 'Wisata kebun dengan udara sejuk.',
      'harga': 'Rp 20.000',
      'gallery':
          'assets/images/lembahhijau1.jpg,assets/images/lembahhijau2.jpg,assets/images/lembahhihau3.jpg',
    },
    {
      'name': 'Pulau Pahawang',
      'loc': 'Pesawaran',
      'img': 'assets/images/pahawang1.jpg',
      'deskripsi': 'Surga snorkeling di Lampung.',
      'harga': 'Rp 30.000',
      'gallery':
          'assets/images/lh1.jpg,assets/images/lh2.jpg,assets/images/lh3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    loadRole();
  }

  void loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= PAGE SWITCH =================
  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return _buildMainHomeContent();
      case 1:
        return const TiketPage();
      case 2:
        return const Center(child: Text("Halaman Favorit"));
      case 3:
        return role == 'admin'
            ? const ProfileAdminPage()
            : const ProfilePage();
      default:
        return _buildMainHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _getPage(),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Tiket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorit",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // ================= HOME CONTENT =================

  Widget _buildMainHomeContent() {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.shade800,
                Colors.orange.shade400
              ],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, Penjelajah!",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "Mau ke mana hari ini?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari tempat wisata...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Rekomendasi Wisata",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      ..._villages.map((village) {
                        return Card(
                          margin:
                              const EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            leading: Image.asset(
                              village['img']!,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(village['name']!),
                            subtitle: Text(village['loc']!),
                            trailing:
                                const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailWisataPage(
                                    data: village,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}