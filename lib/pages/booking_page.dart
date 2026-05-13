import 'package:flutter_application_2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';

// ══════════════════════════════════════════════════════
//  COLOR PALETTE  — matches the teal/green ticket page
// ══════════════════════════════════════════════════════
class _C {
  // Primary teal (from "Pesan Tiket Sekarang" button)
  static const teal        = Color(0xFF00897B);   // teal-700
  static const tealLight   = Color(0xFF4DB6AC);   // teal-300
  static const tealDark    = Color(0xFF00695C);   // teal-800
  // Background / surface
  static const bg          = Color(0xFFF0FAF9);   // very light teal tint
  static const surface     = Colors.white;
  static const surfaceCard = Color(0xFFF7FDFC);
  // Text
  static const charcoal    = Color(0xFF1A2E2C);
  static const grey        = Color(0xFF607D8B);
  static const greyLight   = Color(0xFFB0BEC5);
  // Accent
  static const green       = Color(0xFF43A047);
  static const red         = Color(0xFFE53935);
  // Glass card stroke
  static const stroke      = Color(0xFFB2DFDB);
}

// ══════════════════════════════════════════════════════

class BookingPage extends StatefulWidget {
  final List<CartItem> items;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHarga;

  BookingPage({
    super.key,
    List<CartItem>? items,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    this.totalHarga = 0,
  })  : items = items ?? const [],
        tanggalMulai = tanggalMulai ?? DateTime.now(),
        tanggalSelesai = tanggalSelesai ?? DateTime.now();

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  String? _selectedMetode;
  String? _selectedBank;
  bool _isLoading = false;
  String? _bookingIdFromBackend;

  late AnimationController _shimmerCtrl;

  static const Map<String, int> _adminFee = {
    'Transfer Bank': 4500,
    'QRIS': 0,
    'GoPay': 1000,
    'OVO': 1000,
    'Dana': 1000,
    'ShopeePay': 1000,
  };

