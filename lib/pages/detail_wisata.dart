import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════
//  Design Tokens — Teal/Green palette (selaras TiketPage)
// ════════════════════════════════════════════════════════
const Color _primary = Color(0xFF2DC8A8); // teal utama (mirip tiket)
const Color _primaryDark = Color(0xFF1AA08A); // teal gelap
const Color _primaryLight = Color(0xFF7DE8D4); // teal muda
const Color _accent = Color(0xFF00B894); // green-teal accent
const Color _bgPage = Color(0xFFF0FBF8); // bg sangat soft teal
const Color _bgCard = Color(0xFFFFFFFF);
const Color _textPrimary = Color(0xFF0D2B22); // dark greenish
const Color _textSecondary = Color(0xFF4A7A6E);
const Color _textMuted = Color(0xFF9ABDB5);
const Color _divider = Color(0xFFD6F0EA);

// ════════════════════════════════════════════════════════
//  Deskripsi lengkap per wisata (sama persis aslinya)
// ════════════════════════════════════════════════════════
const Map<String, String> _deskripsiLengkap = {
  'Lembah Hijau':
      'Lembah Hijau adalah taman wisata terpadu yang terletak di jantung Kota Bandar Lampung. '
      'Tempat ini menawarkan kombinasi unik antara taman satwa, wahana waterboom, dan area piknik yang rindang. '
      'Pengunjung dapat menyaksikan berbagai satwa seperti rusa, kancil, burung merak, dan reptil eksotis di area kebun binatang mini. '
      'Waterboom-nya dilengkapi dengan seluncuran air berbagai ukuran yang ramah untuk semua usia, dari anak-anak hingga dewasa. '
      'Area kuliner dengan aneka makanan khas Lampung tersedia di dalam kompleks, menjadikan Lembah Hijau pilihan sempurna '
      'untuk liburan keluarga yang menyenangkan dan tak terlupakan.',

  'Kebun Liwa':
      'Kebun Liwa adalah surga wisata alam di ketinggian pegunungan Lampung Barat yang menawarkan udara sejuk dan segar. '
      'Dikelilingi hamparan kebun kopi, lada, dan kakao, tempat ini memperkenalkan pengunjung pada kearifan lokal pertanian '
      'tradisional masyarakat Lampung Barat. '
      'Pemandangan Gunung Pesagi yang megah menjadi latar belakang yang memukau, cocok untuk fotografi maupun sekadar menikmati ketenangan alam. '
      'Tersedia jalur trekking ringan melewati kebun dan hutan kecil, serta homestay lokal bagi yang ingin menginap '
      'dan merasakan kehidupan desa secara langsung. '
      'Wisata edukasi pertanian juga tersedia untuk anak-anak sekolah maupun keluarga yang ingin belajar tentang alam.',

  'Pantai Pahawang':
      'Pantai Pahawang adalah destinasi snorkeling terbaik di Lampung yang terkenal hingga mancanegara. '
      'Terletak di Kabupaten Pesawaran, pulau ini dapat dicapai dengan perahu sekitar 30-45 menit dari dermaga Ketapang. '
      'Keindahan bawah lautnya sangat menakjubkan — terumbu karang berwarna-warni, ikan badut, bintang laut, '
      'dan berbagai biota laut eksotis lainnya dapat dijumpai di perairan yang sangat jernih ini. '
      'Pulau Pahawang Kecil dan Pahawang Besar memiliki pantai berpasir putih dengan air berwarna toska yang memesona. '
      'Paket wisata umumnya sudah mencakup peralatan snorkeling, makan siang, dan kunjungan ke beberapa spot terbaik '
      'di sekitar pulau, menjadikannya pengalaman wisata bahari yang lengkap dan tak terlupakan.',
};

String _getDeskripsiLengkap(String name) {
  return _deskripsiLengkap[name] ??
      'Destinasi wisata menakjubkan di Lampung yang menawarkan pengalaman tak terlupakan. '
          'Nikmati keindahan alam, budaya lokal, dan kehangatan masyarakat setempat dalam setiap kunjungan Anda.';
}

// ════════════════════════════════════════════════════════
//  DetailWisataPage
// ════════════════════════════════════════════════════════
class DetailWisataPage extends StatefulWidget {
  final Map<String, String> data;
  const DetailWisataPage({super.key, required this.data});

  @override
  State<DetailWisataPage> createState() => _DetailWisataPageState();
}

