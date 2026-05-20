import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../helper/snackbar_helper.dart'; // Pastikan path import ini sesuai

// =====================================================================
//  QRIS SCANNER PAGE
// =====================================================================

class QrisScannerPage extends StatefulWidget {
  const QrisScannerPage({super.key});
  
  @override
  State<QrisScannerPage> createState() => _QrisScannerPageState();
}

class _QrisScannerPageState extends State<QrisScannerPage>
    with WidgetsBindingObserver {
  static const teal500   = Color(0xFF319795);
  static const teal400   = Color(0xFF4DB6AC);
  static const charcoal  = Color(0xFF2D3748);
  
  final MobileScannerController _camCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  bool _torchOn     = false;
  bool _scanning    = true; 
  bool _loadingData = false;

  // Hasil scan terakhir
  String?               _scannedRaw;
  Map<String, dynamic>? _bookingData;
  String?               _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camCtrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _camCtrl.stop();
    } else if (state == AppLifecycleState.resumed) {
      _camCtrl.start();
    }
  }

  // ── Ekstrak ticket code / bookingId dari raw QR ──
  String? _parseBookingId(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['ticket_code'] ?? json['bookingId'] ?? json['booking_id'] ?? json['id'])
          ?.toString();
    } catch (_) {}
    
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return null;
  }

  // ── Dipanggil setiap QR berhasil terbaca ──
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loadingData) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;
    setState(() {
      _scanning    = false; 
      _scannedRaw  = raw;
      _loadingData = true;
      _bookingData = null;
      _errorMsg    = null;
    });
    
    await _camCtrl.stop(); 

    final ticketCode = _parseBookingId(raw);
    if (ticketCode == null) {
      setState(() {
        _errorMsg    = 'QR tidak valid. Bukan format tiket wisata.';
        _loadingData = false;
      });
      return;
    }

    // 1. Tembak API Check-In
    final checkInResult = await ApiService.checkIn(ticketCode: ticketCode);
    
    if (!mounted) return;

    // 2. Munculkan Notifikasi Custom SnackBar
    CustomSnackBar.show(
      context,
      checkInResult["message"] ?? "Memproses tiket...",
      checkInResult["success"] ?? false,
    );

    // 3. Ambil detail booking dari API untuk ditampilkan di UI
    final data = await ApiService.getHistoryBookingById(ticketCode);
    if (!mounted) return;

    if (data != null) {
      setState(() {
        _bookingData = data;
        _loadingData = false;
      });
    } else {
      setState(() {
        _errorMsg    = 'Detail tiket tidak dapat dimuat.\nID: $ticketCode';
        _loadingData = false;
      });
    }
  }

  // ── Reset → scan ulang ──
  void _resetScan() {
    setState(() {
      _scanning    = true;
      _scannedRaw  = null;
      _bookingData = null;
      _errorMsg    = null;
      _loadingData = false;
    });
    _camCtrl.start();
  }

  // ── Toggle torch ──
  void _toggleTorch() {
    _camCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _camCtrl,
            onDetect: _onDetect,
          ),
          _buildOverlay(),
          _buildTopBar(context),
          _buildSideButtons(),
          if (_loadingData || _bookingData != null || _errorMsg != null)
            _buildResultPanel(),
        ],
      ),
    );
  }

  // ── Overlay viewfinder ──
  Widget _buildOverlay() {
    const cut = 260.0;
    return LayoutBuilder(builder: (context, box) {
      final cx = box.maxWidth / 2;
      final cy = box.maxHeight / 2 - 40;
      final l  = cx - cut / 2;
      final t  = cy - cut / 2;

      return Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: _OverlayPainter(
                cutRect: Rect.fromLTWH(l, t, cut, cut),
              ),
            ),
          ),
          ..._corners(l, t, cut),
          Positioned(
            left: 0,
            right: 0,
            top: t + cut + 20,
            child: const Text(
              'Arahkan kamera ke QR tiket',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _corners(double l, double t, double size) {
    const len   = 28.0;
    const thick = 3.5;
    const r     = 6.0;
    final color = teal400;
    
    Widget corner({
      required double left,
      required double top,
      bool flipH = false,
      bool flipV = false,
    }) {
      return Positioned(
        left: left,
        top:  top,
        child: Transform.scale(
          scaleX: flipH ? -1 : 1,
          scaleY: flipV ? -1 : 1,
          child: SizedBox(
            width: len,
            height: len,
            child: CustomPaint(
              painter: _CornerPainter(color: color, thick: thick, r: r),
            ),
          ),
        ),
      );
    }

    return [
      corner(left: l,              top: t),
      corner(left: l + size - len, top: t,              flipH: true),
      corner(left: l,              top: t + size - len, flipV: true),
      corner(left: l + size - len, top: t + size - len, flipH: true, flipV: true),
    ];
  }

  // ── Top bar ──
  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Scan QRIS Tiket',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tombol torch & flip kamera ──
  Widget _buildSideButtons() {
    return Positioned(
      bottom: 220,
      right: 20,
      child: Column(
        children: [
          _iconBtn(
            icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            active: _torchOn,
            onTap: _toggleTorch,
            tooltip: 'Senter',
          ),
          const SizedBox(height: 12),
          _iconBtn(
            icon: Icons.flip_camera_ios_rounded,
            onTap: () => _camCtrl.switchCamera(),
            tooltip: 'Balik kamera',
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: active
                ? teal500.withOpacity(0.85)
                : Colors.black.withOpacity(0.45),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? teal400 : Colors.white24,
              width: 1.2,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  // ── Panel hasil / loading / error ──
  Widget _buildResultPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.28,
      maxChildSize: 0.75,
      snap: true,
      builder: (ctx, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: sc,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (_loadingData) _buildLoading(),
                if (_errorMsg != null) _buildError(),
                if (_bookingData != null) _buildBookingCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CircularProgressIndicator(color: teal500),
        const SizedBox(height: 16),
        Text(
          'Memproses tiket...',
          style: TextStyle(
              fontSize: 14, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 8),
        Text(
          _scannedRaw ?? '',
          style: const TextStyle(fontSize: 11, color: Colors.black38),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.qr_code_2_rounded,
              color: Colors.red.shade400, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'Gagal Memproses Tiket',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748)),
        ),
        const SizedBox(height: 6),
        Text(
          _errorMsg ?? '',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 20),
        _scanAgainBtn(),
      ],
    );
  }

  Widget _buildBookingCard() {
    final b      = _bookingData!;
    final status = (b['status'] ?? '').toString().toUpperCase();
    final isValid = status == 'PAID' || status == 'COMPLETED';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isValid
                    ? teal500.withOpacity(0.1)
                    : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isValid
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                color: isValid ? teal500 : Colors.orange.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isValid ? 'Tiket Valid' : 'Tiket Bermasalah',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isValid ? teal500 : Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _statusBadge(status),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        const Divider(height: 1),
        const SizedBox(height: 16),

        _detailRow(Icons.person_outline_rounded, 'Nama',
            b['user']?['fullname'] ?? b['user_id']?.toString() ?? '-'),
        _detailRow(Icons.email_outlined, 'Email',
            b['user']?['email'] ?? '-'),
        _detailRow(Icons.receipt_long_outlined, 'Booking ID',
            (b['id']?.toString() ?? '-').length > 16
                ? '${b['id'].toString().substring(0, 16)}...'
                : b['id']?.toString() ?? '-'),
        _detailRow(Icons.calendar_today_outlined, 'Mulai',
            _fmtDate(b['startDate'] ?? b['start_date'])),
        _detailRow(Icons.calendar_today_outlined, 'Selesai',
            _fmtDate(b['endDate'] ?? b['end_date'])),
        _detailRow(Icons.payments_outlined, 'Total',
            _fmtRupiah(b['total_price'])),

        const SizedBox(height: 22),
        _scanAgainBtn(),
      ],
    );
  }

  Widget _statusBadge(String status) {
    const colors = {
      'PENDING':              Color(0xFFF6AD55),
      'PENDING_VERIFICATION': Color(0xFF4299E1),
      'PAID':                 Color(0xFF48BB78),
      'CANCELLED':            Color(0xFFFC8181),
      'COMPLETED':            Color(0xFF319795),
    };
    const labels = {
      'PENDING':              'Menunggu Bayar',
      'PENDING_VERIFICATION': 'Menunggu Verifikasi',
      'PAID':                 'Lunas',
      'CANCELLED':            'Dibatalkan',
      'COMPLETED':            'Selesai',
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: teal500.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: teal500, size: 17),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black38)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: charcoal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scanAgainBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _resetScan,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan Tiket Lagi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: teal500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  String _fmtDate(dynamic val) {
    if (val == null) return '-';
    try {
      final dt = DateTime.parse(val.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
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
}

// =====================================================================
//  CUSTOM PAINTERS
// =====================================================================

class _OverlayPainter extends CustomPainter {
  final Rect cutRect;
  const _OverlayPainter({required this.cutRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);
    final full  = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(cutRect, const Radius.circular(16));

    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, paint);
    canvas.drawRRect(
        rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.cutRect != cutRect;
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thick;
  final double r;
  
  const _CornerPainter(
      {required this.color, required this.thick, required this.r});
      
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = thick
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;
      
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(size.width * 0.5, 0);
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}