  static const List<Map<String, String>> _banks = [
    {'name': 'BCA',     'norek': '1234567890'},
    {'name': 'Mandiri', 'norek': '0987654321'},
    {'name': 'BNI',     'norek': '1122334455'},
    {'name': 'BRI',     'norek': '5566778899'},
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────
  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatTanggal(DateTime dt) {
    const hari  = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const bulan = ['Januari','Februari','Maret','April','Mei','Juni',
                   'Juli','Agustus','September','Oktober','November','Desember'];
    return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  String _shortDate(DateTime dt) {
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun',
                   'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  int get _durasi =>
      widget.tanggalSelesai.difference(widget.tanggalMulai).inDays + 1;
  int get _adminFeeAmount => _adminFee[_selectedMetode] ?? 0;
  int get _totalBayar     => widget.totalHarga + _adminFeeAmount;

  String get _bookingCode {
    final now = DateTime.now();
    return 'WS${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  // ── API ──────────────────────────────────────────────
  Future<void> _prosesBooking() async {
    if (mounted) Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.createBooking(
        startDate: widget.tanggalMulai.toIso8601String(),
        endDate:   widget.tanggalSelesai.toIso8601String(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (result != null) {
        _bookingIdFromBackend = result['id']?.toString() ?? _bookingCode;
        _showSuksesSheet();
      } else {
        _showErrorSnackbar('Gagal membuat booking. Coba lagi.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackbar('Terjadi kesalahan. Periksa koneksi internet kamu.');
    }
  }

  // ── Snackbars ────────────────────────────────────────
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: _C.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showWarningSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: Colors.orange.shade700,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ══════════════════════════════════════════════════════
  //  PAYMENT BOTTOM SHEET
  // ══════════════════════════════════════════════════════
  void _showMetodePembayaran() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 12, 24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 44, height: 5,
                    decoration: BoxDecoration(
                      color: _C.greyLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // header
                Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.teal, _C.tealLight],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.payment_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Metode Pembayaran',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.charcoal)),
                    Text('Pilih cara pembayaran kamu',
                        style: TextStyle(fontSize: 12, color: _C.grey)),
                  ]),
                ]),
                const SizedBox(height: 24),

                // Transfer Bank
                _metodeGroup(
                  setSheetState: setSheetState,
                  label: 'Transfer Bank',
                  icon: Icons.account_balance_rounded,
                  child: _selectedMetode == 'Transfer Bank'
                      ? Column(
                          children: _banks.map((bank) {
                            final isSel = _selectedBank == bank['name'];
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() => _selectedBank = bank['name']);
                                setState(() => _selectedBank = bank['name']);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? _C.teal.withOpacity(0.06)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: isSel ? _C.teal : Colors.grey.shade200,
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? _C.teal.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Center(child: Text(bank['name']!,
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: isSel
                                                ? _C.teal
                                                : _C.grey))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Bank ${bank['name']}',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: isSel
                                                  ? _C.teal
                                                  : _C.charcoal)),
                                      Text('No. Rek: ${bank['norek']}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: _C.grey)),
                                    ],
                                  )),
                                  if (isSel)
                                    const Icon(Icons.check_circle_rounded,
                                        color: _C.teal, size: 20),
                                ]),
                              ),
                            );
                          }).toList(),
                        )
                      : null,
                ),
                const SizedBox(height: 10),

                // QRIS
                _metodeGroup(
                  setSheetState: setSheetState,
                  label: 'QRIS',
                  icon: Icons.qr_code_scanner_rounded,
                  badge: 'Gratis',
                  child: _selectedMetode == 'QRIS'
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(children: [
                            Icon(Icons.qr_code_2_rounded,
                                size: 82, color: _C.charcoal),
                            const SizedBox(height: 8),
                            Text('QR Code akan muncul setelah konfirmasi',
                                style: TextStyle(
                                    fontSize: 12, color: _C.grey),
                                textAlign: TextAlign.center),
                          ]),
                        )
                      : null,
                ),
                const SizedBox(height: 10),

                // E-Wallet
                _metodeGroup(
                  setSheetState: setSheetState,
                  label: 'E-Wallet',
                  icon: Icons.account_balance_wallet_rounded,
                  child: _selectedMetode == 'E-Wallet'
                      ? Column(
                          children: ['GoPay', 'OVO', 'Dana', 'ShopeePay']
                              .map((w) {
                            final isSel = _selectedBank == w;
                            return GestureDetector(
                              onTap: () {
                                setSheetState(() => _selectedBank = w);
                                setState(() => _selectedBank = w);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? _C.teal.withOpacity(0.06)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: isSel ? _C.teal : Colors.grey.shade200,
                                    width: isSel ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(children: [
                                  Icon(Icons.wallet_rounded,
                                      size: 20,
                                      color: isSel ? _C.teal : _C.grey),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(w,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSel ? _C.teal : _C.charcoal))),
                                  Text('+ ${_formatRupiah(_adminFee[w] ?? 0)}',
                                      style: TextStyle(
                                          fontSize: 11, color: _C.grey)),
                                  if (isSel) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check_circle_rounded,
                                        color: _C.teal, size: 20),
                                  ],
                                ]),
                              ),
                            );
                          }).toList(),
                        )
                      : null,
                ),
                const SizedBox(height: 28),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedMetode == null) {
                        _showWarningSnackbar('Pilih metode pembayaran dulu');
                        return;
                      }
                      if (_selectedMetode == 'Transfer Bank' &&
                          _selectedBank == null) {
                        _showWarningSnackbar('Pilih bank tujuan transfer');
                        return;
                      }
                      if (_selectedMetode == 'E-Wallet' &&
                          _selectedBank == null) {
                        _showWarningSnackbar('Pilih e-wallet yang ingin digunakan');
                        return;
                      }
                      _prosesBooking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.tealDark, _C.teal, _C.tealLight],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Center(
                          child: Text('Konfirmasi & Bayar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  SUCCESS BOTTOM SHEET
  // ══════════════════════════════════════════════════════
  void _showSuksesSheet() {
    final code = _bookingIdFromBackend ?? _bookingCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 44, height: 5,
                decoration: BoxDecoration(
                  color: _C.greyLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // success icon
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_C.teal, _C.tealLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _C.teal.withOpacity(0.30),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 54),
            ),
            const SizedBox(height: 22),

            const Text('Pembayaran Berhasil!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _C.charcoal)),
            const SizedBox(height: 6),
            Text('Tiket wisata kamu sudah dikonfirmasi',
                style: TextStyle(fontSize: 13, color: _C.grey)),
            const SizedBox(height: 26),

            // booking code card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _C.teal.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _C.teal.withOpacity(0.22), width: 1),
              ),
              child: Column(children: [
                Text('Kode Booking',
                    style: TextStyle(
                        fontSize: 12,
                        color: _C.grey,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(code,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.teal,
                          letterSpacing: 2.5)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Kode booking disalin!'),
                        backgroundColor: _C.teal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _C.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          size: 16, color: _C.teal),
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // info rows
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(children: [
                _infoRow('Metode', _selectedBank ?? _selectedMetode ?? '-'),
                const SizedBox(height: 10),
                _infoRow('Total Bayar', _formatRupiah(_totalBayar)),
                const SizedBox(height: 10),
                _infoRow('Kunjungan',
                    '${_shortDate(widget.tanggalMulai)} – '
                    '${_shortDate(widget.tanggalSelesai)} ($_durasi hari)'),
              ]),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  CartModel.instance.clear();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // ── Empty state jika dibuka dari bottom nav tanpa data ──
    if (widget.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0FAF9),
        body: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_C.tealDark, _C.teal, _C.tealLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PEMESANAN TIKET',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5)),
                SizedBox(height: 8),
                Text('Booking Tiket',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1)),
                SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text('Lampung',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 16),
                  Icon(Icons.confirmation_number_outlined,
                      color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text('Trip Nusa Desa',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: _C.teal.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      size: 52, color: _C.teal),
                ),
                const SizedBox(height: 26),
                const Text('Belum Ada Booking',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _C.charcoal)),
                const SizedBox(height: 10),
                const Text(
                  'Tambahkan tiket ke keranjang\nlalu lakukan checkout',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _C.grey),
                ),
              ]),
            ),
          ),
        ]),
      );
    }

    return Stack(children: [
      Scaffold(
        backgroundColor: _C.bg,
        body: Stack(children: [
          // ── Gradient header background ──
          _GradientHeader(),

          // ── Decorative circles ──
          Positioned(top: -50, right: -30,
              child: _Circle(size: 170, opacity: 0.08)),
          Positioned(top: 40, right: 70,
              child: _Circle(size: 85,  opacity: 0.06)),
          Positioned(top: 80, left: -20,
              child: _Circle(size: 110, opacity: 0.05)),

          SafeArea(
            child: Column(children: [
              // ── AppBar area ──
              _buildAppBar(),
              const SizedBox(height: 16),

              // ── Step progress ──
              _StepProgress(step: 1),
              const SizedBox(height: 18),

              // ── Content ──
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _C.bg,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 140),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _sectionTitle('Info Kunjungan',
                          Icons.calendar_month_rounded),
                      const SizedBox(height: 10),
                      _buildKunjunganCard(),
                      const SizedBox(height: 22),
                      _sectionTitle('Detail Tiket',
                          Icons.confirmation_number_rounded),
                      const SizedBox(height: 10),
                      ...widget.items.map((item) => _buildTiketCard(item)),
                      const SizedBox(height: 22),
                      _sectionTitle('Ringkasan Harga',
                          Icons.receipt_long_rounded),
                      const SizedBox(height: 10),
                      _buildHargaCard(),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ]),
        bottomNavigationBar: _buildBottomBar(),
      ),

      // ── Loading overlay ──
      if (_isLoading)
        Container(
          color: Colors.black.withOpacity(0.45),
          child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: Colors.white,
                  strokeWidth: 3),
              SizedBox(height: 18),
              Text('Memproses booking...',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
    ]);
  }

  // ── App Bar ──────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 4),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Konfirmasi',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const Text('Detail Pemesanan',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
        ]),
        const Spacer(),
        // ticket count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.30)),
          ),
          child: Row(children: [
            const Icon(Icons.confirmation_number_outlined,
                color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text('${widget.items.length} tiket',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ── Section title ────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: _C.teal.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: _C.teal),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _C.charcoal,
              letterSpacing: -0.2)),
    ]);
  }

  // ── Visit card ───────────────────────────────────────
  Widget _buildKunjunganCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(children: [
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Tanggal Mulai'),
              const SizedBox(height: 4),
              Text(_formatTanggal(widget.tanggalMulai),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.charcoal)),
            ],
          )),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _C.teal.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                size: 16, color: _C.teal),
          ),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _label('Tanggal Selesai'),
              const SizedBox(height: 4),
              Text(_formatTanggal(widget.tanggalSelesai),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.charcoal)),
            ],
          )),
        ]),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.tealDark, _C.teal],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _C.teal.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wb_sunny_rounded,
                color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text('$_durasi Hari Kunjungan',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }

  // ── Ticket card ──────────────────────────────────────
  Widget _buildTiketCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.tealDark, _C.tealLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _C.teal.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.confirmation_number_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _C.teal.withOpacity(0.09),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(item.kategori,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _C.teal)),
            ),
            const SizedBox(height: 5),
            Text(item.name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.charcoal),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_rounded,
                  size: 11, color: _C.tealLight),
              const SizedBox(width: 3),
              Expanded(child: Text(item.loc,
                  style: TextStyle(fontSize: 11, color: _C.grey),
                  overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${item.quantity}x tiket',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade600)),
                ),
                Text(_formatRupiah(item.subtotal),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _C.teal)),
              ],
            ),
          ],
        )),
      ]),
    );
  }

  // ── Price card ───────────────────────────────────────
  Widget _buildHargaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(children: [
        ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(
                      '${item.name} (${item.quantity}x)',
                      style: TextStyle(fontSize: 12, color: _C.grey),
                      overflow: TextOverflow.ellipsis)),
                  Text(_formatRupiah(item.subtotal),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.charcoal)),
                ],
              ),
            )),
        if (_selectedMetode != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Biaya admin (${_selectedBank ?? _selectedMetode})',
                    style: TextStyle(fontSize: 12, color: _C.grey)),
                Text(
                    _adminFeeAmount == 0
                        ? 'Gratis'
                        : _formatRupiah(_adminFeeAmount),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _adminFeeAmount == 0
                            ? _C.green
                            : _C.charcoal)),
              ],
            ),
          ),
        ],
        Divider(color: _C.stroke),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Pembayaran',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _C.charcoal)),
          Text(_formatRupiah(_totalBayar),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _C.teal)),
        ]),
      ]),
    );
  }

  // ── Bottom bar ───────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _C.teal.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft:  Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Row(children: [
        Expanded(child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Bayar',
                style: TextStyle(
                    fontSize: 11,
                    color: _C.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(_formatRupiah(_totalBayar),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.teal,
                    letterSpacing: -0.3)),
          ],
        )),
        GestureDetector(
          onTap: _showMetodePembayaran,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.tealDark, _C.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _C.teal.withOpacity(0.38),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text('Bayar Sekarang',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1)),
          ),
        ),
      ]),
    );
  }

  // ── Payment method group tile ────────────────────────
  Widget _metodeGroup({
    required StateSetter setSheetState,
    required String label,
    required IconData icon,
    String? badge,
    Widget? child,
  }) {
    final isSelected = _selectedMetode == label ||
        (label == 'E-Wallet' &&
            ['GoPay', 'OVO', 'Dana', 'ShopeePay'].contains(_selectedMetode));

    return GestureDetector(
      onTap: () {
        setSheetState(() {
          if (_selectedMetode == label ||
              (label == 'E-Wallet' &&
                  ['GoPay','OVO','Dana','ShopeePay'].contains(_selectedMetode))) {
            _selectedMetode = null;
            _selectedBank = null;
          } else {
            _selectedMetode = label;
            _selectedBank = null;
          }
        });
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _C.teal : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _C.teal.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? _C.teal.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  size: 20,
                  color: isSelected ? _C.teal : _C.grey),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _C.teal : _C.charcoal))),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _C.green)),
              ),
            const SizedBox(width: 6),
            Icon(
              isSelected
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isSelected ? _C.teal : _C.grey,
              size: 22,
            ),
          ]),
          if (isSelected && child != null) ...[
            const SizedBox(height: 14),
            child,
          ],
        ]),
      ),
    );
  }

  // ── Shared helpers ───────────────────────────────────
  BoxDecoration _cardDeco() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.stroke.withOpacity(0.50), width: 1),
        boxShadow: [
          BoxShadow(
            color: _C.teal.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11, color: _C.grey, fontWeight: FontWeight.w600));

  Widget _infoRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: _C.grey,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.charcoal)),
        ],
      );
}

