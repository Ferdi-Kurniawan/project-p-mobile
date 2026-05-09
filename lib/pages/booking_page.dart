import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/services/api_service.dart'; // Pastikan path ini benar

class BookingPage extends StatefulWidget {
  final String bookingId; // ID dari Backend
  final List<CartItem> items;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHarga;

  const BookingPage({
    super.key,
    required this.bookingId,
    required this.items,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.totalHarga,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedMetode;
  String? _selectedBank;

  static const Map<String, int> _adminFee = {
    'Transfer Bank': 4500,
    'QRIS': 0,
    'GoPay': 1000,
    'OVO': 1000,
    'Dana': 1000,
    'ShopeePay': 1000,
  };

  static const List<Map<String, String>> _banks = [
    {'name': 'BCA', 'norek': '1234567890'},
    {'name': 'Mandiri', 'norek': '0987654321'},
    {'name': 'BNI', 'norek': '1122334455'},
    {'name': 'BRI', 'norek': '5566778899'},
  ];

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
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  int get _durasi => widget.tanggalSelesai.difference(widget.tanggalMulai).inDays + 1;
  int get _adminFeeAmount => _adminFee[_selectedMetode] ?? 0;
  int get _totalBayar => widget.totalHarga + _adminFeeAmount;

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── LOGIKA UPDATE KE BACKEND ──
  Future<void> _prosesKonfirmasiBayar() async {
    if (_selectedMetode == null) {
      _showSnackBar('Pilih metode pembayaran dulu');
      return;
    }
    if (_selectedMetode == 'Transfer Bank' && _selectedBank == null) {
      _showSnackBar('Pilih bank tujuan');
      return;
    }

    // 1. Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
    );

    // 2. Hit API
    String paymentMethodName = _selectedBank ?? _selectedMetode!;
    bool success = await ApiService.updatePaymentBooking(
      widget.bookingId,
      paymentMethodName,
    );

    Navigator.pop(context); // Tutup Loading

    if (success) {
      Navigator.pop(context); // Tutup BottomSheet Metode
      _showSuksesSheet();
    } else {
      _showSnackBar('Gagal memproses pembayaran ke server.');
    }
  }

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
            padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),
                  
                  // Transfer Bank
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'Transfer Bank',
                    icon: Icons.account_balance_rounded,
                    child: _selectedMetode == 'Transfer Bank'
                        ? Column(children: _banks.map((bank) => _buildOption(bank['name']!, 'No. Rek: ${bank['norek']}', _selectedBank == bank['name'], () {
                            setSheetState(() => _selectedBank = bank['name']);
                            setState(() => _selectedBank = bank['name']);
                          })).toList())
                        : null,
                  ),
                  const SizedBox(height: 10),
                  
                  // QRIS
                  _metodeGroup(setSheetState: setSheetState, label: 'QRIS', icon: Icons.qr_code_scanner_rounded, badge: 'Gratis'),
                  const SizedBox(height: 10),
                  
                  // E-Wallet
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'E-Wallet',
                    icon: Icons.wallet_rounded,
                    child: _selectedMetode == 'E-Wallet'
                        ? Column(children: ['GoPay', 'OVO', 'Dana', 'ShopeePay'].map((w) => _buildOption(w, '+ ${_formatRupiah(_adminFee[w] ?? 0)}', _selectedBank == w, () {
                            setSheetState(() => _selectedBank = w);
                            setState(() => _selectedBank = w);
                          })).toList())
                        : null,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _prosesKonfirmasiBayar,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Konfirmasi Bayar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildOption(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.withOpacity(0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.deepOrange, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSuksesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('ID Booking: ${widget.bookingId}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  CartModel.instance.clear();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- SISA UI (build, _buildKunjunganCard, dll) Tetap Sama ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          Container(height: 220, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepOrange.shade800, Colors.orange.shade400]))),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    children: [
                      _buildKunjunganCard(),
                      const SizedBox(height: 20),
                      ...widget.items.map((item) => _buildTiketCard(item)),
                      const SizedBox(height: 20),
                      _buildHargaCard(),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        const Text('Detail Pemesanan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildKunjunganCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(children: [Text('Mulai', style: TextStyle(fontSize: 10, color: Colors.grey)), Text(_formatTanggal(widget.tanggalMulai), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
        const Icon(Icons.arrow_forward, color: Colors.deepOrange),
        Column(children: [Text('Selesai', style: TextStyle(fontSize: 10, color: Colors.grey)), Text(_formatTanggal(widget.tanggalSelesai), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
      ]),
    );
  }

  Widget _buildTiketCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        const Icon(Icons.confirmation_number, color: Colors.deepOrange),
        const SizedBox(width: 12),
        Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(_formatRupiah(item.subtotal), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildHargaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Tiket'), Text(_formatRupiah(widget.totalHarga))]),
        if (_selectedMetode != null) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Admin ($_selectedMetode)'), Text(_formatRupiah(_adminFeeAmount))]),
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)), Text(_formatRupiah(_totalBayar), style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))]),
      ]),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total Bayar', style: TextStyle(fontSize: 12, color: Colors.grey)), Text(_formatRupiah(_totalBayar), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange))]),
        ElevatedButton(onPressed: _showMetodePembayaran, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange), child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white))),
      ]),
    );
  }

  Widget _metodeGroup({required StateSetter setSheetState, required String label, required IconData icon, String? badge, Widget? child}) {
    bool isSelected = _selectedMetode == label || (label == 'E-Wallet' && ['GoPay', 'OVO', 'Dana', 'ShopeePay'].contains(_selectedMetode));
    return GestureDetector(
      onTap: () { setSheetState(() { _selectedMetode = isSelected ? null : label; _selectedBank = null; }); setState(() {}); },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade200)),
        child: Column(children: [
          Row(children: [
            Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.deepOrange : Colors.black))),
            if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.green))),
            Icon(isSelected ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
          ]),
          if (isSelected && child != null) Padding(padding: const EdgeInsets.only(top: 12), child: child),
        ]),
      ),
    );
  }
}