import 'dart:io';
import 'dart:async'; // DITAMBAHKAN untuk Timer Debounce
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/services/api_service.dart';
import '../helper/snackbar_helper.dart';

// ════════════════════════════════════════════════════════
//  DESIGN TOKENS — Premium Teal Theme
// ════════════════════════════════════════════════════════
class _T {
  static const Color primary = Color(0xFF00B09B);
  static const Color primaryDark = Color(0xFF007A6A);
  static const Color primaryLight = Color(0xFF4DD9C9);
  static const Color primarySurface = Color(0xFFE0F7F4);
  static const List<Color> headerGrad = [Color(0xFF00B09B), Color(0xFF00D2B4)];
  static const Color accent = Color(0xFFFF6B35);
  static const Color bgPage = Color(0xFFF4F9F8);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color textHead = Color(0xFF0D2B26);
  static const Color textBody = Color(0xFF4A6B66);
  static const Color textMuted = Color(0xFFA0B8B5);
  static const Color divider = Color(0xFFDCF0EE);
  static const Color green = Color(0xFF00C48C);
}

class BookingPage extends StatefulWidget {
  final String bookingId;
  final List<CartItem> items;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int totalHarga;

  BookingPage({
    super.key,
    this.bookingId = '',
    this.items = const [],
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    this.totalHarga = 0,
  }) : tanggalMulai = tanggalMulai ?? DateTime.now(),
       tanggalSelesai = tanggalSelesai ?? DateTime.now();

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  // State untuk Flow Umum
  bool _isLoading = false;
  bool _isBookingCreated = false;

  // STATE BARU: Manajemen Data History & Search
  List<dynamic> _bookings = [];
  List<dynamic> _filtered = [];
  bool _loadingHistory = false;

  final _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  // Data Spesifik Tiket
  String? _bookingIdFromBackend;
  String? _ticketCodeFromBackend;
  String? _proofUrlFromBackend;
  File? _imageProof;
  int _activeTotalFromHistory = 0;
  String? _currentStatus;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();

