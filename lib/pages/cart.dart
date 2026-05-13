import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/pages/booking_page.dart';
import 'package:flutter_application_2/services/api_service.dart';

// ── Brand color palette (matching Tiket page: teal/mint/sage green) ──
class _C {
  static const primary      = Color(0xFF2DB89A); // teal hijau utama
  static const primaryLight = Color(0xFF4ECFB5); // teal terang
  static const primaryDark  = Color(0xFF1A9A80); // teal gelap
  static const accent       = Color(0xFF00C9A7); // mint accent
  static const surface      = Color(0xFFEFF9F6); // latar belakang mint pucat
  static const cardBg       = Colors.white;
  static const headerStart  = Color(0xFF2DB89A);
  static const headerEnd    = Color(0xFF7EDDD0);
  static const textPrimary  = Color(0xFF1A2E2A);
  static const textSecondary= Color(0xFF6B8C85);
  static const borderGlass  = Color(0xFFB2E4DA);
  static const redDelete    = Color(0xFFFF5C6A);
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  List<Map<String, dynamic>> _backendItems = [];
  bool _loadingCart = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    CartModel.instance.addListener(_refresh);
    _loadCartFromBackend();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  Future<void> _loadCartFromBackend() async {
    setState(() => _loadingCart = true);
    final data = await ApiService.getCart();
    setState(() {
      _backendItems = data;
      _loadingCart = false;
      CartModel.instance.clear();
      for (final item in data) {
        final priceInt = int.tryParse((item['price'] ?? 0).toString()) ?? 0;
        final hargaStr = _formatRupiah(priceInt);
        CartModel.instance.addItemWithQuantity({
          'name': (item['name'] ?? '').toString(),
          'loc': (item['location'] ?? '').toString(),
          'img': (item['image'] ?? item['img'] ?? '').toString(),
          'harga': hargaStr,
          'kategori': (item['category'] ?? item['kategori'] ?? '').toString(),
        }, int.tryParse(item['quantity'].toString()) ?? 1);
      }
    });
    _fadeCtrl.forward(from: 0);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    CartModel.instance.removeListener(_refresh);
    _fadeCtrl.dispose();
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

  void _checkout() {
    if (CartModel.instance.items.isEmpty) return;

    DateTime? tanggalMulai = _tanggalMulai;
    DateTime? tanggalSelesai = _tanggalSelesai;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pilihTanggal({required bool isStart}) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: isStart
                  ? (tanggalMulai ?? DateTime.now())
                  : (tanggalSelesai ??
                      (tanggalMulai ?? DateTime.now())
                          .add(const Duration(days: 1))),
              firstDate: isStart
                  ? DateTime.now()
                  : (tanggalMulai ?? DateTime.now())
                      .add(const Duration(days: 1)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _C.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: _C.textPrimary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setModalState(() {
                if (isStart) {
                  tanggalMulai = picked;
                  if (tanggalSelesai != null &&
                      !tanggalSelesai!.isAfter(picked)) {
                    tanggalSelesai = null;
                  }
                } else {
                  tanggalSelesai = picked;
                }
              });
              setState(() {
                if (isStart) {
                  _tanggalMulai = tanggalMulai;
                } else {
                  _tanggalSelesai = tanggalSelesai;
                }
              });
            }
          }

          String formatTanggal(DateTime? dt) {
            if (dt == null) return 'Pilih tanggal';
            const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
            const bulan = [
              'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
              'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
            ];
            return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
          }

          int hitungDurasi() {
            if (tanggalMulai == null || tanggalSelesai == null) return 0;
            return tanggalSelesai!.difference(tanggalMulai!).inDays + 1;
          }

          String namaHari(DateTime dt) {
            const hari = [
              'Senin', 'Selasa', 'Rabu', 'Kamis',
              'Jumat', 'Sabtu', 'Minggu'
            ];
            return hari[dt.weekday - 1];
          }

          final durasi = hitungDurasi();

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: _C.borderGlass.withOpacity(0.4)),
                ),
                padding: EdgeInsets.fromLTRB(
                  24, 12, 24,
                  MediaQuery.of(context).viewInsets.bottom + 36,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _C.borderGlass,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Ikon konfirmasi
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_C.primaryDark, _C.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _C.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Konfirmasi Pesanan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${CartModel.instance.totalItems} tiket · ${_formatRupiah(CartModel.instance.totalHarga)}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _C.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: _C.primaryDark),
                            const SizedBox(width: 5),
                            Text(
                              "Batas kunjungan 7 hari",
                              style: TextStyle(
                                fontSize: 11,
                                color: _C.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── FORM TANGGAL ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _C.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _C.borderGlass, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded,
                                    size: 15, color: _C.primaryDark),
                                const SizedBox(width: 6),
                                const Text(
                                  "Tanggal Kunjungan",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _C.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                // Tanggal Mulai
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => pilihTanggal(isStart: true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: tanggalMulai != null
                                              ? _C.primary
                                              : _C.borderGlass,
                                          width: tanggalMulai != null ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Mulai",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _C.textSecondary
                                                  .withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            formatTanggal(tanggalMulai),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: tanggalMulai != null
                                                  ? _C.primary
                                                  : _C.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Icon(Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: _C.textSecondary.withOpacity(0.5)),
                                ),

                                // Tanggal Selesai
                                Expanded(
                                  child: GestureDetector(
                                    onTap: tanggalMulai == null
                                        ? null
                                        : () => pilihTanggal(isStart: false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: tanggalMulai == null
                                            ? _C.surface
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: tanggalSelesai != null
                                              ? _C.primary
                                              : _C.borderGlass,
                                          width:
                                              tanggalSelesai != null ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Selesai",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _C.textSecondary
                                                  .withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            tanggalMulai == null
                                                ? 'Pilih mulai dulu'
                                                : formatTanggal(tanggalSelesai),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: tanggalSelesai != null
                                                  ? _C.primary
                                                  : _C.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (durasi > 0) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _C.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded,
                                        size: 14, color: _C.primaryDark),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "$durasi hari kunjungan  ·  "
                                        "${namaHari(tanggalMulai!)} – ${namaHari(tanggalSelesai!)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _C.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (durasi == 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Pilih tanggal mulai dan selesai kunjungan wisata",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _C.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Ringkasan item
                      ...CartModel.instance.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_C.primaryDark, _C.primaryLight],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.confirmation_number_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _C.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text("${item.quantity}x · ${item.loc}",
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: _C.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatRupiah(item.subtotal),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _C.primary),
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 8),
                      Divider(color: _C.borderGlass.withOpacity(0.6)),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _C.textSecondary)),
                          Text(
                            _formatRupiah(CartModel.instance.totalHarga),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _C.primary,
                                letterSpacing: -0.4),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tombol Bayar
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              (tanggalMulai == null || tanggalSelesai == null)
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingPage(
                                            items: CartModel.instance.items
                                                .toList(),
                                            tanggalMulai: tanggalMulai!,
                                            tanggalSelesai: tanggalSelesai!,
                                            totalHarga:
                                                CartModel.instance.totalHarga,
                                          ),
                                        ),
                                      );
                                    },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (tanggalMulai == null || tanggalSelesai == null)
                                    ? const Color(0xFFD8EDE9)
                                    : _C.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: (tanggalMulai == null ||
                                    tanggalSelesai == null)
                                ? 0
                                : 4,
                            shadowColor: _C.primary.withOpacity(0.3),
                          ),
                          child: Text(
                            (tanggalMulai == null || tanggalSelesai == null)
                                ? "Pilih Tanggal Dulu"
                                : "Bayar Sekarang",
                            style: TextStyle(
                              color: (tanggalMulai == null ||
                                      tanggalSelesai == null)
                                  ? _C.textSecondary
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal",
                            style: TextStyle(
                                color: _C.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = CartModel.instance.items;

    return Scaffold(
      backgroundColor: _C.surface,
      body: Stack(
        children: [
          // ── Header gradient (teal-mint, mirip screenshot) ──
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_C.headerStart, _C.headerEnd],
              ),
            ),
          ),

          // Dekoratif lingkaran glassmorphism di header
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── APP BAR ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.8)),
                              const SizedBox(width: 5),
                              Text(
                                "Keranjang",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tiket Wisatamu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),
                        ],
                      ),

                      // Tombol hapus semua
                      if (items.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                title: const Text("Kosongkan Keranjang?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: _C.textPrimary)),
                                content: const Text(
                                    "Semua tiket di keranjang akan dihapus.",
                                    style: TextStyle(
                                        fontSize: 13, color: _C.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Batal",
                                        style: TextStyle(
                                            color: _C.textSecondary,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      CartModel.instance.clear();
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _C.redDelete,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: const Text("Hapus",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline_rounded,
                                        color: Colors.white, size: 17),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${items.length} item",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── CONTENT AREA ──
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: _loadingCart
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: _C.primary, strokeWidth: 2.5),
                          )
                        : items.isEmpty
                            ? _buildEmptyState()
                            : FadeTransition(
                                opacity: _fadeAnim,
                                child: _buildCartList(items),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── FLOATING CHECKOUT BAR ──
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Total harga
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontSize: 11,
                            color: _C.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatRupiah(CartModel.instance.totalHarga),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Checkout
                  GestureDetector(
                    onTap: _checkout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.primaryDark, _C.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _C.primary.withOpacity(0.40),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Bayar Sekarang",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── CART LIST ──
  Widget _buildCartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + index * 80),
          curve: Curves.easeOut,
          builder: (context, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - val)),
              child: child,
            ),
          ),
          child: _buildCartCard(items[index]),
        );
      },
    );
  }

  // ── CART CARD ──
  Widget _buildCartCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon tiket
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.primaryDark, _C.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: _C.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                // Nama & lokasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 12, color: _C.primary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.loc,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Badge kategori
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.kategori,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _C.primaryDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dashed divider (tiket style)
            Row(
              children: List.generate(
                36,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i % 2 == 0
                        ? Colors.transparent
                        : _C.borderGlass.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Jumlah tiket badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _C.borderGlass),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_alt_outlined,
                          size: 13, color: _C.primaryDark),
                      const SizedBox(width: 5),
                      Text(
                        "${item.quantity} tiket",
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Harga + tombol hapus
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Subtotal",
                          style: TextStyle(
                            fontSize: 10,
                            color: _C.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatRupiah(item.subtotal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.primary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () =>
                          CartModel.instance.removeItem(item.name),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _C.redDelete.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 18,
                            color: _C.redDelete.withOpacity(0.8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 46,
              color: _C.primary.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            "Keranjang Kosong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tambahkan tiket dari halaman wisata",
            style: TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
        ],
      ),
    );
  }
}