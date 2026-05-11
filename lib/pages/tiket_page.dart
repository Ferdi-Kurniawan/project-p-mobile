import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../models/cart_models.dart';

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

  List<Map<String, dynamic>> _villages = [];
  bool _loading = true;

  // 2026 Bright Palette
  final Color _mintGreen = const Color(0xFFD5F5E3);
  final Color _skyBlue = const Color(0xFFD6EAF8);
  final Color _charcoal = const Color(0xFF333333);
  final Color _tealAccent = const Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward();
    fetchData();
  }

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  void fetchData() async {
    final data = await ApiService.getProducts();
    if (!mounted) return;
    setState(() {
      _villages = List<Map<String, dynamic>>.from(
        data.map((item) {
          final kategori = item['category'] is Map
              ? (item['category']['name'] ?? 'Wisata').toString()
              : (item['category'] ?? 'Wisata').toString();

          return {
            'id': item['id'].toString(),
            'name': (item['name'] ?? 'Wisata').toString(),
            'harga': _formatRupiah(int.tryParse((item['price'] ?? 0).toString()) ?? 0),
            'hargaNum': (item['price'] ?? 0).toString(),
            'kategori': kategori,
            'loc': (item['location'] ?? 'Indonesia').toString(),
            'deskripsi': (item['description'] ?? '').toString(),
            'img': (item['image'] ?? '').toString(),
            'icon': '🏔️',
          };
        }),
      );
      _loading = false;
    });
  }

  void _showCheckoutSheet(Map<String, dynamic> wisata) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutSheet(
        wisata: Map<String, String>.from(
          wisata.map((k, v) => MapEntry(k, v.toString())),
        ),
        formatRupiah: _formatRupiah,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background: Bright Airy Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, _mintGreen.withOpacity(0.3), _skyBlue.withOpacity(0.3)],
              ),
            ),
          ),
          
          // Background 3D-like Decorative Elements
          Positioned(top: 50, right: -30, child: _decorativeCircle(120, _mintGreen.withOpacity(0.5))),
          Positioned(bottom: 150, left: -40, child: _decorativeCircle(180, _skyBlue.withOpacity(0.5))),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: _loading 
                    ? Center(child: CircularProgressIndicator(color: _tealAccent))
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            itemCount: _villages.length,
                            itemBuilder: (context, index) => _buildPremiumGlassCard(_villages[index]),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "E-TIKET PARIWISATA",
            style: TextStyle(
              color: _tealAccent,
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Jelajahi Indonesia",
            style: TextStyle(
              color: _charcoal,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGlassCard(Map<String, dynamic> wisata) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            ),
            child: Column(
              children: [
                // Glossy Image Section
                Stack(
                  children: [
                    wisata['img'].toString().isNotEmpty
                        ? Image.network(
                            wisata['img'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            color: _mintGreen,
                            child: Center(child: Text(wisata['icon'], style: const TextStyle(fontSize: 50))),
                          ),
                    // High-fidelity shine overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(top: 20, right: 20, child: _glassBadge(wisata['kategori'])),
                  ],
                ),
                
                // Content Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wisata['name'],
                                  style: TextStyle(color: _charcoal, fontSize: 22, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 16, color: _tealAccent),
                                    const SizedBox(width: 4),
                                    Text(wisata['loc'], style: TextStyle(color: _charcoal.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Mulai dari", style: TextStyle(color: _charcoal.withOpacity(0.4), fontSize: 10)),
                              Text(wisata['harga'], style: TextStyle(color: _tealAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Pesan Tiket Button - Refreshing Mint Gradient
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCheckoutSheet(wisata);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color(0xFF1ABC9C), const Color(0xFF3498DB).withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _tealAccent.withOpacity(0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "PESAN TIKET",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassBadge(String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.white.withOpacity(0.3),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Checkout Bottom Sheet - Bright Airy Version
// ─────────────────────────────────────────────────────────────────

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

  void _submit() async {
    final success = await ApiService.addToCart(widget.wisata['id']!, _jumlah);
    if (success) CartModel.instance.addItemWithQuantity(widget.wisata, _jumlah);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Tiket masuk keranjang!" : "Gagal memproses"),
        backgroundColor: success ? const Color(0xFF1ABC9C) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 20, 30, MediaQuery.of(context).viewInsets.bottom + 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 30),
          Text(widget.wisata['name']!, style: const TextStyle(color: Color(0xFF333333), fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _qtyBtn(Icons.remove, _jumlah > 1, () => setState(() => _jumlah--)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text("$_jumlah", style: const TextStyle(color: Color(0xFF333333), fontSize: 48, fontWeight: FontWeight.w900)),
              ),
              _qtyBtn(Icons.add, true, () => setState(() => _jumlah++)),
            ],
          ),
          const SizedBox(height: 45),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
              Text(widget.formatRupiah(_totalHarga), style: const TextStyle(color: Color(0xFF1ABC9C), fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1ABC9C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              ),
              child: const Text("KONFIRMASI PEMESANAN", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1ABC9C).withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: enabled ? const Color(0xFF1ABC9C) : Colors.grey[300], size: 28),
      ),
    );
  }
}