class _DetailWisataPageState extends State<DetailWisataPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isWishlisted = false;
  bool _isExpanded = false;
  final ScrollController _scrollCtrl = ScrollController();
  double _heroOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();

    _scrollCtrl.addListener(() {
      final offset = _scrollCtrl.offset;
      setState(() {
        _heroOpacity = (1.0 - (offset / 260)).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final name = data['name'] ?? '';
    final deskripsi = _getDeskripsiLengkap(name);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _bgPage,
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Stack(
            children: [
              // ── Scrollable content ──
              CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Hero SliverAppBar ──────────────────────────────
                  SliverAppBar(
                    expandedHeight: 380,
                    pinned: true,
                    stretch: true,
                    backgroundColor: _primaryDark,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: _buildHeroBackground(data, name),
                    ),
                  ),

                  // ── Body konten ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Glassmorphism info card overlap ──
                        _buildGlassInfoCard(data, name),

                        // ── Tentang Destinasi ──
                        _buildDescriptionSection(deskripsi),

                        // ── Galeri Foto ──
                        _buildGallerySection(data),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Floating AppBar buttons ──
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                child: Opacity(
                  opacity: _heroOpacity > 0.3 ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassButton(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      Row(
                        children: [
                          _glassButton(
                            onTap: () =>
                                setState(() => _isWishlisted = !_isWishlisted),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(_isWishlisted),
                                color: _isWishlisted
                                    ? const Color(0xFFFF6B6B)
                                    : Colors.white,
                                size: 20,
                              ),
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
      ),
    );
  }

  // ── Hero Background ──────────────────────────────────────
  Widget _buildHeroBackground(Map<String, String> data, String name) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Foto hero
        Image.asset(
          data['img'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryDark, _primary, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.landscape_rounded,
                color: Colors.white54,
                size: 80,
              ),
            ),
          ),
        ),

        // Multi-layer gradient — cinematic
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x44000000),
                  Color(0x00000000),
                  Color(0x66003D2E),
                  Color(0xEE001F14),
                ],
                stops: [0.0, 0.25, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // Nama & lokasi di atas foto
        Positioned(
          bottom: 28,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge kategori
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  data['kategori'] ?? 'Wisata Alam',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Nama wisata
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Lokasi
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data['loc'] ?? 'Lampung, Indonesia',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.90),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Glassmorphism Info Card (overlap di bawah hero) ──────
  Widget _buildGlassInfoCard(Map<String, String> data, String name) {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _primary.withOpacity(0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Baris utama: rating + ulasan + wishlist
                  Row(
                    children: [
                      // Rating badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFC107), Color(0xFFFFE066)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withOpacity(0.40),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data['rating'] ?? '4.9',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Ulasan + label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['review'] ?? '2.3k'} Ulasan',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Sangat direkomendasikan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Wishlist heart glow
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isWishlisted = !_isWishlisted),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: _isWishlisted
                                ? const Color(0xFFFFEEEE)
                                : _bgPage,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isWishlisted
                                  ? const Color(0xFFFF6B6B).withOpacity(0.5)
                                  : _divider,
                              width: 1.5,
                            ),
                            boxShadow: _isWishlisted
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withOpacity(0.3),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              _isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(_isWishlisted),
                              color: _isWishlisted
                                  ? const Color(0xFFFF6B6B)
                                  : _textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: _divider, height: 1),
                  ),

                  // Baris bawah: Kategori + Lokasi
                  Row(
                    children: [
                      // Kategori chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_rounded,
                              color: _primary,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data['kategori'] ?? 'Wisata Alam',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Lokasi
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: _accent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['loc'] ?? 'Lampung, Indonesia',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Experience Detail Chips ──────────────────────────────
  Widget _buildExperienceChips(Map<String, String> data) {
    final chips = [
      {
        'icon': Icons.schedule_rounded,
        'label': 'Durasi',
        'value': data['durasi'] ?? '1 Hari',
        'color': _primary,
      },
      {
        'icon': Icons.trending_up_rounded,
        'label': 'Tingkat',
        'value': data['difficulty'] ?? 'Mudah',
        'color': const Color(0xFF00C853),
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'label': 'Terbaik',
        'value': data['bestTime'] ?? 'Pagi',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.people_rounded,
        'label': 'Min. Grup',
        'value': data['minGroup'] ?? '2 Org',
        'color': _primaryDark,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('✨', 'Detail Pengalaman'),
          const SizedBox(height: 14),
          Row(
            children: chips.map((chip) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: chip == chips.last ? 0 : 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _divider, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: (chip['color'] as Color).withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (chip['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          chip['icon'] as IconData,
                          color: chip['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chip['value'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chip['label'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Description Section ──────────────────────────────────
  Widget _buildDescriptionSection(String deskripsi) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('📖', 'Tentang Destinasi'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Decorative top accent
                Container(
                  width: 40,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                AnimatedCrossFade(
                  firstChild: Text(
                    deskripsi,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _textSecondary,
                      height: 1.75,
                      letterSpacing: 0.1,
                    ),
                  ),
                  secondChild: Text(
                    deskripsi,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _textSecondary,
                      height: 1.75,
                      letterSpacing: 0.1,
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? 'Sembunyikan' : 'Selengkapnya',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Gallery Section ──────────────────────────────────────
  Widget _buildGallerySection(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('🖼️', 'Galeri Foto'),
          const SizedBox(height: 14),
          SizedBox(height: 188, child: _buildGallery(data['gallery'] ?? '')),
        ],
      ),
    );
  }

  // ── Booking Bar (frosted glass) ──────────────────────────
  Widget _buildBookingBar(String harga, String name) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            border: Border(top: BorderSide(color: _divider, width: 1.5)),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.14),
                blurRadius: 28,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Harga
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Mulai dari',
                      style: TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      harga,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _primaryDark,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const Text(
                      '/orang',
                      style: TextStyle(
                        fontSize: 10,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Book button — gradient teal
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    // TODO: navigate to booking
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryDark, _primary, _primaryLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: _primaryLight.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'PESAN TIKET',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
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
      ),
    );
  }

  // ── Glass button helper ──────────────────────────────────
  Widget _glassButton({Widget? child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────
  Widget _sectionHeader(String emoji, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryDark, _primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Gallery horizontal ───────────────────────────────────
  Widget _buildGallery(String galleryString) {
    if (galleryString.isEmpty) {
      return Center(
        child: Text(
          'Galeri foto belum tersedia.',
          style: TextStyle(color: _textMuted, fontSize: 13),
        ),
      );
    }

    final images = galleryString.split(',');
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      itemBuilder: (context, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (i * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(20 * (1 - v), 0),
              child: child,
            ),
          ),
          child: Container(
            width: 230,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.13),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    images[i].trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _divider,
                      child: const Center(
                        child: Icon(
                          Icons.image_rounded,
                          color: _primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // subtle bottom vignette
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _primaryDark.withOpacity(0.40),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
