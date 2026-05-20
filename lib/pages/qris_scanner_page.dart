import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../helper/snackbar_helper.dart';

// =====================================================================
//  QRIS SCANNER PAGE  — Fixed version
//  Fixes:
//    1. Camera error handler (Device error code 4/5)
//    2. Camera stop guard (prevent stop() on uninitialized camera)
//    3. Torch & switchCamera guards
//    4. _resetScan: restart hanya jika camera initialized
//    5. _detailRow Expanded wrapper (text overflow)
// =====================================================================

class QrisScannerPage extends StatefulWidget {
  const QrisScannerPage({super.key});

  @override
  State<QrisScannerPage> createState() => _QrisScannerPageState();
}

class _QrisScannerPageState extends State<QrisScannerPage>
    with WidgetsBindingObserver {
  static const teal500  = Color(0xFF319795);
  static const teal400  = Color(0xFF4DB6AC);
  static const charcoal = Color(0xFF2D3748);

  late final MobileScannerController _camCtrl;

  bool _torchOn     = false;
  bool _scanning    = true;
  bool _loadingData = false;
  bool _cameraError = false; // FIX #1: track camera error state

  String?               _scannedRaw;
  String?               _successMsg;
  Map<String, dynamic>? _bookingData;
  String?               _errorMsg;

  @override
  void initState() {
    super.initState();
    _initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  // FIX #1: Pisahkan inisialisasi kamera agar bisa di-retry
  void _initCamera() {
    _camCtrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() => _cameraError = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FIX #2: Guard isInitialized sebelum stop/start
    if (!_camCtrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _camCtrl.stop();
    } else if (state == AppLifecycleState.resumed && _scanning) {
      _camCtrl.start();
    }
  }

  // ── Ekstrak ticket code dari raw QR ──
  String? _parseTicketCode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (json['ticket_code'] ??
              json['bookingId'] ??
              json['booking_id'] ??
              json['id'])
          ?.toString();
    } catch (_) {}
    final trimmed = raw.trim();
    return trimmed.isNotEmpty ? trimmed : null;
  }

  // ── Dipanggil setiap QR berhasil terbaca ──
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loadingData) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;
    setState(() {
      _scanning    = false;
      _scannedRaw  = raw;
      _loadingData = true;
      _bookingData = null;
      _errorMsg    = null;
    });

    // FIX #2: Guard stop
    if (_camCtrl.value.isInitialized) {
      await _camCtrl.stop();
    }

    final ticketCode = _parseTicketCode(raw);
    if (ticketCode == null) {
      setState(() {
        _errorMsg    = 'QR tidak valid. Bukan format tiket wisata.';
        _loadingData = false;
      });
      return;
    }

    // 1. Check-In API → /payment/check-in/:ticketCode (param)
    final checkInResult = await ApiService.checkIn(ticketCode: ticketCode);
    if (!mounted) return;

    // 2. Tampilkan SnackBar (selalu, seperti semula)
    CustomSnackBar.show(
      context,
      checkInResult["message"] ?? "Memproses tiket...",
      checkInResult["success"] ?? false,
    );

    // Cek apakah check-in gagal — toleran terhadap berbagai format response
    final rawSuccess = checkInResult["success"];
    final bool checkInSuccess = rawSuccess == true ||
        rawSuccess == 1 ||
        rawSuccess?.toString().toLowerCase() == 'true';

    if (!checkInSuccess) {
      setState(() {
        _errorMsg    = checkInResult["message"] ?? 'Gagal memverifikasi tiket.';
        _loadingData = false;
      });
      return;
    }

    // 3. Check-in sukses → tampilkan pesan berhasil
    if (!mounted) return;
    setState(() {
      _successMsg  = checkInResult["message"]?.toString();
      _bookingData = <String, dynamic>{};
      _loadingData = false;
    });
  }

  // ── Reset → scan ulang ──
  void _resetScan() {
    setState(() {
      _scanning    = true;
      _scannedRaw  = null;
      _bookingData = null;
      _errorMsg    = null;
      _successMsg  = null;
      _loadingData = false;
      _cameraError = false;
    });
    // FIX #2: Guard start
    if (_camCtrl.value.isInitialized) {
      _camCtrl.start();
    }
  }

  // FIX #1: Restart kamera setelah error hardware
  void _retryCameraAfterError() {
    _camCtrl.dispose();
    _initCamera();
    setState(() {
      _scanning    = true;
      _scannedRaw  = null;
      _bookingData = null;
      _errorMsg    = null;
      _successMsg  = null;
      _loadingData = false;
    });
  }

  // ── Toggle torch dengan guard ──
  void _toggleTorch() {
    // FIX #3: Jangan toggle kalau kamera belum ready
    if (!_camCtrl.value.isInitialized) return;
    _camCtrl.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  // ── Switch camera dengan guard ──
  void _switchCamera() {
    // FIX #3: Jangan switch kalau kamera belum ready
    if (!_camCtrl.value.isInitialized) return;
    _camCtrl.switchCamera();
  }

  // =====================================================================
  //  BUILD
  // =====================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FIX #1: errorBuilder untuk handle Device error code 4/5
          MobileScanner(
            controller: _camCtrl,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return _buildCameraError(error.errorCode.name);
            },
          ),
          if (!_cameraError) _buildOverlay(),
          _buildTopBar(context),
          if (!_cameraError) _buildSideButtons(),
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
          CustomPaint(
            size: Size(box.maxWidth, box.maxHeight),
            painter: _OverlayPainter(cutRect: Rect.fromLTWH(l, t, cut, cut)),
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
        top: top,
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
            onTap: _toggleTorch, // FIX #3: sudah ada guard di dalam
            tooltip: 'Senter',
          ),
          const SizedBox(height: 12),
          _iconBtn(
            icon: Icons.flip_camera_ios_rounded,
            onTap: _switchCamera, // FIX #3: sudah ada guard di dalam
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

  // ── FIX #1: Camera error widget ──
  Widget _buildCameraError(String errorCode) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_off_rounded,
                    color: Colors.red.shade300, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kamera Tidak Tersedia',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Terjadi error pada kamera ($errorCode).\nPastikan izin kamera sudah diberikan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _retryCameraAfterError,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ],
          ),
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
        Text('Memproses tiket...',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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
          decoration:
              BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
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
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 20),
        _scanAgainBtn(),
      ],
    );
  }

  Widget _buildBookingCard() {
    final msg = _successMsg ?? 'Check-in berhasil.';
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: teal500.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: teal500,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Check-in Berhasil!',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: teal500),
        ),
        const SizedBox(height: 6),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade500, height: 1.5),
        ),
        const SizedBox(height: 20),
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
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  // FIX #4: Bungkus value Text dengan Expanded agar tidak overflow
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
          Expanded( // FIX #4: Expanded untuk mencegah overflow teks panjang
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: charcoal),
                  overflow: TextOverflow.ellipsis, // FIX #4
                  maxLines: 2,
                ),
              ],
            ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
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
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true)
      ..lineTo(size.width * 0.5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}