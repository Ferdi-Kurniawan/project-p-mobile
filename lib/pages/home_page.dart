import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'tiket_page.dart';
import 'cart.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'detail_wisata.dart';
import 'profile.dart';
import 'profile_admin_page.dart';
import 'booking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int _currentIndex = 0;
  String _selectedKategori = "Semua";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String role = "";
  Map<String, dynamic> userData = {
    'fullname': 'Pengguna',
    'email': 'user@gmail.com',
  };

  final List<Map<String, String>> _villages = [
    {
      'name': 'Lembah Hijau',
      'loc': 'Bandar Lampung',
      'img': 'assets/images/lembahhijau.jpeg',
      'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
      'harga': 'Rp 25.000',
      'kategori': 'Hiburan',
      'gallery':
          'assets/images/lembahhijau1.jpg,assets/images/lembahhijau2.jpg,assets/images/lembahhijau3.jpg',
    },
    {
      'name': 'Kebun Liwa',
      'loc': 'Lampung Barat',
      'img': 'assets/images/kebunliwa.jpeg',
      'deskripsi': 'Wisata kebun dengan udara sejuk.',
      'harga': 'Rp 20.000',
      'kategori': 'Alam',
      'gallery':
          'assets/images/liwa1.jpeg,assets/images/liwa2.jpeg,assets/images/liwa3.jpeg',
    },
    {
      'name': 'Pantai Pahawang',
      'loc': 'Pesawaran',
      'img': 'assets/images/pahawang1.jpg',
      'deskripsi': 'Surga snorkeling di Lampung.',
      'harga': 'Rp 30.000',
      'kategori': 'Pantai',
      'gallery':
          'assets/images/pahawang2.jpeg,assets/images/pahawang3.jpeg,assets/images/pahawang4.jpeg',
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
    if (!mounted) return;
    setState(() {
      role = prefs.getString('role') ?? '';
      userData = ApiService.userData ?? {
        'fullname': prefs.getString('fullname') ?? 'Pengguna',
        'email': prefs.getString('email') ?? 'user@gmail.com',
      };
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, String>> _chips = [
    {'label': '🌍 Semua', 'kategori': 'Semua'},
    {'label': '🏖️ Pantai', 'kategori': 'Pantai'},
    {'label': '🌿 Alam', 'kategori': 'Alam'},
    {'label': '🎢 Hiburan', 'kategori': 'Hiburan'},
  ];

  List<Map<String, String>> get _filteredVillages {
    List<Map<String, String>> result = _villages;
    if (_selectedKategori != 'Semua') {
      result =
          result.where((v) => v['kategori'] == _selectedKategori).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((v) =>
              v['name']!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              v['loc']!
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  Widget _getPage() {
    switch (_currentIndex) {
      case 0:
        return _buildMainHomeContent();
      case 1:
        return const TiketPage();
      case 2:
        return const CartPage();
      case 3:
        return _buildBookingTab();
      case 4:
        return role.toLowerCase() == 'admin'
            ? const ProfileAdminPage()
            : ProfilePage(userData: userData);
          default:
        return _buildMainHomeContent();
    }
  }

  // ── Tab Booking: placeholder jika belum ada data booking aktif ──
  Widget _buildBookingTab() {
    final items = CartModel.instance.items;

    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: Stack(
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepOrange.shade800,
                    Colors.orange.shade400,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -40, right: -30,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              top: 30, right: 60,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      children: [
                        const Text("🎟️ ",
                            style: TextStyle(fontSize: 16)),
                        Text(
                          "Pemesanan",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Booking Tiket",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color:
                                    Colors.deepOrange.withOpacity(0.07),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color:
                                    Colors.deepOrange.withOpacity(0.35),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Belum Ada Booking",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Tambahkan tiket ke keranjang\nlalu lakukan checkout",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _currentIndex = 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.deepOrange.shade700,
                                      Colors.orange.shade400,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepOrange
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Ke Keranjang",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Jika ada item di keranjang, langsung tampilkan BookingPage
    return BookingPage(
      bookingId: '',
      items: items.toList(),
      tanggalMulai: DateTime.now(),
      tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
      totalHarga: CartModel.instance.totalHarga,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F7F7),
      body: _getPage(),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: _navIcon(
                    Icons.home_outlined, Icons.home, 0),
                label: "Beranda",
              ),
              BottomNavigationBarItem(
                icon: _navIcon(
                    Icons.confirmation_number_outlined,
                    Icons.confirmation_number,
                    1),
                label: "Tiket",
              ),
              BottomNavigationBarItem(
                icon: _navIcon(
                    Icons.shopping_cart_outlined,
                    Icons.shopping_cart,
                    2),
                label: "Keranjang",
              ),
              // ── Tab Booking baru ──
              BottomNavigationBarItem(
                icon: _navIcon(
                    Icons.receipt_long_outlined,
                    Icons.receipt_long,
                    3),
                label: "Booking",
              ),
              BottomNavigationBarItem(
                icon: _navIcon(
                    Icons.person_outline, Icons.person, 4),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData inactiveIcon, IconData activeIcon, int index) {
    final bool isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.deepOrange.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(isActive ? activeIcon : inactiveIcon, size: 22),
    );
  }

  // ================= HOME CONTENT =================

  Widget _buildMainHomeContent() {
    return Stack(
      children: [
        Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepOrange.shade800,
                Colors.orange.shade400,
              ],
            ),
          ),
        ),
        Positioned(
          top: -40, right: -30,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          top: 30, right: 60,
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("👋 ",
                              style: TextStyle(fontSize: 18)),
                          Text(
                            "Halo, Penjelajah!",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Mau ke mana hari ini?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrange.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari tempat wisata...",
                        hintStyle: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.deepOrange),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _searchQuery = "";
                                    _searchController.clear();
                                  });
                                },
                                child: const Icon(Icons.close_rounded,
                                    color: Colors.grey),
                              )
                            : const Icon(Icons.tune_rounded,
                                color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _chips.length,
                    itemBuilder: (context, i) {
                      final chip = _chips[i];
                      final isSelected =
                          _selectedKategori == chip['kategori'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedKategori = chip['kategori']!;
                          });
                        },
                        child: _categoryChip(
                            chip['label']!, isSelected),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding:
                      const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F7F7),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_filteredVillages.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filteredVillages.map((village) {
                          return _buildWisataCard(village);
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

  Widget _categoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.deepOrange.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              "Wisata tidak ditemukan",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Coba kata kunci lain",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWisataCard(Map<String, String> village) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailWisataPage(data: village),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                village['img']!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      village['name']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13,
                            color: Colors.deepOrange.shade400),
                        const SizedBox(width: 3),
                        Text(
                          village['loc']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrange.shade700,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}