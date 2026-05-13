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
import 'dart:async';

// ════════════════════════════════════════════════════════
//  DESIGN TOKENS — Palet Teal/Hijau (matching tiket wireframe)
// ════════════════════════════════════════════════════════
class _T {
  // Primary teal — sama persis dengan warna header tiket wireframe
  static const Color primary        = Color(0xFF00B09B);  // teal utama
  static const Color primaryDark    = Color(0xFF007A6A);  // teal gelap
  static const Color primaryLight   = Color(0xFF4DD9C9);  // teal terang
  static const Color primarySurface = Color(0xFFE0F7F4);  // bg teal pucat

  // Gradient header — mirip gradien tiket wireframe
  static const List<Color> headerGrad = [Color(0xFF00B09B), Color(0xFF00D2B4)];

  // Accent oranye untuk CTA / harga
  static const Color accent     = Color(0xFFFF6B35);
  static const Color accentSoft = Color(0xFFFFF0EB);

  // Neutrals
  static const Color bgPage     = Color(0xFFF2FAF9);
  static const Color bgCard     = Color(0xFFFFFFFF);
  static const Color textHead   = Color(0xFF0D2B26);
  static const Color textBody   = Color(0xFF4A6B66);
  static const Color textMuted  = Color(0xFFA0B8B5);
  static const Color divider    = Color(0xFFDCF0EE);

