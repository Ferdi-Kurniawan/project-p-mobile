import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/services/api_service.dart';

// ════════════════════════════════════════════════════════
//  DESIGN TOKENS — Konsisten dengan tema aplikasi
// ════════════════════════════════════════════════════════
class _T {
  static const Color primary        = Color(0xFF00B09B);
  static const Color primaryDark    = Color(0xFF007A6A);
  static const Color primaryLight   = Color(0xFF4DD9C9);
  static const Color primarySurface = Color(0xFFE0F7F4);
  static const List<Color> headerGrad = [Color(0xFF00B09B), Color(0xFF00D2B4)];
  static const Color accent         = Color(0xFFFF6B35);
  static const Color accentSoft     = Color(0xFFFFF0EB);
  static const Color bgPage         = Color(0xFFF2FAF9);
  static const Color bgCard         = Color(0xFFFFFFFF);
  static const Color textHead       = Color(0xFF0D2B26);
  static const Color textBody       = Color(0xFF4A6B66);
  static const Color textMuted      = Color(0xFFA0B8B5);
  static const Color divider        = Color(0xFFDCF0EE);
}

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});
  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  List<Map<String, String>> _villages = [];
  bool _isLoadingProducts = true;
  
  // LOGIKA KATEGORI DINAMIS
  String _selectedFilter = 'Semua';
  List<String> _filterChips = ['Semua']; // Inisialisasi dengan 'Semua' saja dulu

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    
    _animController.forward();
    
    // Panggil kedua fungsi data
    _loadCategories(); 
    _loadProducts();
  }

  // ── MENGAMBIL KATEGORI DARI API ──
  Future<void> _loadCategories() async {
    final categories = await ApiService.getCategories();
    if (categories.isNotEmpty) {
      setState(() {
        // Ambil nama kategori dan gabungkan dengan 'Semua'
        _filterChips = ['Semua', ...categories.map((c) => c['name'].toString())];
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    final products = await ApiService.getProducts();

    if (products.isNotEmpty) {
      final List<Map<String, String>> loaded = [];
      for (var p in products) {
        final categoryName = p['category'] != null ? p['category']['name'] : 'Umum';
        loaded.add({
          'productId'  : p['id'].toString(),
          'name'       : p['name'].toString(),
          'harga'      : _formatRupiah(p['price'] ?? 0),
          'hargaNum'   : (p['price'] ?? 0).toString(),
          'kategori'   : categoryName.toString(),
          'deskripsi'  : 'Tiket masuk wisata.',
        });
      }
      setState(() {
        _villages = loaded;
        _isLoadingProducts = false;
      });
    } else {
      setState(() {
        _villages = []; // Kosongkan jika API gagal
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  void _showCheckoutSheet(Map<String, String> wisata) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        wisata: wisata,
        formatRupiah: _formatRupiah,
      ),
    );
  }

  List<Map<String, String>> get _filteredVillages {
    if (_selectedFilter == 'Semua') return _villages;
    return _villages.where((v) => v['kategori'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bgPage,
      body: Stack(children: [
        // Header Gradient
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _T.headerGrad,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            // Header Content
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.38), width: 1.3),
                      ),
                      child: const Center(child: Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20)),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pesan Tiket", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text("Pilih destinasi wisatamu", style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ]),
                  IconButton(
                    onPressed: () { _loadProducts(); _loadCategories(); },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Statistics Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(children: [
                _headerStat("${_villages.length}", "Destinasi"),
                const SizedBox(width: 14),
                _headerStat("10rb+", "Wisatawan"),
                const SizedBox(width: 14),
                _headerStat("4.9★", "Rating"),
              ]),
            ),
            const SizedBox(height: 14),
            // Main List Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _T.bgPage,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: _isLoadingProducts
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Destinasi Tersedia", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _T.textHead)),
                            const SizedBox(height: 14),
                            // Filter Chips Dinamis
                            SizedBox(
                              height: 36,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _filterChips.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final chip = _filterChips[i];
                                  final isSelected = _selectedFilter == chip;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedFilter = chip),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected ? const LinearGradient(colors: _T.headerGrad) : null,
                                        color: isSelected ? null : _T.bgCard,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: isSelected ? Colors.transparent : _T.divider),
                                      ),
                                      child: Text(chip, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : _T.textBody)),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Wisata Cards
                            if (_filteredVillages.isEmpty)
                              const Center(child: Text("Tidak ada destinasi di kategori ini"))
                            else
                              ..._filteredVillages.map((wisata) => _buildWisataCard(wisata)),
                          ],
                        ),
                      ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildWisataCard(Map<String, String> wisata) {
    return GestureDetector(
      onTap: () => _showCheckoutSheet(wisata),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: _T.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _T.divider, width: 1),
          boxShadow: [BoxShadow(color: _T.primary.withOpacity(0.09), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: _T.headerGrad),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
            ),
            child: const Center(child: Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 64)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(wisata['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _T.textHead)),
                      const SizedBox(height: 4),
                      Text(wisata['kategori']!, style: const TextStyle(fontSize: 12, color: _T.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(wisata['deskripsi']!, maxLines: 2, style: const TextStyle(fontSize: 12, color: _T.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(wisata['harga']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _T.accent)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showCheckoutSheet(wisata),
                      style: ElevatedButton.styleFrom(backgroundColor: _T.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Beli", style: TextStyle(color: Colors.white, fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 10)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
//  CHECKOUT SHEET — Sesuai permintaan (Logika tetap)
// ════════════════════════════════════════════════════════
class _CheckoutSheet extends StatefulWidget {
  final Map<String, String> wisata;
  final String Function(int) formatRupiah;

  const _CheckoutSheet({required this.wisata, required this.formatRupiah});

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  int _jumlah = 1;
  int get _hargaBase => int.tryParse(widget.wisata['hargaNum'] ?? '0') ?? 0;
  int get _totalHarga => _hargaBase * _jumlah;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDCF0EE),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Wisata Info
          Text(
            widget.wisata['name'] ?? 'Destinasi', 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 20),
          
          // Qty Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () { if(_jumlah > 1) setState(() => _jumlah--); }, 
                icon: const Icon(Icons.remove_circle_outline)
              ),
              Text("$_jumlah", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => setState(() => _jumlah++), 
                icon: const Icon(Icons.add_circle_outline)
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Total Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total"),
              Text(
                widget.formatRupiah(_totalHarga), 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00B09B))
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tombol Submit (Perbaikan Null Safety ada di sini)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await CartModel.instance.addItem({
                  'productId': widget.wisata['productId'] ?? '', // Tambahkan ?? ''
                  'name': widget.wisata['name'] ?? '',           // Tambahkan ?? ''
                  'hargaNum': widget.wisata['hargaNum'] ?? '0',   // Tambahkan ?? '0'
                  'kategori': widget.wisata['kategori'] ?? '',   // Tambahkan ?? ''
                }, _jumlah);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B09B), 
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Tambah ke Keranjang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}