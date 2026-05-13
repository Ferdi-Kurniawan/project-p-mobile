import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/pages/booking_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  @override
  void initState() {
    super.initState();
    CartModel.instance.addListener(_refresh);
  }

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
                    primary: Colors.deepOrange,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF1A1A1A),
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

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon konfirmasi
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.shade700,
                          Colors.orange.shade400
                        ],
                      ),
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
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                 Text(
  "${CartModel.instance.totalItems} tiket · ${_formatRupiah(CartModel.instance.totalHarga)}",
  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
),
const SizedBox(height: 6),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.info_outline_rounded, size: 12, color: Colors.orange.shade400),
    const SizedBox(width: 4),
    Text(
      "Batas kunjungan 7 hari",
      style: TextStyle(
        fontSize: 12,
        color: Colors.orange.shade600,
        fontWeight: FontWeight.w600,
      ),
    ),
  ],
),
const SizedBox(height: 24),

                  // ── FORM PEMILIHAN TANGGAL ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 16, color: Colors.deepOrange.shade700),
                            const SizedBox(width: 6),
                            Text(
                              "Tanggal Kunjungan",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.deepOrange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Baris tanggal mulai & selesai
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
                                          ? Colors.deepOrange
                                          : Colors.grey.shade300,
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
                                          color: Colors.grey.shade500,
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
                                              ? Colors.deepOrange
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.arrow_forward_rounded,
                                  size: 16, color: Colors.grey.shade400),
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
                                        ? Colors.grey.shade50
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: tanggalSelesai != null
                                          ? Colors.deepOrange
                                          : Colors.grey.shade300,
                                      width: tanggalSelesai != null ? 1.5 : 1,
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
                                          color: Colors.grey.shade500,
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
                                              ? Colors.deepOrange
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Info durasi
                        if (durasi > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    size: 14,
                                    color: Colors.deepOrange.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "$durasi hari kunjungan  ·  "
                                    "${namaHari(tanggalMulai!)} – ${namaHari(tanggalSelesai!)}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepOrange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Petunjuk jika belum pilih
                        if (durasi == 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Pilih tanggal mulai dan selesai kunjungan wisata",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ── AKHIR FORM TANGGAL ──

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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepOrange.shade700,
                                    Colors.orange.shade400
                                  ],
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A1A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text("${item.quantity}x · ${item.loc}",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400)),
                                ],
                              ),
                            ),
                            Text(
                              _formatRupiah(item.subtotal),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.deepOrange),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700)),
                      Text(
                        _formatRupiah(CartModel.instance.totalHarga),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepOrange),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tombol Bayar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                     onPressed: (tanggalMulai == null || tanggalSelesai == null)
    ? null
    : () {
        Navigator.pop(context); // tutup modal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingPage(
              items: CartModel.instance.items.toList(),
              tanggalMulai: tanggalMulai!,
              tanggalSelesai: tanggalSelesai!,
              totalHarga: CartModel.instance.totalHarga,
            ), 
          ),
        );
      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (tanggalMulai == null || tanggalSelesai == null)
                            ? Colors.grey.shade300
                            : Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        (tanggalMulai == null || tanggalSelesai == null)
                            ? "Pilih Tanggal Dulu"
                            : "Bayar Sekarang",
                        style: TextStyle(
                          color: (tanggalMulai == null || tanggalSelesai == null)
                              ? Colors.grey.shade500
                              : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Batal",
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
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
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          Container(
            height: 240,
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
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
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
                              const Text("🛒 ", style: TextStyle(fontSize: 16)),
                              Text(
                                "Keranjang",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tiket Wisatamu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      if (items.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text("Kosongkan Keranjang?",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                                content: const Text(
                                    "Semua tiket di keranjang akan dihapus.",
                                    style: TextStyle(fontSize: 13)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Batal",
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      CartModel.instance.clear();
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "${items.length} item",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: items.isEmpty
                        ? _buildEmptyState()
                        : _buildCartList(items),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
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
                  // Total harga
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Pembayaran",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRupiah(CartModel.instance.totalHarga),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepOrange,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: _checkout,
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
                        "Checkout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildCartCard(items[index]),
    );
  }

  Widget _buildCartCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
                Container(
                  width: 52,
                  height: 52,
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
                    size: 26,
                  ),
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
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 12, color: Colors.deepOrange.shade300),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.loc,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
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

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.kategori,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: List.generate(
                32,
                (i) => Expanded(
                  child: Container(
                    height: 1,
                    color: i % 2 == 0
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Harga",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(item.subtotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepOrange,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: () => CartModel.instance.removeItem(item.name),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 18, color: Colors.red.shade400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.deepOrange.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Keranjang Kosong",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tambahkan tiket dari halaman wisata",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}