    if (widget.items.isEmpty) {
      _fetchHistory();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIKA DATA ---
  Future<void> _fetchHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final list = await ApiService.getBookings();
      if (mounted) {
        setState(() {
          _bookings = list;
          _filtered = list;
        });
      }
    } catch (e) {
      debugPrint("Gagal fetch history: $e");
    } finally {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  // --- LOGIKA PENCARIAN (DEBOUNCE) ---
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final q = query.trim();

      if (q.isEmpty) {
        setState(() => _filtered = _bookings);
        return;
      }

      setState(() => _loadingHistory = true);
      // Memanggil endpoint search yang kini sudah aman untuk role User
      ApiService.searchBookings(q).then((list) {
        if (mounted) {
          setState(() {
            _filtered = list;
            _loadingHistory = false;
          });
        }
      });
    });
  }

  Future<void> _loadPaymentProof(String bId) async {
    final res = await ApiService.getPaymentProof(bId);
    if (res != null && res['success'] == true) {
      if (res['payment_proof_url'] != null) {
        setState(() {
          _proofUrlFromBackend = res['payment_proof_url'];
        });
      }
    } else {
      debugPrint("Gagal mengambil URL bukti: ${res?['message']}");
    }
  }

  // --- HELPER FORMAT TANGGAL ---
  String _formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      DateTime dt = DateTime.parse(dateStr);
      const bulan = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return dateStr;
    }
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

  // --- HELPER UI STATUS ---
  StatusUI _getStatusUI(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s.contains('paid') || s.contains('success')) {
      return StatusUI(
        label: "TERVERIFIKASI",
        actionText: "Lihat E-Tiket",
        color: _T.green,
        icon: Icons.check_circle_rounded,
        bannerTitle: "Pembayaran Tuntas",
        bannerSub: "Tiket Anda sudah siap digunakan",
        bannerGrad: [_T.primary, _T.primaryLight],
      );
    } else if (s.contains('pending_verification') ||
        s.contains('verification')) {
      return StatusUI(
        label: "DIPROSES",
        actionText: "Lihat Detail",
        color: Colors.blue.shade500,
        icon: Icons.hourglass_top_rounded,
        bannerTitle: "Menunggu Verifikasi",
        bannerSub: "Admin sedang mengecek pembayaran Anda",
        bannerGrad: [Colors.blue.shade500, Colors.blue.shade400],
      );
    } else if (s.contains('cancel')) {
      return StatusUI(
        label: "DIBATALKAN",
        actionText: "Lihat Detail",
        color: Colors.red.shade500,
        icon: Icons.cancel_rounded,
        bannerTitle: "Pesanan Dibatalkan",
        bannerSub: "Pembayaran ditolak atau dibatalkan",
        bannerGrad: [Colors.red.shade500, Colors.red.shade400],
      );
    } else if (s.contains('expire')) {
      return StatusUI(
        label: "KADALUARSA",
        actionText: "Lihat Detail",
        color: _T.textMuted,
        icon: Icons.timer_off_rounded,
        bannerTitle: "Waktu Habis",
        bannerSub: "Pesanan ini sudah tidak berlaku",
        bannerGrad: [_T.textMuted, Colors.grey.shade400],
      );
    } else {
      return StatusUI(
        label: "MENUNGGU BAYAR",
        actionText: "Bayar Sekarang",
        color: _T.accent,
        icon: Icons.schedule_rounded,
        bannerTitle: "Menunggu Transfer",
        bannerSub: "Segera upload bukti pembayaran",
        bannerGrad: [const Color(0xFFFF7A45), const Color(0xFFFF9C73)],
      );
    }
  }

  Future<void> _handleCreateBooking() async {
    setState(() => _isLoading = true);
    final result = await ApiService.createBooking(
      startDate:
          "${widget.tanggalMulai.year}-${widget.tanggalMulai.month}-${widget.tanggalMulai.day}",
      endDate:
          "${widget.tanggalSelesai.year}-${widget.tanggalSelesai.month}-${widget.tanggalSelesai.day}",
    );
    setState(() => _isLoading = false);

    if (result != null) {
      setState(() {
        var data = result['data'] ?? result;
        var bookingData = data['booking'] ?? data['bookings'] ?? data;
        _bookingIdFromBackend = (bookingData['id'] ?? bookingData['_id'])
            ?.toString();
        _ticketCodeFromBackend =
            (bookingData['ticket_code'] ?? bookingData['ticketCode'])
                ?.toString();
        _isBookingCreated = true;
      });
      CartModel.instance.clear();
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_bookingIdFromBackend == null) await _handleCreateBooking();
    if (_bookingIdFromBackend == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageProof = File(pickedFile.path);
        _isLoading = true;
      });

      final res = await ApiService.uploadPaymentProof(
        bookingId: _bookingIdFromBackend!,
        paymentMethod: 'Transfer Bank',
        imageFile: _imageProof!,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final bool isSuccess = res['success'] == true;
      final String msg = res['message'];
      CustomSnackBar.show(context, msg, isSuccess);

      if (isSuccess) {
        setState(() {
          _currentStatus = "pending_verification";
        });
        _fetchHistory();
        _showSuksesSheet();
      } else {
        setState(() {
          _imageProof = null;
        });
      }
    }
  }

  // ════════════════════════════════════════════════════════
  //  ARSITEKTUR UI UTAMA
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bgPage,
      body: _isLoading
          ? _buildLoadingOverlay()
          : FadeTransition(
              opacity: _fadeAnim,
              child: (widget.items.isEmpty && !_isBookingCreated)
                  ? _buildHistoryView()
                  : _buildDetailView(),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- OVERLAY LOADING ---
  Widget _buildLoadingOverlay() {
    return Container(
      color: _T.bgPage,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: _T.headerGrad),
                  boxShadow: [
                    BoxShadow(
                      color: _T.primary.withOpacity(0.30),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Memproses Transaksi...",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textHead,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Mohon tunggu sebentar",
              style: TextStyle(fontSize: 12, color: _T.textBody),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAMPILAN A: DAFTAR RIWAYAT DENGAN SEARCH (HISTORY VIEW)
  // ════════════════════════════════════════════════════════
  Widget _buildHistoryView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverHeader(
          icon: Icons.confirmation_number_outlined,
          title: "Tiket Saya",
          subtitle: "Kelola riwayat pemesanan & akses cepat tiket Anda",
        ),

        // --- SEARCH BAR AREA ---
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus, // Kunci fokus agar keyboard tidak turun
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Cari ID Tiket...",
                hintStyle: const TextStyle(color: _T.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: _T.primary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: _T.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _T.divider, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _T.divider, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _T.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),

        // --- DAFTAR TIKET ---
        SliverToBoxAdapter(
          child: _loadingHistory
              ? const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: _T.primary),
                  ),
                )
              : _filtered.isEmpty
              ? _buildEmptyState()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    children: _filtered
                        .map((b) => _buildPremiumHistoryCard(b))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  // --- KARTU RIWAYAT ALA TIKET FISIK ---
  Widget _buildPremiumHistoryCard(Map<String, dynamic> b) {
    final status = b['status']?.toString() ?? 'pending';
    final statusUI = _getStatusUI(status);
    final String ticketCode = b['ticket_code'] ?? "TICKET-${b['id'] ?? 'NEW'}";
    final String date = _formatTanggal(b['start_date']?.toString());
    final int price = b['total_price'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _T.divider.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _T.textHead.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              _isBookingCreated = true;
              _bookingIdFromBackend = (b['id'] ?? b['_id'])?.toString();
              _ticketCodeFromBackend = ticketCode;
              _currentStatus = status;
              _activeTotalFromHistory = price;
            });
            if (status.toLowerCase() != 'pending') {
              _loadPaymentProof(_bookingIdFromBackend!);
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusUI.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusUI.icon,
                                color: statusUI.color,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusUI.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: statusUI.color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: _T.textMuted.withOpacity(0.5),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ticketCode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _T.textHead,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_available_rounded,
                          size: 14,
                          color: _T.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Kunjungan: $date",
                          style: const TextStyle(
                            fontSize: 13,
                            color: _T.textBody,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: 24,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final dashCount = (constraints.constrainWidth() / 10)
                              .floor();
                          return Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            direction: Axis.horizontal,
                            children: List.generate(dashCount, (_) {
                              return SizedBox(
                                width: 5,
                                height: 1.5,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: _T.divider),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: -12,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _T.bgPage,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -12,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: _T.bgPage,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Pembayaran",
                          style: TextStyle(fontSize: 11, color: _T.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRupiah(price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _T.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      statusUI.actionText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: statusUI.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAMPILAN B: DETAIL PESANAN & PEMBAYARAN (DETAIL VIEW)
  // ════════════════════════════════════════════════════════
  Widget _buildDetailView() {
    final status = _currentStatus?.toLowerCase() ?? 'pending';
    final statusUI = _getStatusUI(status);
    final bool showUpload = status == 'pending';
    final int total = (_isBookingCreated && widget.items.isEmpty)
        ? _activeTotalFromHistory
        : widget.totalHarga;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverHeader(
          icon: statusUI.icon,
          title: status == 'paid' || status == 'success'
              ? "E-Tiket Resmi"
              : "Detail Pemesanan",
          subtitle: _ticketCodeFromBackend != null
              ? "Booking Ref: $_ticketCodeFromBackend"
              : "Verifikasi instruksi di bawah ini",
          onBack: () {
            if (_isBookingCreated && widget.items.isEmpty) {
              setState(() => _isBookingCreated = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernStatusBanner(statusUI),
                const SizedBox(height: 24),

                if (widget.items.isNotEmpty) ...[
                  _buildSectionHeader(
                    "Item Dipesan",
                    Icons.shopping_bag_rounded,
                  ),
                  const SizedBox(height: 12),
                  ...widget.items.map((item) => _buildModernItemRow(item)),
                  const SizedBox(height: 24),
                ],

                _buildSectionHeader(
                  "Rincian Pembayaran",
                  Icons.receipt_long_rounded,
                ),
                const SizedBox(height: 12),
                _buildPremiumTotalCard(total),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  "Transfer Bank Resmi",
                  Icons.business_rounded,
                ),
                const SizedBox(height: 12),
                _buildPremiumBankCard(),
                const SizedBox(height: 24),

                _buildSectionHeader(
                  "Dokumentasi Bukti",
                  Icons.cloud_done_rounded,
                ),
                const SizedBox(height: 12),
                _buildModernProofSection(showUpload),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN: BANNER STATUS PREMIUM ---
  Widget _buildModernStatusBanner(StatusUI statusUI) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusUI.bannerGrad,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusUI.color.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusUI.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusUI.bannerTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusUI.bannerSub,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: BARIS ITEM MODERN ---
  Widget _buildModernItemRow(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _T.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_activity_rounded,
              color: _T.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _T.textHead,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${item.quantity}x tiket pengunjung",
                  style: const TextStyle(fontSize: 12, color: _T.textBody),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(
              (int.tryParse(item.harga.toString()) ?? 0) * item.quantity,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: _T.primaryDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: KARTU TOTAL TAGIHAN ---
  Widget _buildPremiumTotalCard(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.primarySurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Tagihan",
                style: TextStyle(
                  fontSize: 12,
                  color: _T.textBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Termasuk pajak",
                style: TextStyle(fontSize: 10, color: _T.textMuted),
              ),
            ],
          ),
          Text(
            _formatRupiah(total),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _T.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: KARTU REKENING BANK ---
  Widget _buildPremiumBankCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: _T.textHead.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _T.bgPage,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: _T.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bank Central Asia (BCA)",
                  style: TextStyle(fontSize: 12, color: _T.textBody),
                ),
                const SizedBox(height: 4),
                const Text(
                  "1234 5678 90",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _T.textHead,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "a.n. Wisata Indonesia",
                  style: TextStyle(
                    fontSize: 11,
                    color: _T.textMuted.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.copy_rounded, color: _T.primary, size: 20),
            tooltip: "Salin Rekening",
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN: AREA UPLOAD & PREVIEW BUKTI ---
  Widget _buildModernProofSection(bool showUploadButton) {
    return Column(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _T.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: _proofUrlFromBackend != null
                ? Image.network(
                    _proofUrlFromBackend!,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(color: _T.primary),
                          ),
                    errorBuilder: (c, e, s) => _buildProofPlaceholder(
                      "Gagal memuat gambar bukti",
                      Icons.broken_image_rounded,
                    ),
                  )
                : (_imageProof != null
                      ? Image.file(_imageProof!, fit: BoxFit.cover)
                      : _buildProofPlaceholder(
                          !showUploadButton
                              ? "Dokumen Tersimpan"
                              : "Belum ada file diunggah",
                          Icons.image_search_rounded,
                        )),
          ),
        ),
        if (showUploadButton) const SizedBox(height: 16),
        if (showUploadButton)
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: _T.headerGrad),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _T.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Unggah Bukti Transfer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProofPlaceholder(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _T.textMuted.withOpacity(0.5), size: 48),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: _T.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  KOMPONEN ARSITEKTURAL GLOBAL
  // ════════════════════════════════════════════════════════

  // --- HEADER SLIVER LENGKUNG PREMIUM ---
  Widget _buildSliverHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onBack,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _T.headerGrad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 80,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null) ...[
                      IconButton(
                        onPressed: onBack,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(10),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FLOATING BOTTOM NAVIGATION BAR ---
  Widget? _buildBottomBar() {
    if (_isBookingCreated || (widget.items.isEmpty && !_isBookingCreated)) {
      return null;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _T.textHead.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Tagihan",
                    style: TextStyle(
                      fontSize: 11,
                      color: _T.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatRupiah(widget.totalHarga),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _T.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _handleCreateBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: _T.primary.withOpacity(0.4),
              ),
              child: const Row(
                children: [
                  Text(
                    "Buat Pesanan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER STRUKTUR ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _T.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _T.textHead,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _T.divider.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: _T.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? "Tiket Tidak Ditemukan"
                  : "Belum Ada Transaksi",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _T.textHead,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? "Pastikan kode pencarian Anda sudah benar"
                  : "Tiket pesanan Anda akan muncul di sini",
              style: const TextStyle(color: _T.textBody, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuksesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _T.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_done_rounded,
                  color: _T.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Bukti Berhasil Terkirim!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _T.textHead,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Admin akan melakukan verifikasi pembayaran Anda sesegera mungkin.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _T.textBody),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _T.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Selesai & Kembali",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusUI {
  final String label;
  final String actionText;
  final Color color;
  final IconData icon;
  final String bannerTitle;
  final String bannerSub;
  final List<Color> bannerGrad;

  StatusUI({
    required this.label,
    required this.actionText,
    required this.color,
    required this.icon,
    required this.bannerTitle,
    required this.bannerSub,
    required this.bannerGrad,
  });
}
