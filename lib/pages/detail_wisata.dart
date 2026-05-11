import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ════════════════════════════════════════════════════════
//  Design Tokens — sama persis dengan HomePage
// ════════════════════════════════════════════════════════
const Color _primary       = Color(0xFF0064D2);
const Color _primaryLight  = Color(0xFF3B8AFF);
const Color _accent        = Color(0xFFFF6900);
const Color _bgPage        = Color(0xFFF0F4FA);
const Color _bgCard        = Color(0xFFFFFFFF);
const Color _textPrimary   = Color(0xFF0A1629);
const Color _textSecondary = Color(0xFF6B7A99);
const Color _textMuted     = Color(0xFFAAB4C8);
const Color _divider       = Color(0xFFE8EDF5);

// ════════════════════════════════════════════════════════
//  Deskripsi lengkap per wisata
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

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data      = widget.data;
    final name      = data['name'] ?? '';
    final deskripsi = _getDeskripsiLengkap(name);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bgPage,
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── Hero SliverAppBar ──────────────────────────────
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                stretch: true,
                backgroundColor: _primary,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 1.2),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 1.2),
                      ),
                      child: const Icon(Icons.bookmark_border_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(children: [
                    // Foto hero
                    Positioned.fill(
                      child: Image.asset(
                        data['img'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_primary, _primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                              child: Icon(Icons.image_rounded,
                                  color: Colors.white, size: 64)),
                        ),
                      ),
                    ),
                    // Multi-layer gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x33000000),
                              Color(0x00000000),
                              Color(0x88000000),
                              Color(0xDD001A4D),
                            ],
                            stops: [0.0, 0.3, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Nama + lokasi di atas foto
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
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                    color: _primary.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ],
                            ),
                            child: Text(data['kategori'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4)),
                          ),
                          const SizedBox(height: 10),
                          // Nama wisata
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                    color: Colors.black54,
                                    blurRadius: 12,
                                    offset: Offset(0, 3))
                              ],
                            ),
                          ),
                          const SizedBox(height: 7),
                          // Lokasi
                          Row(children: [
                            const Icon(Icons.location_on_rounded,
                                color: _accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              data['loc'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(color: Colors.black45, blurRadius: 6)
                                ],
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Body konten ───────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Info chips: Rating / Ulasan / Kategori ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(children: [
                        _infoChip(Icons.star_rounded,
                            const Color(0xFFFBBF24),
                            data['rating'] ?? '4.5',
                            'Rating'),
                        const SizedBox(width: 12),
                        _infoChip(Icons.chat_bubble_rounded, _primary,
                            data['review'] ?? '-', 'Ulasan'),
                        const SizedBox(width: 12),
                        _infoChip(Icons.category_rounded, _accent,
                            data['kategori'] ?? '-', 'Kategori'),
                      ]),
                    ),

                    // ── Tentang Destinasi ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('📖', 'Tentang Destinasi'),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _bgCard,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: _divider, width: 1),
                              boxShadow: [
                                BoxShadow(
                                    color: _primary.withOpacity(0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedCrossFade(
                                  firstChild: Text(
                                    deskripsi,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: _textSecondary,
                                        height: 1.65),
                                  ),
                                  secondChild: Text(
                                    deskripsi,
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: _textSecondary,
                                        height: 1.65),
                                  ),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 280),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _isExpanded = !_isExpanded),
                                  child: Row(children: [
                                    Text(
                                      _isExpanded
                                          ? 'Sembunyikan'
                                          : 'Selengkapnya',
                                      style: const TextStyle(
                                          color: _primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      _isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: _primary,
                                      size: 16,
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Galeri Foto ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('🖼️', 'Galeri Foto'),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 180,
                            child: _buildGallery(data['gallery'] ?? ''),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info chip ────────────────────────────────────────
  Widget _infoChip(IconData icon, Color color, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider, width: 1),
          boxShadow: [
            BoxShadow(
                color: _primary.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 7),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.3)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ── Section header ───────────────────────────────────
  Widget _sectionHeader(String emoji, String title) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, _primaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(emoji, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 6),
      Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.2)),
    ]);
  }

  // ── Galeri horizontal ────────────────────────────────
  Widget _buildGallery(String galleryString) {
    if (galleryString.isEmpty) {
      return Center(
        child: Text('Galeri foto belum tersedia.',
            style: TextStyle(color: _textMuted, fontSize: 13)),
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
                offset: Offset(20 * (1 - v), 0), child: child),
          ),
          child: Container(
            width: 230,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: _primary.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                images[i].trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE6F0FF),
                  child: const Center(
                      child: Icon(Icons.image_rounded,
                          color: _primary, size: 40)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}