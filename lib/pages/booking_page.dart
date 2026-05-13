import 'package:flutter_application_2/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';

class BookingPage extends StatefulWidget {
  final String bookingId; // ID dari Backend
  final List<CartItem> items;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHarga;

  BookingPage({
    super.key,
    required this.items,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.totalHarga,
  });

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
    const hari = [
      'Senin', 'Selasa', 'Rabu', 'Kamis',
      'Jumat', 'Sabtu', 'Minggu'
    ];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
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

  int get _totalBayar => widget.totalHarga + _adminFeeAmount;

  String get _bookingCode {
    final now = DateTime.now();
    return 'WS${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  // ── Pop up metode pembayaran ──
  void _showMetodePembayaran() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.shade700,
                              Colors.orange.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.payment_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'Pilih cara pembayaran kamu',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Transfer Bank ──
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'Transfer Bank',
                    icon: Icons.account_balance_rounded,
                    child: _selectedMetode == 'Transfer Bank'
                        ? Column(
                            children: _banks.map((bank) {
                              final isSelected = _selectedBank == bank['name'];
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(
                                      () => _selectedBank = bank['name']);
                                  setState(() => _selectedBank = bank['name']);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.deepOrange.withOpacity(0.06)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.deepOrange
                                          : Colors.grey.shade200,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.deepOrange
                                                  .withOpacity(0.1)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: Center(
                                          child: Text(
                                            bank['name']!,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: isSelected
                                                  ? Colors.deepOrange
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Bank ${bank['name']}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.deepOrange
                                                    : const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            Text(
                                              'No. Rek: ${bank['norek']}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle_rounded,
                                            color: Colors.deepOrange, size: 20),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // ── QRIS ──
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'QRIS',
                    icon: Icons.qr_code_scanner_rounded,
                    badge: 'Gratis',
                    child: _selectedMetode == 'QRIS'
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.qr_code_2_rounded,
                                    size: 80,
                                    color: Colors.grey.shade700),
                                const SizedBox(height: 6),
                                Text(
                                  'QR Code akan muncul setelah konfirmasi',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // ── E-Wallet ──
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'E-Wallet',
                    icon: Icons.account_balance_wallet_rounded,
                    child: _selectedMetode == 'E-Wallet'
                        ? Column(
                            children: ['GoPay', 'OVO', 'Dana', 'ShopeePay']
                                .map((w) {
                              final isSelected = _selectedBank == w;
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    _selectedBank = w;
                                  });
                                  setState(() {
                                    _selectedBank = w;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.deepOrange.withOpacity(0.06)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.deepOrange
                                          : Colors.grey.shade200,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.wallet_rounded,
                                          size: 20,
                                          color: isSelected
                                              ? Colors.deepOrange
                                              : Colors.grey.shade400),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          w,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.deepOrange
                                                : const Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '+ ${_formatRupiah(_adminFee[w] ?? 0)}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.check_circle_rounded,
                                            color: Colors.deepOrange,
                                            size: 20),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : null,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Konfirmasi di dalam popup
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validasi pilihan
                        if (_selectedMetode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('Pilih metode pembayaran dulu',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ]),
                              backgroundColor: Colors.orange.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        if (_selectedMetode == 'Transfer Bank' &&
                            _selectedBank == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('Pilih bank tujuan transfer',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600)),
                              ]),
                              backgroundColor: Colors.orange.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          return;
                        }
                        // Tutup popup metode lalu tampilkan sukses
                        Navigator.pop(context);
                        _showSuksesSheet();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Konfirmasi Bayar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Pop up sukses ──
  void _showSuksesSheet() {
    final code = _bookingCode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade400,
                    Colors.teal.shade400,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Tiket wisata kamu sudah dikonfirmasi',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),

            // Kode booking
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.deepOrange.withOpacity(0.2), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'Kode Booking',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepOrange,
                            letterSpacing: 2),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Kode booking disalin!'),
                              backgroundColor: Colors.deepOrange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.copy_rounded,
                              size: 16, color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info ringkas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _infoRow('Metode',
                      _selectedBank ?? _selectedMetode ?? '-'),
                  const SizedBox(height: 8),
                  _infoRow('Total Bayar', _formatRupiah(_totalBayar)),
                  const SizedBox(height: 8),
                  _infoRow(
                    'Kunjungan',
                    '${_formatTanggal(widget.tanggalMulai).split(',')[0]} – '
                    '${_formatTanggal(widget.tanggalSelesai).split(',')[0]} '
                    '($_durasi hari)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  CartModel.instance.clear();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _metodeGroup({
    required StateSetter setSheetState,
    required String label,
    required IconData icon,
    String? badge,
    Widget? child,
  }) {
    final isSelected = _selectedMetode == label ||
        (label == 'E-Wallet' &&
            ['GoPay', 'OVO', 'Dana', 'ShopeePay']
                .contains(_selectedMetode));

    return GestureDetector(
      onTap: () {
        setSheetState(() {
          if (_selectedMetode == label ||
              (label == 'E-Wallet' &&
                  ['GoPay', 'OVO', 'Dana', 'ShopeePay']
                      .contains(_selectedMetode))) {
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
            color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepOrange.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon,
                      size: 20,
                      color: isSelected
                          ? Colors.deepOrange
                          : Colors.grey.shade500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.deepOrange
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: isSelected
                      ? Colors.deepOrange
                      : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
            if (isSelected && child != null) ...[
              const SizedBox(height: 14),
              child,
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // AppBar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konfirmasi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Detail Pemesanan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Konten
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      padding:
                          const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // ── Info Kunjungan ──
                        _sectionTitle('Info Kunjungan',
                            Icons.calendar_month_rounded),
                        const SizedBox(height: 10),
                        _buildKunjunganCard(),
                        const SizedBox(height: 20),

                        // ── Detail Tiket ──
                        _sectionTitle('Detail Tiket',
                            Icons.confirmation_number_rounded),
                        const SizedBox(height: 10),
                        ...widget.items.map((item) => _buildTiketCard(item)),
                        const SizedBox(height: 20),

                        // ── Ringkasan Harga ──
                        _sectionTitle('Ringkasan Harga',
                            Icons.receipt_long_rounded),
                        const SizedBox(height: 10),
                        _buildHargaCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.deepOrange),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ── Visit card ───────────────────────────────────────
  Widget _buildKunjunganCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Mulai',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTanggal(widget.tanggalMulai),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.deepOrange),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tanggal Selesai',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTanggal(widget.tanggalSelesai),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade700,
                  Colors.orange.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny_rounded,
                    color: Colors.white, size: 15),
                const SizedBox(width: 6),
                Text(
                  '$_durasi Hari Kunjungan',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tiket card tanpa foto
  Widget _buildTiketCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon pengganti foto
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade700,
                  Colors.orange.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.confirmation_number_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge kategori
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.kategori,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 11, color: Colors.deepOrange.shade300),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.loc,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                      child: Text(
                        '${item.quantity}x tiket',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600),
                      ),
                    ),
                    Text(
                      _formatRupiah(item.subtotal),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Price card ───────────────────────────────────────
  Widget _buildHargaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...widget.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} (${item.quantity}x)',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatRupiah(item.subtotal),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              )),

          // Biaya admin jika sudah pilih metode
          if (_selectedMetode != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya admin (${_selectedBank ?? _selectedMetode})',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    _adminFeeAmount == 0
                        ? 'Gratis'
                        : _formatRupiah(_adminFeeAmount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _adminFeeAmount == 0
                          ? Colors.green
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A)),
              ),
              Text(
                _formatRupiah(_totalBayar),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.deepOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Bayar',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRupiah(_totalBayar),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.deepOrange,
                      letterSpacing: -0.3),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showMetodePembayaran, // buka popup metode
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.shade700,
                    Colors.orange.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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