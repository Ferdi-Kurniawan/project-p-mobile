import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/pages/booking_page.dart';
import 'package:flutter_application_2/services/api_service.dart';

// ════════════════════════════════════════════════════════
//  DESIGN TOKENS — sama persis dengan home_page.dart
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

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    CartModel.instance.addListener(_refresh);
    _syncCartFromServer(); // ← logika asli tidak diubah

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  // ── TIDAK DIUBAH ──
  Future<void> _syncCartFromServer() async {
    try {
      final serverCart = await ApiService.getCart();
      if (serverCart.isNotEmpty) {
        CartModel.instance.updateItemsFromServer(serverCart);
      }
    } catch (e) {
      print("SYNC CART ERROR: $e");
    }
  }

  @override
  void dispose() {
    CartModel.instance.removeListener(_refresh);
    _pulseController.dispose();
    super.dispose();
  }

  // ── TIDAK DIUBAH ──
  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  // ════════════════════════════════════════════════════════
  //  _checkout — TIDAK DIUBAH (logika + navigasi asli)
  //  Hanya warna UI dalam sheet yang disesuaikan ke teal
  // ════════════════════════════════════════════════════════
  void _checkout() {
    if (CartModel.instance.items.isEmpty) return;

    DateTime? tanggalMulai   = _tanggalMulai;
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
                    primary: _T.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: _T.textHead,
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
            const hari   = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
            const bulan  = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
            return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
          }

          int hitungDurasi() {
            if (tanggalMulai == null || tanggalSelesai == null) return 0;
            return tanggalSelesai!.difference(tanggalMulai!).inDays + 1;
          }

          String namaHari(DateTime dt) {
            const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
            return hari[dt.weekday - 1];
          }

          final durasi = hitungDurasi();
          final allFilled = tanggalMulai != null && tanggalSelesai != null;

          return Container(
            decoration: const BoxDecoration(
              color: _T.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
              24, 12, 24,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: _T.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon konfirmasi
                  Container(
                    width: 72, height: 72,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: _T.headerGrad),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Konfirmasi Pesanan",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _T.textHead),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${CartModel.instance.totalItems} tiket · ${_formatRupiah(CartModel.instance.totalHarga)}",
                    style: const TextStyle(fontSize: 14, color: _T.textBody),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: _T.primary),
                      const SizedBox(width: 4),
                      const Text(
                        "Batas kunjungan 7 hari",
                        style: TextStyle(
                            fontSize: 12,
                            color: _T.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Form Tanggal ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _T.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _T.divider, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_month_rounded,
                              size: 16, color: _T.primaryDark),
                          const SizedBox(width: 6),
                          const Text(
                            "Tanggal Kunjungan",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _T.primaryDark),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => pilihTanggal(isStart: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _T.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tanggalMulai != null
                                        ? _T.primary
                                        : _T.divider,
                                    width: tanggalMulai != null ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Mulai",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _T.textMuted,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text(
                                      formatTanggal(tanggalMulai),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: tanggalMulai != null
                                            ? _T.primary
                                            : _T.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: _T.textMuted),
                          ),
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
                                      ? const Color(0xFFF4F4F4)
                                      : _T.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tanggalSelesai != null
                                        ? _T.primary
                                        : _T.divider,
                                    width: tanggalSelesai != null ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Selesai",
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _T.textMuted,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 3),
                                    Text(
                                      tanggalMulai == null
                                          ? 'Pilih mulai dulu'
                                          : formatTanggal(tanggalSelesai),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: tanggalSelesai != null
                                            ? _T.primary
                                            : _T.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),

                        if (durasi > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _T.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 14, color: _T.primaryDark),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "$durasi hari kunjungan  ·  ${namaHari(tanggalMulai!)} – ${namaHari(tanggalSelesai!)}",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _T.primaryDark),
                                ),
                              ),
                            ]),
                          ),
                        ],
                        if (durasi == 0) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Pilih tanggal mulai dan selesai kunjungan wisata",
                            style: TextStyle(fontSize: 11, color: _T.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Item list dalam sheet
                  ...CartModel.instance.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: _T.headerGrad),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                                Icons.confirmation_number_rounded,
                                color: Colors.white,
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _T.textHead),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                  "${item.quantity}x · ${item.loc}",
                                  style: const TextStyle(
                                      fontSize: 11, color: _T.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatRupiah(item.subtotal),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _T.primary),
                          ),
                        ]),
                      )),

                  const SizedBox(height: 8),
                  Divider(color: _T.divider, thickness: 1),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _T.textBody)),
                      ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          colors: _T.headerGrad,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(r),
                        child: Text(
                          _formatRupiah(CartModel.instance.totalHarga),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // CTA Bayar — logika asli TIDAK DIUBAH
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: GestureDetector(
                      onTap: allFilled
                          ? () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingPage(
                                    bookingId:
                                        "DRAFT_${DateTime.now().millisecondsSinceEpoch}",
                                    items: CartModel.instance.items.toList(),
                                    tanggalMulai: tanggalMulai!,
                                    tanggalSelesai: tanggalSelesai!,
                                    totalHarga:
                                        CartModel.instance.totalHarga,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: allFilled
                              ? const LinearGradient(
                                  colors: _T.headerGrad,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight)
                              : null,
                          color: allFilled ? null : _T.divider,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: allFilled
                              ? [
                                  BoxShadow(
                                      color: _T.primary.withOpacity(0.32),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5))
                                ]
                              : [],
                        ),
                        child: Text(
                          allFilled
                              ? "Bayar Sekarang"
                              : "Pilih Tanggal Dulu",
                          style: TextStyle(
                            color: allFilled ? Colors.white : _T.textMuted,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal",
                        style: TextStyle(
                            color: _T.textMuted, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final items = CartModel.instance.items;

    return Scaffold(
      backgroundColor: _T.bgPage,
      bottomNavigationBar: null, // ← TIDAK DIUBAH: sesuai kode asli
      body: Stack(children: [

        // ── Teal gradient header ──
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

        // ── Dekorasi lingkaran header ──
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
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          top: 80, left: -20,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        SafeArea(
          child: Column(children: [

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Keranjang",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                          ),
                        ),
                        Text(
                          "Tiket Wisatamu",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ]),

                  // Tombol hapus semua — logika asli TIDAK DIUBAH
                  if (items.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text(
                              "Kosongkan Keranjang?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16,
                                  color: _T.textHead),
                            ),
                            content: const Text(
                              "Semua tiket di keranjang akan dihapus.",
                              style: TextStyle(fontSize: 13, color: _T.textBody),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal",
                                    style: TextStyle(
                                        color: _T.textMuted,
                                        fontWeight: FontWeight.w600)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  CartModel.instance.clear(); // ← asli
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.30), width: 1),
                        ),
                        child: Row(children: [
                          const Icon(Icons.delete_outline_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "${items.length} item",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
            ),

            // Stats row kecil di header
            if (items.isNotEmpty) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(children: [
                  _headerStat("${items.length}", "Tiket"),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      width: 1, height: 24,
                      color: Colors.white.withOpacity(0.25)),
                  _headerStat(
                      _formatRupiah(CartModel.instance.totalHarga), "Total"),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      width: 1, height: 24,
                      color: Colors.white.withOpacity(0.25)),
                  _headerStat(
                      "${CartModel.instance.totalItems}", "Pax"),
                ]),
              ),
            ],
            const SizedBox(height: 18),

            // ── List area ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: _T.bgPage,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: items.isEmpty
                    ? _buildEmptyState()
                    : _buildCartList(items),
              ),
            ),

            // ── Checkout panel bawah — posisi TIDAK DIUBAH (di atas nav global) ──
            if (items.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  color: _T.bgCard,
                  boxShadow: [
                    BoxShadow(
                        color: _T.primary.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, -6)),
                  ],
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Pembayaran",
                            style: TextStyle(
                                fontSize: 12,
                                color: _T.textMuted,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            colors: _T.headerGrad,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(r),
                          child: Text(
                            _formatRupiah(CartModel.instance.totalHarga),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _checkout();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: _T.headerGrad,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: _T.primary.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_checkout_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Checkout",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CART LIST
  // ════════════════════════════════════════════════════════
  Widget _buildCartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
                offset: Offset(0, 16 * (1 - value)), child: child),
          ),
          child: _buildCartCard(items[index]),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════
  //  CART CARD — tanpa gambar, ikon teal
  // ════════════════════════════════════════════════════════
  Widget _buildCartCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _T.divider, width: 1),
        boxShadow: [
          BoxShadow(
              color: _T.primary.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Baris atas: ikon + info + kategori badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon teal dengan nomor urut
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: _T.headerGrad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: _T.primary.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _T.textHead),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: _T.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            item.loc,
                            style: const TextStyle(
                                fontSize: 12,
                                color: _T.textBody,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // Kategori badge — teal
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _T.primarySurface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                        color: _T.primary.withOpacity(0.20), width: 1),
                  ),
                  child: Text(
                    item.kategori,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _T.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Garis putus-putus
            Row(
              children: List.generate(
                36,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i % 2 == 0
                        ? Colors.transparent
                        : _T.divider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Baris bawah: jumlah tiket + harga + hapus ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Jumlah tiket chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _T.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _T.divider, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          size: 13, color: _T.primary),
                      const SizedBox(width: 5),
                      Text(
                        "${item.quantity} tiket",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _T.primaryDark),
                      ),
                    ],
                  ),
                ),

                Row(children: [
                  // Harga subtotal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Total Harga",
                          style: TextStyle(
                              fontSize: 10,
                              color: _T.textMuted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          colors: _T.headerGrad,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(r),
                        child: Text(
                          _formatRupiah(item.subtotal),
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Tombol hapus — logika TIDAK DIUBAH
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      CartModel.instance.removeItem(item.productId); // ← asli
                    },
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: Colors.red.withOpacity(0.15), width: 1),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.red.shade400),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Stat kecil di header ──
  Widget _headerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Empty state ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _T.primarySurface,
                border: Border.all(
                    color: _T.primary.withOpacity(0.15), width: 2),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 44, color: _T.primary),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Keranjang Kosong",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _T.textHead),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tambahkan tiket dari halaman wisata",
            style: TextStyle(fontSize: 13, color: _T.textBody),
          ),
        ],
      ),
    );
  }
}