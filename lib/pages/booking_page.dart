import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/services/api_service.dart';

class BookingPage extends StatefulWidget {
  final List<CartItem> items;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHarga;

  BookingPage({
    super.key,
    this.items = const [],
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    this.totalHarga = 0,
  }) : tanggalMulai = tanggalMulai ?? DateTime.now(),
       tanggalSelesai = tanggalSelesai ?? DateTime.now();

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedMetode;
  String? _selectedBank;
  bool _isLoading = false;
  
  // State untuk mengontrol UI: Apakah booking sudah terbuat di backend?
  bool _isBookingCreated = false;
  String? _bookingIdFromBackend;
  String? _ticketCodeFromBackend;
  File? _imageProof;

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

  // ── helpers ──
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
    const bulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  // Format aman YYYY-MM-DD untuk Backend
  String _formatDateForApi(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  int get _durasi => widget.tanggalSelesai.difference(widget.tanggalMulai).inDays + 1;
  int get _adminFeeAmount => _adminFee[_selectedMetode] ?? 0;
  int get _totalBayar => widget.totalHarga + _adminFeeAmount;

  // ═════════════════════════════════════════════════════════
  //  LOGIK KONEKSI API (CREATE BOOKING & UPLOAD PROOF)
  // ═════════════════════════════════════════════════════════

  // 1. Fungsi DRAFT / CREATE BOOKING
  void _handleCreateBooking() async {
    setState(() => _isLoading = true);

    // Menggunakan format YYYY-MM-DD agar tidak ditolak backend
    final result = await ApiService.createBooking(
      startDate: _formatDateForApi(widget.tanggalMulai),
      endDate: _formatDateForApi(widget.tanggalSelesai),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      setState(() {
        // Ambil ID dari backend (cek 'id' atau '_id' tergantung database SQL/MongoDB)
        _bookingIdFromBackend = result['id'] ?? result['_id'];
        _ticketCodeFromBackend = result['ticket_code'] ?? "WS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
        _isBookingCreated = true; // Mengubah tampilan UI ke mode Upload Pembayaran
      });

      // Cart di server (Redis) otomatis terhapus saat sukses jadi booking, bersihkan lokal:
      CartModel.instance.clear(); 
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal membuat pesanan. Pastikan sesi login aktif.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 2. Fungsi PILIH GAMBAR & UPLOAD BUKTI BAYAR
  Future<void> _pickAndUploadImage() async {
    if (_bookingIdFromBackend == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageProof = File(pickedFile.path);
        _isLoading = true;
      });

      final metodeDipilih = _selectedBank ?? _selectedMetode ?? 'Transfer';
      
      // Panggil fungsi upload dari ApiService
      final response = await ApiService.uploadPaymentProof(
        bookingId: _bookingIdFromBackend!,
        paymentMethod: metodeDipilih,
        imageFile: _imageProof!,
      );

      setState(() => _isLoading = false);

      if (response != null) {
        _showSuksesSheet();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal mengupload bukti pembayaran. Coba lagi.'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ═════════════════════════════════════════════════════════
  //  BOTTOM SHEET METODE PEMBAYARAN
  // ═════════════════════════════════════════════════════════
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
                  const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 24),

                  // Transfer Bank List
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'Transfer Bank',
                    icon: Icons.account_balance_rounded,
                    child: _selectedMetode == 'Transfer Bank'
                        ? Column(
                            children: _banks.map((bank) {
                              final isSelected = _selectedBank == bank['name'];
                              return ListTile(
                                onTap: () {
                                  setSheetState(() => _selectedBank = bank['name']);
                                  setState(() => _selectedBank = bank['name']);
                                },
                                title: Text('Bank ${bank['name']}', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.deepOrange : Colors.black)),
                                subtitle: Text('No. Rek: ${bank['norek']}'),
                                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.deepOrange) : null,
                              );
                            }).toList(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // QRIS Option
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'QRIS',
                    icon: Icons.qr_code_scanner_rounded,
                    badge: 'Gratis',
                  ),
                  const SizedBox(height: 10),

                  // E-Wallet Option
                  _metodeGroup(
                    setSheetState: setSheetState,
                    label: 'E-Wallet',
                    icon: Icons.account_balance_wallet_rounded,
                    child: _selectedMetode == 'E-Wallet'
                        ? Column(
                            children: ['GoPay', 'OVO', 'Dana', 'ShopeePay'].map((w) {
                              final isSelected = _selectedBank == w;
                              return ListTile(
                                onTap: () {
                                  setSheetState(() => _selectedBank = w);
                                  setState(() => _selectedBank = w);
                                },
                                title: Text(w, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.deepOrange : Colors.black)),
                                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.deepOrange) : null,
                              );
                            }).toList(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedMetode == null || (_selectedMetode == 'Transfer Bank' && _selectedBank == null) || (_selectedMetode == 'E-Wallet' && _selectedBank == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih detail metode pembayaran terlebih dahulu')));
                          return;
                        }
                        Navigator.pop(context);
                        // Jalankan proses DRAFT Booking ke backend
                        _handleCreateBooking();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Lanjutkan Pemesanan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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

  // ═════════════════════════════════════════════════════════
  //  TAMPILAN UTAMA (BUILDER)
  // ═════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade800,
        elevation: 0,
        title: const Text("Detail & Pembayaran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                // Jika pesanan belum dibuat -> Tampilkan ringkasan pesanan
                if (!_isBookingCreated) ...[
                  _sectionTitle('Info Kunjungan', Icons.calendar_month_rounded),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    Text("Mulai: ${_formatTanggal(widget.tanggalMulai)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Selesai: ${_formatTanggal(widget.tanggalSelesai)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text("Durasi: $_durasi Hari Kunjungan", style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 20),
                  
                  _sectionTitle('Ringkasan Item', Icons.receipt_long_rounded),
                  const SizedBox(height: 10),
                  _buildCardContainer(
                    widget.items.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${e.name} (${e.quantity}x)")),
                          Text(_formatRupiah(e.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )).toList(),
                  ),
                ] 
                // Jika pesanan SUDAH DIBUAT -> Tampilkan halaman instruksi bayar & Upload
                else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
                    child: Column(
                      children: [
                        const Text("Pesanan Berhasil Dibuat!", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("Kode Booking: ${_ticketCodeFromBackend ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('Instruksi Pembayaran', Icons.payment_rounded),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    Text("Metode: ${_selectedBank ?? _selectedMetode}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_selectedMetode == 'Transfer Bank') ...[
                      const Text("Silakan lakukan transfer ke rekening berikut:"),
                      const SizedBox(height: 4),
                      Text(_banks.firstWhere((b) => b['name'] == _selectedBank, orElse: () => {'norek': '1234567890'})['norek']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.deepOrange, letterSpacing: 2)),
                    ] else if (_selectedMetode == 'QRIS') ...[
                      const Center(child: Icon(Icons.qr_code_2_rounded, size: 120)),
                      const Center(child: Text("Scan QRIS di atas menggunakan M-Banking / E-Wallet Anda")),
                    ] else ...[
                      Text("Buka aplikasi $_selectedBank Anda dan lakukan pembayaran ke merchant Wisata."),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tagihan:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatRupiah(_totalBayar), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.deepOrange)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Area Upload Bukti
                  _sectionTitle('Konfirmasi Pembayaran', Icons.cloud_upload_rounded),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: _imageProof != null ? Colors.green : Colors.deepOrange),
                          const SizedBox(height: 8),
                          Text(_imageProof != null ? "Bukti Terpilih (Ketuk untuk ganti)" : "Upload Bukti Pembayaran disini", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          if (_imageProof != null)
                            Padding(padding: const EdgeInsets.only(top: 4), child: Text(_imageProof!.path.split('/').last, style: const TextStyle(fontSize: 11, color: Colors.green))),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

      // Bottom Navigation Bar
      bottomNavigationBar: _isLoading || _isBookingCreated
          ? null // Sembunyikan jika sedang loading atau sudah masuk mode upload
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(_formatRupiah(_totalBayar), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.deepOrange)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showMetodePembayaran,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Pilih Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Sub-Widget & Komponen UI ──
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepOrange),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _metodeGroup({required StateSetter setSheetState, required String label, required IconData icon, String? badge, Widget? child}) {
    final isSelected = _selectedMetode == label || (label == 'E-Wallet' && ['GoPay', 'OVO', 'Dana', 'ShopeePay'].contains(_selectedMetode));
    return InkWell(
      onTap: () {
        setSheetState(() {
          _selectedMetode = isSelected ? null : label;
          _selectedBank = null;
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade200)),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? Colors.deepOrange : Colors.grey),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.deepOrange : Colors.black))),
                if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)), child: Text(badge, style: const TextStyle(color: Colors.green, fontSize: 10))),
                Icon(isSelected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
            if (isSelected && child != null) ...[const Divider(), child],
          ],
        ),
      ),
    );
  }

  void _showSuksesSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Bukti pembayaran Anda sedang diverifikasi oleh admin.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}