// ══════════════════════════════════════════════════════
//  SUB-WIDGETS
// ══════════════════════════════════════════════════════

/// Full-width teal gradient header background
class _GradientHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 230,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_C.tealDark, _C.teal, _C.tealLight],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
      );
}

/// Decorative translucent circle
class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

/// 3-step progress indicator
class _StepProgress extends StatelessWidget {
  final int step; // 1-indexed current step
  const _StepProgress({required this.step});

  @override
  Widget build(BuildContext context) {
    final labels = ['Keranjang', 'Konfirmasi', 'Pembayaran'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // connector line
            final filled = (i ~/ 2) < step - 1;
            return Expanded(
              child: Container(
                height: 2,
                color: filled ? Colors.white : Colors.white.withOpacity(0.30),
              ),
            );
          }
          final idx = i ~/ 2 + 1;
          final isActive   = idx == step;
          final isComplete = idx < step;
          return _StepDot(
              index: idx,
              label: labels[idx - 1],
              isActive: isActive,
              isComplete: isComplete);
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isComplete;
  const _StepDot({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 30 : 24,
        height: isActive ? 30 : 24,
        decoration: BoxDecoration(
          color: isComplete || isActive
              ? Colors.white
              : Colors.white.withOpacity(0.20),
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Center(
          child: isComplete
              ? Icon(Icons.check_rounded,
                  size: 14, color: _C.teal)
              : Text('$index',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? _C.teal
                          : Colors.white.withOpacity(0.50))),
        ),
      ),
      const SizedBox(height: 5),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.55))),
    ]);
  }
}