import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tiket_page.dart';
import 'cart.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'detail_wisata.dart';
import 'profile.dart';
import 'profile_admin_page.dart';
import 'booking_page.dart';

// ════════════════════════════════════════════════════════
//  HomePage
// ════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _heroController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _shimmerAnim;
  late Animation<double> _heroScaleAnim;
  late Animation<double> _heroFadeAnim;

  // Hero slider
  late PageController _heroPageController;
  int _heroPage = 0;

  static const List<String> _heroImages = [
    'assets/images/pahawang1.jpg',
    'assets/images/lembahhijau.jpeg',
    'assets/images/kebunliwa.jpeg',
  ];
  static const List<String> _heroSubtitles = [
    'Snorkeling & Pantai Eksotis',
    'Taman Satwa & Waterboom',
    'Kebun Sejuk Pegunungan',
  ];

  int _currentIndex = 0;
  String _selectedKategori = "Semua";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String role = "";
  bool _isSearchFocused = false;
  final FocusNode _searchFocus = FocusNode();

  static const Color _primary       = Color(0xFF0064D2);
  static const Color _primaryLight  = Color(0xFF3B8AFF);
  static const Color _primaryDark   = Color(0xFF004AAD);
  static const Color _accent        = Color(0xFFFF6900);
  static const Color _bgPage        = Color(0xFFF0F4FA);
  static const Color _bgCard        = Color(0xFFFFFFFF);
  static const Color _textPrimary   = Color(0xFF0A1629);
  static const Color _textSecondary = Color(0xFF6B7A99);
  static const Color _textMuted     = Color(0xFFAAB4C8);
  static const Color _divider       = Color(0xFFE8EDF5);

  static const String _heroImage = 'assets/images/pahawang1.jpg';

  final List<Map<String, String>> _villages = [
    {
      'name': 'Lembah Hijau', 'loc': 'Bandar Lampung',
      'img': 'assets/images/lembahhijau.jpeg',
      'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
      'harga': 'Rp 25.000', 'kategori': 'Hiburan',
      'gallery': 'assets/images/lembahhijau1.jpg,assets/images/lembahhijau2.jpg,assets/images/lembahhijau3.jpg',
      'rating': '4.8', 'review': '2.3k',
    },
    {
      'name': 'Kebun Liwa', 'loc': 'Lampung Barat',
      'img': 'assets/images/kebunliwa.jpeg',
      'deskripsi': 'Wisata kebun dengan udara sejuk dan pemandangan indah.',
      'harga': 'Rp 20.000', 'kategori': 'Alam',
      'gallery': 'assets/images/liwa1.jpeg,assets/images/liwa2.jpeg,assets/images/liwa3.jpeg',
      'rating': '4.6', 'review': '1.8k',
    },
    {
      'name': 'Pantai Pahawang', 'loc': 'Pesawaran',
      'img': 'assets/images/pahawang1.jpg',
      'deskripsi': 'Surga snorkeling di Lampung dengan air jernih.',
      'harga': 'Rp 30.000', 'kategori': 'Pantai',
      'gallery': 'assets/images/pahawang2.jpeg,assets/images/pahawang3.jpeg,assets/images/pahawang4.jpeg',
      'rating': '4.9', 'review': '5.1k',
    },
  ];

  final List<Map<String, dynamic>> _quickMenu = [
    {'icon': Icons.pool,           'label': 'Pantai',  'color': Color(0xFF0064D2), 'bg': Color(0xFFE6F0FF)},
    {'icon': Icons.terrain,        'label': 'Alam',    'color': Color(0xFF00A86B), 'bg': Color(0xFFE0F8EF)},
    {'icon': Icons.theater_comedy, 'label': 'Hiburan', 'color': Color(0xFFFF6900), 'bg': Color(0xFFFFEEE3)},
    {'icon': Icons.filter_vintage, 'label': 'Foto',    'color': Color(0xFF7B5EA7), 'bg': Color(0xFFF2ECFF)},
  ];

  final List<Map<String, dynamic>> _whyCards = [
    {
      'emoji': '🎫', 'title': 'Tiket Instan',
      'desc': 'Pesan & langsung dapat e-tiket dalam hitungan detik',
      'color': Color(0xFF0064D2), 'bg': Color(0xFFE6F0FF),
    },
    {
      'emoji': '💰', 'title': 'Harga Terjangkau',
      'desc': 'Nikmati wisata terbaik Lampung tanpa bikin dompet menangis',
      'color': Color(0xFF00A86B), 'bg': Color(0xFFE0F8EF),
    },
    {
      'emoji': '🔒', 'title': 'Aman & Terpercaya',
      'desc': 'Pembayaran aman, tiket resmi dari pengelola wisata',
      'color': Color(0xFFFF6900), 'bg': Color(0xFFFFEEE3),
    },
  ];

  final List<Map<String, dynamic>> _promoCards = [
    {
      'tag': 'PROMO SPESIAL',
      'title': 'Diskon 20%\ntiket wisata alam',
      'btnLabel': 'Klaim',
      'colors': [Color(0xFFFF6900), Color(0xFFFF9A3C)],
      'btnColor': Color(0xFFFF6900),
      'icon': '🌿',
    },
    {
      'tag': 'WEEKEND DEAL',
      'title': 'Beli 2 tiket pantai\ngratis 1 tiket',
      'btnLabel': 'Klaim',
      'colors': [Color(0xFF0064D2), Color(0xFF3B8AFF)],
      'btnColor': Color(0xFF0064D2),
      'icon': '🏖️',
    },
    {
      'tag': 'FLASH SALE',
      'title': 'Cashback Rp15rb\nmin. transaksi Rp50rb',
      'btnLabel': 'Klaim',
      'colors': [Color(0xFF00A86B), Color(0xFF34C88A)],
      'btnColor': Color(0xFF00A86B),
      'icon': '⚡',
    },
  ];

  // Stats summary data
  final List<Map<String, String>> _stats = [
    {'value': '3', 'label': 'Destinasi'},
    {'value': '10rb+', 'label': 'Wisatawan'},
    {'value': '4.9', 'label': 'Rating'},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _heroController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _controller, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
    _heroScaleAnim = Tween<double>(begin: 1.08, end: 1.0).animate(
        CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic));
    _heroFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    _heroPageController = PageController();
    _controller.forward();
    _heroController.forward();
    // Auto-slide hero every 4 seconds
    Future.delayed(const Duration(seconds: 4), _autoSlide);
    loadRole();
    _searchFocus.addListener(
        () => setState(() => _isSearchFocused = _searchFocus.hasFocus));
  }

  void loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => role = prefs.getString('role') ?? '');
  }

  void _autoSlide() {
    if (!mounted) return;
    final next = (_heroPage + 1) % _heroImages.length;
    _heroPageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 4), _autoSlide);
  }

  @override
  void dispose() {
    _heroPageController.dispose();
    _controller.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _heroController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredVillages {
    List<Map<String, String>> result = _villages;
    if (_selectedKategori != 'Semua')
      result = result.where((v) => v['kategori'] == _selectedKategori).toList();
    if (_searchQuery.isNotEmpty)
      result = result
          .where((v) =>
              v['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              v['loc']!.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    return result;
  }

  Widget _getPage() {
    switch (_currentIndex) {
      case 0: return _buildMainHomeContent();
      case 1: return TiketPage();
      case 2: return const CartPage();
      case 3: return _buildBookingTab();
      case 4: return role == 'admin'
          ? const ProfileAdminPage()
          : const ProfilePage();
      default: return _buildMainHomeContent();
    }
  }

  Widget _buildBookingTab() {
    final items = CartModel.instance.items;
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: _bgPage,
        body: Stack(children: [
          _buildGradientHeader(220),
          SafeArea(
            child: Column(children: [
              _buildHeaderSection("🎟️ Pemesanan", "Booking Tiket"),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _bgPage,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28)),
                  ),
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildEmptyIllustration(
                              Icons.receipt_long_rounded, _primary),
                          const SizedBox(height: 20),
                          const Text("Belum Ada Booking",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary)),
                          const SizedBox(height: 8),
                          const Text(
                              "Tambahkan tiket ke keranjang\nlalu lakukan checkout",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _textSecondary,
                                  height: 1.6)),
                          const SizedBox(height: 28),
                          _buildCTAButton("Ke Keranjang",
                              Icons.shopping_cart_rounded,
                              () => setState(() => _currentIndex = 2)),
                        ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      );
    }
    return BookingPage(
      items: items.toList(),
      tanggalMulai: DateTime.now(),
      tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
      totalHarga: CartModel.instance.totalHarga,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bgPage,
      extendBody: true,
      body: _getPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOTTOM NAV — modern floating pill style
  // ══════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0064D2).withOpacity(0.14),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: _primary,
          unselectedItemColor: _textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.2),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            _navItem(Icons.explore_outlined,       Icons.explore,              "Beranda",   0),
            _navItem(Icons.airplane_ticket_outlined, Icons.airplane_ticket,    "Tiket",     1),
            _navItem(Icons.card_travel_outlined,   Icons.card_travel,          "Keranjang", 2),
            _navItem(Icons.event_note_outlined,    Icons.event_note,           "Booking",   3),
            _navItem(Icons.manage_accounts_outlined, Icons.manage_accounts,    "Profil",    4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
      IconData inactive, IconData active, String label, int index) {
    final bool isActive = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        padding:
            EdgeInsets.symmetric(horizontal: isActive ? 16 : 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE6F0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(isActive ? active : inactive, size: 22),
      ),
      label: label,
    );
  }

  // ══════════════════════════════════════════════════════
  //  MAIN HOME — CustomScrollView
  // ══════════════════════════════════════════════════════
  Widget _buildMainHomeContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: _buildStatsBar()),
            SliverToBoxAdapter(child: _buildPromoCards()),
            SliverToBoxAdapter(child: _buildQuickMenu()),
            SliverToBoxAdapter(child: _buildWhySection()),
            SliverToBoxAdapter(child: _buildWisataSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  HERO SECTION — PageView 3 gambar + overlay + headline
  // ══════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return SizedBox(
      height: 390,
      child: Stack(children: [

        // ── 3-gambar PageView background ──
        Positioned.fill(
          child: PageView.builder(
            controller: _heroPageController,
            itemCount: _heroImages.length,
            onPageChanged: (i) => setState(() => _heroPage = i),
            itemBuilder: (context, i) {
              return AnimatedBuilder(
                animation: _heroScaleAnim,
                builder: (_, child) => Transform.scale(
                  scale: i == _heroPage ? _heroScaleAnim.value : 1.0,
                  child: child,
                ),
                child: Image.asset(
                  _heroImages[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CustomPaint(
                    painter: _FallbackBeachPainter(),
                    child: Container(),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Multi-layer gradient overlay ──
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x44000000),
                  Color(0x00000000),
                  Color(0x77000000),
                  Color(0xDD001A4D),
                ],
                stops: [0.0, 0.28, 0.62, 1.0],
              ),
            ),
          ),
        ),

        // ── Vignette kiri ──
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: Stack(children: [

            // ── App bar ──
            Positioned(
              top: 14,
              left: 18,
              right: 18,
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15), blurRadius: 8)
                    ],
                  ),
                  child: const Center(
                      child: Text("🏝️", style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TripNusaDesa",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                      ),
                    ),
                    Text(
                      "Wisata Desa & Alam Lampung",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ]),
            ),

            // ── Location pill ──
            Positioned(
              top: 68,
              left: 18,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                      offset: Offset(-10 * (1 - v), 0), child: child),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: Color(0xFFFF6900), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        "Lampung, Indonesia",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Hero headline + subtitle ──
            Positioned(
              bottom: 100,
              left: 18,
              right: 18,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                      offset: Offset(0, 20 * (1 - v)), child: child),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mau ke mana harimu?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.6,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 12,
                              offset: Offset(0, 3))
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.3), end: Offset.zero)
                              .animate(anim),
                          child: child,
                        ),
                      ),
                      child: Text(
                        "📍  ${_heroSubtitles[_heroPage]}",
                        key: ValueKey(_heroPage),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 6)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Dot indicator
                    Row(
                      children: List.generate(_heroImages.length, (i) {
                        final active = i == _heroPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withOpacity(0.40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar floating ──
            Positioned(
              bottom: -22,
              left: 16,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 6)),
                    BoxShadow(
                        color: _primary.withOpacity(
                            _isSearchFocused ? 0.20 : 0.0),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4)),
                  ],
                  border: _isSearchFocused
                      ? Border.all(color: _primaryLight, width: 2)
                      : Border.all(
                          color: Colors.white.withOpacity(0.6), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: "Cari destinasi wisata...",
                    hintStyle:
                        const TextStyle(color: _textMuted, fontSize: 14),
                    prefixIcon: Container(
                      padding: const EdgeInsets.only(left: 16, right: 10),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: _primary, size: 18),
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 60),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchQuery = "";
                              _searchController.clear();
                            }),
                            child: const Padding(
                                padding: EdgeInsets.only(right: 14),
                                child: Icon(Icons.cancel_rounded,
                                    color: _textMuted, size: 20)),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Cari",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ]),
        ),

        // ── Wave cut bawah ──
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FA),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32)),
            ),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  //  STATS BAR — destinasi / wisatawan / rating
  // ══════════════════════════════════════════════════════
  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) =>
            Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: _primary.withOpacity(0.10),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 6)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _stats.asMap().entries.map((entry) {
              final i = entry.key;
              final stat = entry.value;
              return Row(children: [
                Column(children: [
                  Text(
                    stat['value']!,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _primary,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat['label']!,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary),
                  ),
                ]),
                if (i < _stats.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: 1,
                    height: 32,
                    color: _divider,
                  ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  PROMO CARDS — horizontal scroll, rapi tanpa "lihat semua"
  // ══════════════════════════════════════════════════════
  Widget _buildPromoCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header (tanpa tombol lihat semua) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(children: [
              Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              const Text(
                "Penawaran Spesial",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.2),
              ),
            ]),
          ),

          // ── Horizontal list ──
          SizedBox(
            height: 148,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _promoCards.length,
              itemBuilder: (context, i) {
                final card = _promoCards[i];
                final colors = card['colors'] as List<Color>;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (i * 120)),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                        offset: Offset(20 * (1 - v), 0), child: child),
                  ),
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: colors[0].withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 8)),
                        BoxShadow(
                            color: colors[0].withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(children: [
                        // Lingkaran dekorasi kanan atas
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.10),
                            ),
                          ),
                        ),
                        // Lingkaran dekorasi kiri bawah
                        Positioned(
                          left: -16,
                          bottom: -24,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),
                        // Konten utama — Row: teks kiri + emoji kanan
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ── Kolom kiri: badge + judul + tombol ──
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Badge tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        card['tag'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.0),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Judul promo
                                    Text(
                                      card['title'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 1.35),
                                    ),
                                    const SizedBox(height: 12),
                                    // Tombol klaim
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.14),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        card['btnLabel'] as String,
                                        style: TextStyle(
                                            color: card['btnColor'] as Color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // ── Emoji kanan ──
                              Text(
                                card['icon'] as String,
                                style: TextStyle(
                                  fontSize: 42,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(2, 4),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  QUICK MENU — category icons
  // ══════════════════════════════════════════════════════
  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionLabel("Jelajahi Kategori"),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _quickMenu.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + (i * 80)),
              curve: Curves.easeOutBack,
              builder: (context, v, child) => Transform.scale(
                scale: v,
                child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
              ),
              child: GestureDetector(
                onTap: () => setState(() => _selectedKategori =
                    item['label'] as String == 'Foto'
                        ? 'Semua'
                        : item['label'] as String),
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (item['color'] as Color).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: (item['color'] as Color).withOpacity(0.18),
                              blurRadius: 14,
                              spreadRadius: 0,
                              offset: const Offset(0, 5)),
                        ]),
                    child: Icon(item['icon'] as IconData,
                        color: item['color'] as Color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(item['label'] as String,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  //  WHY SECTION
  // ══════════════════════════════════════════════════════
  Widget _buildWhySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          const Text("Kenapa Pilih Kami?",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.2)),
        ]),
        const SizedBox(height: 16),
        ..._whyCards.asMap().entries.map((entry) {
          final card = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (entry.key * 120)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                  offset: Offset(24 * (1 - value), 0), child: child),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _divider, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: (card['color'] as Color).withOpacity(0.08),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 5)),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: card['bg'] as Color,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: (card['color'] as Color).withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ]),
                  child: Center(
                      child: Text(card['emoji'] as String,
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card['title'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary)),
                        const SizedBox(height: 3),
                        Text(card['desc'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                                height: 1.4)),
                      ]),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (card['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: card['color'] as Color, size: 20),
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.2));
  }

  // ══════════════════════════════════════════════════════
  //  WISATA CARDS SECTION
  // ══════════════════════════════════════════════════════
  Widget _buildWisataSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text("Rekomendasi Untukmu",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.2)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]),
            child: const Text("Lihat semua",
                style: TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        if (_filteredVillages.isEmpty)
          _buildEmptyState()
        else
          ..._filteredVillages.asMap().entries.map((entry) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 350 + (entry.key * 120)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)), child: child),
              ),
              child: _buildWisataCard(entry.value),
            );
          }),
      ]),
    );
  }

  Widget _buildWisataCard(Map<String, String> village) {
    final rating = village['rating'] ?? '4.5';
    final review = village['review'] ?? '1k';
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) =>
                  DetailWisataPage(data: village),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0.04, 0), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _divider, width: 1),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.07),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8)),
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(children: [
          Stack(children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22)),
              child: Image.asset(village['img']!,
                  width: double.infinity,
                  height: 185,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                        height: 185,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F0FF),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(22),
                              topRight: Radius.circular(22)),
                        ),
                        child: const Center(
                            child: Icon(Icons.image_rounded,
                                color: _primary, size: 48)),
                      )),
            ),
            // Gradient overlay on image
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.45)
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Text(village['kategori']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4)),
              ),
            ),
            // Bookmark button
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]),
                child: const Icon(Icons.bookmark_border_rounded,
                    color: _primary, size: 18),
              ),
            ),
            // Rating badge on image
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 13),
                  const SizedBox(width: 3),
                  Text(rating,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary)),
                  Text("  ($review ulasan)",
                      style: const TextStyle(
                          fontSize: 10,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ]),

          // Card body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(village['name']!,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.2)),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.location_on_rounded,
                      size: 13, color: Color(0xFFFF6900)),
                  const SizedBox(width: 3),
                  Text(village['loc']!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 8),
                Text(village['deskripsi']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                        height: 1.45)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ── Helpers used by other tabs ──

  Widget _buildGradientHeader(double height) {
    return SizedBox(
      height: height,
      child: Image.asset(_heroImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: _primary)),
    );
  }

  Widget _buildHeaderSection(String subtitle, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(subtitle,
            style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4)),
      ]),
    );
  }

  Widget _buildEmptyIllustration(IconData icon, Color color) {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.15), width: 2),
        ),
        child: Icon(icon, size: 44, color: color.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildCTAButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(children: [
          _buildEmptyIllustration(Icons.search_off_rounded, _primary),
          const SizedBox(height: 20),
          const Text("Destinasi tidak ditemukan",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          const Text("Coba kata kunci lain",
              style: TextStyle(fontSize: 13, color: _textSecondary)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Fallback Beach Painter — jika asset foto gagal load
// ════════════════════════════════════════════════════════
class _FallbackBeachPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Sun glow
    canvas.drawCircle(Offset(w * 0.75, h * 0.20),
        46, Paint()..color = const Color(0xFFFFD54F).withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
    canvas.drawCircle(Offset(w * 0.75, h * 0.20), 28,
        Paint()..color = const Color(0xFFFFE082).withOpacity(0.9));

    // Sea
    final seaPath = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w, h * 0.50)
      ..lineTo(w, h * 0.80)
      ..lineTo(0, h * 0.80)
      ..close();
    canvas.drawPath(
        seaPath,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF01579B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.3)));

    // Sand
    final sandPath = Path()
      ..moveTo(0, h * 0.76)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
        sandPath,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE8C77A), Color(0xFFC9A24E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28)));

    // Waves
    for (int i = 0; i < 3; i++) {
      final wY = h * (0.52 + i * 0.05);
      final wavePath = Path()
        ..moveTo(0, wY)
        ..quadraticBezierTo(w * 0.25, wY - 5, w * 0.5, wY)
        ..quadraticBezierTo(w * 0.75, wY + 5, w, wY)
        ..lineTo(w, wY + 7)
        ..lineTo(0, wY + 7)
        ..close();
      canvas.drawPath(
          wavePath,
          Paint()
            ..color =
                Colors.white.withOpacity(0.10 - i * 0.025));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}