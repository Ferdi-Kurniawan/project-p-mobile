import 'package:flutter/material.dart';
import 'tiket_page.dart'; 
import 'detail_wisata.dart'; // Pastikan nama file ini benar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  // Data sudah disesuaikan dengan asset lokal dan deskripsi tambahan
  final List<Map<String, String>> _villages = [
  {
    'name': 'Lembah Hijau',
    'loc': 'Bandar Lampung',
    'img': 'assets/images/lembahhijau.jpeg',
    'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
    'harga': 'Rp 25.000',
    // --- TAMBAHKAN LIST FOTO GALERI DI SINI (Pisahkan dengan koma) ---
    'gallery': 'assets/images/lh1.jpg,assets/images/lh2.jpg,assets/images/lh3.jpg',
  },
  {
    'name': 'Lembah Hijau',
    'loc': 'Bandar Lampung',
    'img': 'assets/images/kebunliwa.jpeg',
    'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
    'harga': 'Rp 25.000',
    // --- TAMBAHKAN LIST FOTO GALERI DI SINI (Pisahkan dengan koma) ---
    'gallery': 'assets/images/lh1.jpg,assets/images/lh2.jpg,assets/images/lh3.jpg',
  },
  {
   'name': 'Lembah Hijau',
    'loc': 'Bandar Lampung',
    'img': 'assets/images/pahawang1.jpg',
    'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
    'harga': 'Rp 25.000',
    // --- TAMBAHKAN LIST FOTO GALERI DI SINI (Pisahkan dengan koma) ---
    'gallery': 'assets/images/lh1.jpg,assets/images/lh2.jpg,assets/images/lh3.jpg',
  },
];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMainHomeContent(), 
          const TiketPage(),       
          const Center(child: Text("Halaman Favorit")), 
          const Center(child: Text("Halaman Profil")),  
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainHomeContent() {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepOrange.shade800, Colors.orange.shade400],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Kategori Populer"),
                      const SizedBox(height: 15),
                      _buildCategories(),
                      const SizedBox(height: 25),
                      _buildSectionTitle("Rekomendasi Desa Wisata"),
                      const SizedBox(height: 15),
                      _buildVillageList(),
                      const SizedBox(height: 100), // Spasi agar tidak tertutup nav
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Halo, Penjelajah!", style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text("Mau ke mana hari ini?", 
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari desa wisata...",
              hintStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, 
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }

  Widget _buildCategories() {
    List<Map<String, dynamic>> cats = [
      {'icon': Icons.landscape, 'label': 'Alam'},
      {'icon': Icons.temple_hindu, 'label': 'Budaya'},
      {'icon': Icons.fastfood, 'label': 'Kuliner'},
      {'icon': Icons.hotel, 'label': 'Inap'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cats.map((c) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Icon(c['icon'], color: Colors.deepOrange),
          ),
          const SizedBox(height: 8),
          Text(c['label'], style: const TextStyle(fontSize: 12)),
        ],
      )).toList(),
    );
  }

  Widget _buildVillageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _villages.length,
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: _controller,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset( // Sudah diubah ke asset
                    _villages[index]['img']!, 
                    height: 150, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _villages[index]['name']!, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _villages[index]['loc']!, 
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailWisataPage(data: _villages[index]),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Detail"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "Tiket"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorit"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
      ],
    );
  }
}