  // Semantic
  static const Color green  = Color(0xFF00C48C);
  static const Color yellow = Color(0xFFFBBF24);
}

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

  Timer? _autoSlide;

  String _fullname = '';
  String _email    = '';
  late PageController _heroPageController;
  int _heroPage    = 0;

  // ── Hero images — 3 foto Unsplash wisata alam Indonesia
  static const List<String> _heroImages = [
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=1280&q=85&fit=crop',
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1280&q=85&fit=crop',
    'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=1280&q=85&fit=crop',
  ];
  static const List<String> _heroSubtitles = [
    '',
    '',
    '',
  ];

  int _currentIndex = 0;

  String _selectedKategori = "Semua";
  String _searchQuery      = "";
  final TextEditingController _searchController = TextEditingController();
  String role              = "";
  bool _isSearchFocused    = false;
  final FocusNode _searchFocus = FocusNode();

  Map<String, dynamic> userData = {
    'fullname': 'Pengguna',
    'email'   : 'user@gmail.com',
  };

  final List<Map<String, String>> _villages = [
    {
      'name'     : 'Lembah Hijau',
      'loc'      : 'Bandar Lampung',
      'img'      : 'assets/images/lembahhijau.jpeg',
      'deskripsi': 'Taman wisata satwa dengan fasilitas waterboom.',
      'harga'    : 'Rp 25.000',
      'kategori' : 'Hiburan',
      'gallery'  : 'assets/images/lembahhijau1.jpg,assets/images/lembahhijau2.jpg,assets/images/lembahhijau3.jpg',
      'rating'   : '4.8',
      'review'   : '2.3k',
    },
    {
      'name'     : 'Kebun Liwa',
      'loc'      : 'Lampung Barat',
      'img'      : 'assets/images/kebunliwa.jpeg',
      'deskripsi': 'Wisata kebun dengan udara sejuk dan pemandangan indah.',
      'harga'    : 'Rp 20.000',
      'kategori' : 'Alam',
      'gallery'  : 'assets/images/liwa1.jpeg,assets/images/liwa2.jpeg,assets/images/liwa3.jpeg',
      'rating'   : '4.6',
      'review'   : '1.8k',
    },
    {
      'name'     : 'Pantai Pahawang',
      'loc'      : 'Pesawaran',
      'img'      : 'assets/images/pahawang1.jpg',
      'deskripsi': 'Surga snorkeling di Lampung dengan air jernih.',
      'harga'    : 'Rp 30.000',
      'kategori' : 'Pantai',
      'gallery'  : 'assets/images/pahawang2.jpeg,assets/images/pahawang3.jpeg,assets/images/pahawang4.jpeg',
      'rating'   : '4.9',
      'review'   : '5.1k',
    },
  ];

  final List<Map<String, dynamic>> _quickMenu = [
    {'icon': Icons.waves_rounded,        'label': 'Pantai',  'color': _T.primary,            'bg': _T.primarySurface},
    {'icon': Icons.park_rounded,         'label': 'Alam',    'color': Color(0xFF00A86B),     'bg': Color(0xFFE0F8EF)},
    {'icon': Icons.celebration_rounded,  'label': 'Hiburan', 'color': Color(0xFFFF6B35),     'bg': Color(0xFFFFF0EB)},
    {'icon': Icons.camera_alt_rounded,   'label': 'Foto',    'color': Color(0xFF7B5EA7),     'bg': Color(0xFFF2ECFF)},
  ];

  final List<Map<String, dynamic>> _whyCards = [
    {
      'emoji': '🎫', 'title': 'Tiket Instan',
      'desc' : 'Pesan & langsung dapat e-tiket dalam hitungan detik',
      'color': _T.primary, 'bg': _T.primarySurface,
    },
    {
      'emoji': '💰', 'title': 'Harga Terjangkau',
      'desc' : 'Nikmati wisata terbaik Lampung tanpa bikin dompet menangis',
      'color': Color(0xFF00A86B), 'bg': Color(0xFFE0F8EF),
    },
    {
      'emoji': '🔒', 'title': 'Aman & Terpercaya',
      'desc' : 'Pembayaran aman, tiket resmi dari pengelola wisata',
      'color': Color(0xFF00A86B), 'bg': Color(0xFFE0F8EF),
    },
  ];

  final List<Map<String, dynamic>> _promoCards = [
    {
      'tag'     : 'PROMO SPESIAL',
      'title'   : 'Diskon 20%\ntiket wisata alam',
      'btnLabel': 'Klaim',
      'colors'  : [Color(0xFF00B09B), Color(0xFF00D2B4)],
      'btnColor': _T.primary,
      'icon'    : '🌿',
    },
    {
      'tag'     : 'WEEKEND DEAL',
      'title'   : 'Beli 2 tiket pantai\ngratis 1 tiket',
      'btnLabel': 'Klaim',
      'colors'  : [Color(0xFF007A6A), Color(0xFF00B09B)],
      'btnColor': _T.primaryDark,
      'icon'    : '🏖️',
    },
    {
      'tag'     : 'FLASH SALE',
      'title'   : 'Cashback Rp15rb\nmin. transaksi Rp50rb',
      'btnLabel': 'Klaim',
      'colors'  : [Color(0xFFFF6B35), Color(0xFFFF9A6B)],
      'btnColor': _T.accent,
      'icon'    : '⚡',
    },
  ];

  final List<Map<String, String>> _stats = [
    {'value': '3',    'label': 'Destinasi'},
    {'value': '10rb+','label': 'Wisatawan'},
    {'value': '4.9',  'label': 'Rating'},
  ];

  // ══════════════════════════════════════════════════════
  //  initState
  // ══════════════════════════════════════════════════════
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
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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

    Future.delayed(const Duration(seconds: 4), _startAutoSlide);
    loadRole();
    _searchFocus.addListener(
        () => setState(() => _isSearchFocused = _searchFocus.hasFocus));
  }

  void _startAutoSlide() {
    if (!mounted) return;
    _autoSlide = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final nextPage = (_heroPage + 1) % _heroImages.length;
      _heroPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      role      = prefs.getString('role')     ?? '';
      _fullname = prefs.getString('fullname') ?? '';
      _email    = prefs.getString('email')    ?? '';
    });
  }

  @override
  void dispose() {
    _autoSlide?.cancel();
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
      case 0:  return _buildMainHomeContent();
      case 1:  return const TiketPage();
      case 2:  return const CartPage();
      case 3:  return BookingPage();
      case 4:
        return role.toLowerCase() == 'admin'
            ? const ProfileAdminPage()
            : ProfilePage(userData: userData);
      default: return _buildMainHomeContent();
    }
  }

  // ══════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _T.bgPage,
      extendBody: true,
      body: _getPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOTTOM NAV — pill gaya Traveloka
  // ══════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: _T.primary.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: _T.primary,
          unselectedItemColor: _T.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.2),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            _navItem(Icons.explore_outlined,         Icons.explore,         "Beranda",   0),
            _navItem(Icons.airplane_ticket_outlined, Icons.airplane_ticket, "Tiket",     1),
            _navItem(Icons.shopping_bag_outlined,    Icons.shopping_bag,    "Keranjang", 2),
            _navItem(Icons.event_note_outlined,      Icons.event_note,      "Booking",   3),
            _navItem(Icons.person_outline_rounded,   Icons.person_rounded,  "Profil",    4),
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
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _T.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(isActive ? active : inactive, size: 22),
      ),
      label: label,
    );
  }

  // ══════════════════════════════════════════════════════
  //  MAIN HOME CONTENT
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
            SliverToBoxAdapter(child: _buildWisataSection()),
            SliverToBoxAdapter(child: _buildWhySection()),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  HERO SECTION — teal gradient header ala tiket wireframe
  // ══════════════════════════════════════════════════════
  Widget _buildHeroSection() {
    return SizedBox(
      height: 400,
      child: Stack(children: [

        // ── PageView foto background ──
        Positioned.fill(
          child: PageView.builder(
            physics: const ClampingScrollPhysics(),
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
                child: Image.network(
                  _heroImages[i],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF007A6A),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white54),
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => CustomPaint(
                    painter: _FallbackTealPainter(),
                    child: Container(),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Gradient overlay teal atas ke bawah ──
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC00B09B),
                  Color(0x33007A6A),
                  Color(0x00000000),
                  Color(0xDD00423A),
                ],
                stops: [0.0, 0.22, 0.50, 1.0],
              ),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: Stack(children: [

            // ── AppBar row ──
            Positioned(
              top: 14, left: 18, right: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Brand
                  Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.40), width: 1.3),
                      ),
                      child: const Center(
                          child: Text("🏝️", style: TextStyle(fontSize: 21))),
                    ),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Trip Nusa Desa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                          )),
                      Text("Jelajahi Desa & Alam",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          )),
                    ]),
                  ]),

                ],
              ),
            ),

            // ── Location chip ──
            Positioned(
              top: 68, left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.35), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFFFFE082), size: 13),
                  const SizedBox(width: 4),
                  Text("Lampung, Indonesia",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ]),
              ),
            ),

            // ── Greeting + subtitle + dots ──
            Positioned(
              bottom: 106, left: 18, right: 18,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  _fullname.isNotEmpty
                      ? "Halo, ${_fullname.split(' ').first} 👋"
                      : "Jelajahi Lampung 🌿",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 3))
                    ],
                  ),
                ),
                const SizedBox(height: 6),
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
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Dot indicators
                Row(
                  children: List.generate(_heroImages.length, (i) {
                    final active = i == _heroPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.38),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ]),
            ),

            // ── Search bar floating ──
            Positioned(
              bottom: -22, left: 16, right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: _T.primary.withOpacity(0.22),
                        blurRadius: 28,
                        offset: const Offset(0, 8)),
                    BoxShadow(
                        color: _T.primary
                            .withOpacity(_isSearchFocused ? 0.22 : 0.0),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                  border: _isSearchFocused
                      ? Border.all(color: _T.primaryLight, width: 2)
                      : Border.all(color: Colors.white, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _T.textHead),
                  decoration: InputDecoration(
                    hintText: "Cari destinasi wisata...",
                    hintStyle:
                        const TextStyle(color: _T.textMuted, fontSize: 14),
                    prefixIcon: Container(
                      padding: const EdgeInsets.only(left: 16, right: 10),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: _T.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: _T.primary, size: 18),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 62),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchQuery = "";
                              _searchController.clear();
                            }),
                            child: const Padding(
                                padding: EdgeInsets.only(right: 14),
                                child: Icon(Icons.cancel_rounded,
                                    color: _T.textMuted, size: 20)),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: _T.headerGrad,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Text("Cari",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
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

        // ── Wave bottom cut ──
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 30,
            decoration: const BoxDecoration(
              color: _T.bgPage,
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
  //  STATS BAR — teal accent numbers
  // ══════════════════════════════════════════════════════
  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => Opacity(
            opacity: v,
            child:
                Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _T.divider, width: 1),
            boxShadow: [
              BoxShadow(
                  color: _T.primary.withOpacity(0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _stats.asMap().entries.map((entry) {
              final i    = entry.key;
              final stat = entry.value;
              return Row(children: [
                Column(children: [
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: _T.headerGrad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(r),
                    child: Text(stat['value']!,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 2),
                  Text(stat['label']!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _T.textBody)),
                ]),
                if (i < _stats.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 22),
                    width: 1, height: 34,
                    color: _T.divider,
                  ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  PROMO CARDS
  // ══════════════════════════════════════════════════════
  Widget _buildPromoCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                    width: 4, height: 18,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: _T.headerGrad,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                const Text("Penawaran Spesial",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _T.textHead,
                        letterSpacing: -0.2)),
              ]),
              Text("Lihat semua",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _T.primary)),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _promoCards.length,
            itemBuilder: (context, i) {
              final card   = _promoCards[i];
              final colors = card['colors'] as List<Color>;
              return Container(
                width: 220,
                margin: EdgeInsets.only(right: i < _promoCards.length - 1 ? 14 : 0),
                child: Material(
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(children: [
                      // Decorative circle TL
                      Positioned(
                        top: -24, right: -18,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                      ),
                      // Decorative circle BR
                      Positioned(
                        left: -16, bottom: -24,
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(card['tag'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.0)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(card['title'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          height: 1.35)),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                                    ),
                                    child: Text(card['btnLabel'] as String,
                                        style: TextStyle(
                                            color: card['btnColor'] as Color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(card['icon'] as String,
                                style: TextStyle(
                                  fontSize: 42,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(2, 4),
                                    )
                                  ],
                                )),
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
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  //  QUICK MENU — kategori icon grid
  // ══════════════════════════════════════════════════════
  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel("Jelajahi Kategori"),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _quickMenu.asMap().entries.map((entry) {
            final i    = entry.key;
            final item = entry.value;
            final isSelected = _selectedKategori == item['label'] as String;
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
                        : (isSelected ? 'Semua' : item['label'] as String)),
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                        color: isSelected
                            ? (item['color'] as Color)
                            : item['bg'] as Color,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: (item['color'] as Color)
                              .withOpacity(isSelected ? 0.0 : 0.18),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: (item['color'] as Color)
                                  .withOpacity(isSelected ? 0.35 : 0.14),
                              blurRadius: isSelected ? 20 : 12,
                              offset: const Offset(0, 5)),
                        ]),
                    child: Icon(item['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : item['color'] as Color,
                        size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(item['label'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? (item['color'] as Color)
                              : _T.textHead)),
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
              width: 4, height: 20,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: _T.headerGrad,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          const Text("Kenapa Pilih Kami?",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _T.textHead,
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
                color: _T.bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _T.divider, width: 1),
                boxShadow: [
                  BoxShadow(
                      color: (card['color'] as Color).withOpacity(0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                      color: card['bg'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: (card['color'] as Color).withOpacity(0.14),
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
                                color: _T.textHead)),
                        const SizedBox(height: 3),
                        Text(card['desc'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _T.textBody,
                                height: 1.4)),
                      ]),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: (card['color'] as Color).withOpacity(0.10),
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
            color: _T.textHead,
            letterSpacing: -0.2));
  }

  // ══════════════════════════════════════════════════════
  //  WISATA CARDS — horizontal scroll + vertical list
  // ══════════════════════════════════════════════════════
  Widget _buildWisataSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: _T.headerGrad,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            const Text("Rekomendasi Untukmu",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _T.textHead,
                    letterSpacing: -0.2)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: _T.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: const Text("Lihat semua",
                style: TextStyle(
                    color: _T.primary,
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
                          parent: animation,
                          curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
            ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: _T.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _T.divider, width: 1),
          boxShadow: [
            BoxShadow(
                color: _T.primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8)),
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(children: [
          Stack(children: [
            // Photo
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
                          color: _T.primarySurface,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(22),
                              topRight: Radius.circular(22)),
                        ),
                        child: const Center(
                            child: Icon(Icons.image_rounded,
                                color: _T.primary, size: 48)),
                      )),
            ),
            // Gradient overlay on photo
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
                        Colors.black.withOpacity(0.42)
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Kategori badge — teal
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: _T.headerGrad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                        color: _T.primary.withOpacity(0.38),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
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
            // Bookmark icon
            Positioned(
              top: 12, right: 12,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]),
                child: const Icon(Icons.bookmark_border_rounded,
                    color: _T.primary, size: 18),
              ),
            ),
            // Rating pill
            Positioned(
              bottom: 14, left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]),
                child: Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFBBF24), size: 13),
                  const SizedBox(width: 3),
                  Text(rating,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _T.textHead)),
                  Text("  ($review ulasan)",
                      style: const TextStyle(
                          fontSize: 10,
                          color: _T.textBody,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ]),
          // Card body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Name + location + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(village['name']!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _T.textHead,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: _T.primary),
                        const SizedBox(width: 3),
                        Text(village['loc']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _T.textBody,
                                fontWeight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 7),
                      Text(village['deskripsi']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _T.textMuted,
                              height: 1.45)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Price + CTA
        
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOOKING TAB
  // ══════════════════════════════════════════════════════
  Widget _buildBookingTab() {
    final items = CartModel.instance.items;
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: _T.bgPage,
        body: Stack(children: [
          // Teal header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: _T.headerGrad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32)),
              ),
            ),
          ),
          SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text("🎟️ Pemesanan",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text("Booking Tiket",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4)),
                ]),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _T.bgPage,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28)),
                  ),
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _T.primarySurface,
                                border: Border.all(
                                    color: _T.primary.withOpacity(0.15),
                                    width: 2),
                              ),
                              child: const Icon(Icons.receipt_long_rounded,
                                  size: 44, color: _T.primary),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Belum Ada Booking",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _T.textHead)),
                          const SizedBox(height: 8),
                          const Text(
                              "Tambahkan tiket ke keranjang\nlalu lakukan checkout",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _T.textBody,
                                  height: 1.6)),
                          const SizedBox(height: 28),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _currentIndex = 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: _T.headerGrad),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: _T.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5))
                                ],
                              ),
                              child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_cart_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text("Ke Keranjang",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  ]),
                            ),
                          ),
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

  // ── Helpers ──
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _T.primarySurface,
                border: Border.all(
                    color: _T.primary.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 44, color: _T.primary),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Destinasi tidak ditemukan",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _T.textHead)),
          const SizedBox(height: 6),
          const Text("Coba kata kunci lain",
              style: TextStyle(fontSize: 13, color: _T.textBody)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  Fallback Teal Painter (jika foto gagal load)
// ════════════════════════════════════════════════════════
class _FallbackTealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Teal gradient bg
    

    // Sun glow
    canvas.drawCircle(Offset(w * 0.75, h * 0.20), 46,
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
    canvas.drawCircle(Offset(w * 0.75, h * 0.20), 28,
        Paint()..color = Colors.white.withOpacity(0.30));

    // Wave bottom
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.70)
        ..quadraticBezierTo(w * 0.5, h * 0.64, w, h * 0.70)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // Wave 2
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.78)
        ..quadraticBezierTo(w * 0.35, h * 0.74, w * 0.70, h * 0.77)
        ..quadraticBezierTo(w * 0.85, h * 0.79, w, h * 0.76)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}