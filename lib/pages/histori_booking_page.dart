import 'package:flutter/material.dart';
import '../services/api_service.dart';

// =====================================================================
//  HISTORI BOOKING PAGE  — Admin view
// =====================================================================
class HistoriBookingPage extends StatefulWidget {
  final String? filterStatus;

  const HistoriBookingPage({super.key, this.filterStatus});

  @override
  State<HistoriBookingPage> createState() => _HistoriBookingPageState();
}

class _HistoriBookingPageState extends State<HistoriBookingPage> {
  static const teal500 = Color(0xFF319795);
  static const charcoal = Color(0xFF2D3748);

  List<dynamic> _all = [];
  List<dynamic> _filtered = [];
  bool _loading = false;

  String? _proofUrlFromBackend;
  bool _isLoadingProof = false; 
  String? _selectedStatus;

  // FOKUS: Controller untuk Search Bar
  final _searchCtrl = TextEditingController();

  static const Map<String, Color> _statusColor = {
    'PENDING': Color(0xFFF6AD55),
    'PENDING_VERIFICATION': Color(0xFF4299E1),
    'PAID': Color(0xFF48BB78),
    'CANCELLED': Color(0xFFFC8181),
    'COMPLETED': Color(0xFF319795),
  };

  static const Map<String, String> _statusLabel = {
    'PENDING': 'Menunggu Bayar',
    'PENDING_VERIFICATION': 'Verifikasi',
    'PAID': 'Lunas',
    'CANCELLED': 'Dibatalkan',
    'COMPLETED': 'Selesai',
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.filterStatus;
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Fetch data (Update dengan Search Query) ─────────────────────────
  Future<void> _fetchHistory({String query = ''}) async {
    setState(() => _loading = true);
    try {
      // Jika query kosong, ambil semua histori. Jika ada, panggil endpoint search.
      final list = query.isEmpty
          ? await ApiService.getHistoryBookings()
          : await ApiService.searchBookings(
              query,
            ); // Pastikan fungsi ini ada di api_service.dart

      setState(() {
        _all = list;
        _applyFilter();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadPaymentProof(String bId, StateSetter sheetSetState) async {
    // Tampilkan loading di dalam Bottom Sheet
    sheetSetState(() => _isLoadingProof = true); 

    final res = await ApiService.getPaymentProof(bId);
    if (res != null && res['success'] == true) {
      if (res['payment_proof_url'] != null) {
        // Update state utama
        setState(() {
          _proofUrlFromBackend = res['payment_proof_url'];
        });
        // Update state khusus Bottom Sheet agar gambar muncul
        sheetSetState(() {
          _proofUrlFromBackend = res['payment_proof_url'];
          _isLoadingProof = false;
        });
      }
    } else {
      debugPrint("Gagal mengambil URL bukti: ${res['message']}");
      sheetSetState(() => _isLoadingProof = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedStatus == null || _selectedStatus!.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all
            .where(
              (b) =>
                  (b['status'] ?? '').toString().toUpperCase() ==
                  _selectedStatus!.toUpperCase(),
            )
            .toList();
      }
    });
  }

  // ── Snackbar ────────────────────────────────────────────────────────
  void _snack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? teal500 : Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Verifikasi & Cancel Booking ─────────────────────────────────────
  // (Fungsi _verifyBooking, _cancelBooking, _deleteBooking, _confirmDialog sama seperti aslinya)
  Future<void> _verifyBooking(String bookingId) async {
    final confirm = await _confirmDialog(
      'Verifikasi Pembayaran',
      'Konfirmasi pembayaran ini? Status akan berubah menjadi LUNAS dan QR tiket dikirim ke email user.',
      actionLabel: 'Verifikasi',
      actionColor: teal500,
    );
    if (!confirm) return;

    final res = await ApiService.verifyPayment(bookingId);
    _snack(res['message'] ?? 'Selesai', success: res['success'] == true);
    if (res['success'] == true) _fetchHistory();
  }

  Future<void> _cancelBooking(String bookingId) async {
    final reasonCtrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Batalkan Booking',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan alasan pembatalan. Email akan dikirim ke user.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Bukti bayar tidak valid',
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonCtrl.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Batalkan Booking',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) {
      _snack('Alasan pembatalan tidak boleh kosong', success: false);
      return;
    }

    final res = await ApiService.cancelPayment(
      bookingId: bookingId,
      reason: reason,
    );
    _snack(res['message'] ?? 'Selesai', success: res['success'] == true);
    if (res['success'] == true) _fetchHistory();
  }

  Future<void> _deleteBooking(String bookingId) async {
    final confirm = await _confirmDialog(
      'Hapus Booking',
      'Data booking ini akan dihapus secara permanen dari sistem.',
      actionLabel: 'Hapus',
      actionColor: Colors.red.shade400,
    );
    if (!confirm) return;

    final res = await ApiService.deleteBooking(bookingId);
    _snack(res['message'] ?? 'Selesai', success: res['success'] == true);
    if (res['success'] == true) _fetchHistory();
  }

  Future<bool> _confirmDialog(
    String title,
    String content, {
    required String actionLabel,
    required Color actionColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Detail bottom sheet (DENGAN BUKTI GAMBAR) ───────────────────────
 void _showDetail(Map<String, dynamic> b) {
    // Reset state setiap kali detail baru dibuka agar tidak membawa data sebelumnya
    _proofUrlFromBackend = null;
    _isLoadingProof = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // WAJIB: Menggunakan StatefulBuilder agar Bottom Sheet bisa mendeteksi perubahan data gambar
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter sheetSetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95, // Ditingkatkan agar scroll gambar lebih nyaman
            expand: false,
            builder: (ctx, sc) => SingleChildScrollView(
              controller: sc,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        'Detail Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: charcoal,
                        ),
                      ),
                      const Spacer(),
                      _statusBadge(b['status']),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _detailRow('ID Booking', b['id']?.toString() ?? '-'),
                  _detailRow('Tiket', b['ticket_code']?.toString() ?? '-'),
                  _detailRow(
                    'User',
                    b['user']?['fullname'] ?? b['user_id']?.toString() ?? '-',
                  ),
                  _detailRow('Email', b['user']?['email'] ?? '-'),
                  _detailRow(
                    'Tanggal Mulai',
                    _fmtDate(b['startDate'] ?? b['start_date']),
                  ),
                  _detailRow(
                    'Tanggal Selesai',
                    _fmtDate(b['endDate'] ?? b['end_date']),
                  ),
                  _detailRow('Total Harga', _fmtRupiah(b['total_price'])),
                  if (b['payment_method'] != null)
                    _detailRow('Metode Bayar', b['payment_method'].toString()),
                  if (b['paidAt'] != null)
                    _detailRow('Dibayar Pada', _fmtDate(b['paidAt'])),
                  _detailRow(
                    'Check-in',
                    (b['is_checked_in'] == true)
                        ? 'Sudah check-in${b['checked_in_at'] != null ? ' · ${_fmtDate(b['checked_in_at'])}' : ''}'
                        : 'Belum check-in',
                  ),
                  if (b['created_at'] != null)
                    _detailRow('Dibuat', _fmtDate(b['created_at'])),

                  const SizedBox(height: 24),

                  // =========================================================
                  // IMPLEMENTASI BARU: LOGIKA MANUALLY TRIGGER UTK GAMBAR BUKTI
                  // =========================================================
                  const Text(
                    'Bukti Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: charcoal,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _proofUrlFromBackend != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _proofUrlFromBackend!,
                            width: double.infinity,
                            fit: BoxFit.cover, 
                            loadingBuilder: (c, child, progress) => progress == null
                                ? child
                                : Container(
                                    height: 150,
                                    color: Colors.grey.shade50,
                                    child: const Center(
                                      child: CircularProgressIndicator(color: teal500),
                                    ),
                                  ),
                            errorBuilder: (c, e, s) {
                              debugPrint("Gagal load bukti: $e");
                              return Container(
                                height: 150,
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_rounded, color: Colors.grey, size: 40),
                                    SizedBox(height: 8),
                                    Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : _isLoadingProof
                          ? Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(color: teal500),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  // 1. Set loading lokal khusus untuk Bottom Sheet
                                  sheetSetState(() {
                                    _isLoadingProof = true;
                                  });
                                  
                                  // 2. Panggil fungsi _loadPaymentProof bawaan kamu
                                  await _loadPaymentProof(b['id'].toString(), sheetSetState);
                                  
                                  // 3. Matikan loading lokal & render ulang Bottom Sheet untuk memunculkan gambar
                                  sheetSetState(() {
                                    _isLoadingProof = false;
                                  });
                                },
                                icon: const Icon(Icons.image_search_rounded, color: teal500),
                                label: const Text(
                                  'Tampilkan Bukti Pembayaran',
                                  style: TextStyle(color: teal500, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: teal500),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                  // =========================================================

                  const SizedBox(height: 32),

                  _buildActionButtons(b),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildActionButtons(Map<String, dynamic> b) {
    final status = (b['status'] ?? '').toString().toUpperCase();
    final id = b['id']?.toString() ?? '';

    return Column(
      children: [
        if (status == 'PENDING_VERIFICATION') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _verifyBooking(id);
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text(
                'Verifikasi Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: teal500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _cancelBooking(id);
              },
              icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
              label: Text(
                'Batalkan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        if (status == 'CANCELLED' || status == 'COMPLETED') ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _deleteBooking(id);
              },
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              label: Text(
                'Hapus Booking',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          widget.filterStatus != null
              ? _statusLabel[widget.filterStatus!] ?? 'Booking'
              : 'Histori Booking',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _searchCtrl.clear();
              _fetchHistory();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: teal500))
          : Column(
              children: [
                // ── Header Search & Filter bar ──
                Container(
                  color: teal500,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    children: [
                      // FOKUS: Kotak Pencarian
                      TextField(
                        controller: _searchCtrl,
                        onSubmitted: (v) => _fetchHistory(query: v),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari kode tiket atau nama user...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _fetchHistory();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Text(
                            'Total: ${_all.length} booking',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Tampil: ${_filtered.length}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _chip('Semua', null),
                            ..._statusLabel.entries.map(
                              (e) => _chip(e.value, e.key),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── List ──
                Expanded(
                  child: _filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: () async =>
                              _fetchHistory(query: _searchCtrl.text),
                          color: teal500,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _buildCard(
                              _filtered[i] as Map<String, dynamic>,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _chip(String label, String? status) {
    final selected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
        _applyFilter();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? teal500 : Colors.white,
          ),
        ),
      ),
    );
  }

  // (Fungsi _buildCard, _statusBadge, _checkInBadge, _infoChip, _detailRow, _fmtDate, _fmtRupiah, _buildEmpty dibiarkan persis sama dengan kode Anda agar tidak ada desain yang rusak)
  Widget _buildCard(Map<String, dynamic> b) {
    final status = (b['status'] ?? '').toString().toUpperCase();
    final isPendingVerif = status == 'PENDING_VERIFICATION';
    final isCheckedIn = b['is_checked_in'] == true;
    return GestureDetector(
      onTap: () => _showDetail(b),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPendingVerif
              ? Border.all(color: const Color(0xFF4299E1), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: teal500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: teal500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['user']?['fullname'] ??
                              b['user_id']?.toString() ??
                              'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: charcoal,
                          ),
                        ),
                        Text(
                          'ID: ${b['id']?.toString().substring(0, 8) ?? '-'}...',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _statusBadge(b['status']),
                      if (isCheckedIn) ...[
                        const SizedBox(height: 4),
                        _checkInBadge(),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _infoChip(
                    Icons.calendar_today_outlined,
                    _fmtDate(b['startDate'] ?? b['start_date']),
                  ),
                  const Text(' → ', style: TextStyle(color: Colors.black38)),
                  _infoChip(
                    Icons.calendar_today_outlined,
                    _fmtDate(b['endDate'] ?? b['end_date']),
                  ),
                  const Spacer(),
                  Text(
                    _fmtRupiah(b['total_price']),
                    style: const TextStyle(
                      color: teal500,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (isPendingVerif) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(b['id'].toString()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          side: BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Tolak',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _verifyBooking(b['id'].toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(dynamic status) {
    final s = (status ?? '').toString().toUpperCase();
    final color = _statusColor[s] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusLabel[s] ?? s,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _checkInBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF48BB78).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.door_front_door_outlined,
            size: 10,
            color: Color(0xFF2F855A),
          ),
          SizedBox(width: 3),
          Text(
            'Check-in',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F855A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.black38),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(dynamic val) {
    if (val == null) return '-';
    try {
      final dt = DateTime.parse(val.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return val.toString();
    }
  }

  String _fmtRupiah(dynamic price) {
    if (price == null) return 'Rp 0';
    final num val = num.tryParse(price.toString()) ?? 0;
    final str = val.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(str[i]);
      c++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data booking',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
