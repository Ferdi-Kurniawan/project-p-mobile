import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/pages/booking_page.dart';
import 'package:flutter_application_2/services/api_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  DateTime? _start; DateTime? _end;

  @override
  void initState() {
    super.initState();
    CartModel.instance.addListener(_refresh);
    _sync();
  }

  @override
  void dispose() {
    CartModel.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _sync() async {
    final data = await ApiService.fetchCartFromServer();
    if (mounted) {
      CartModel.instance.updateItemsFromServer(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = CartModel.instance.items;
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),
      body: items.isEmpty ? const Center(child: Text("Kosong")) : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => ListTile(
          title: Text(items[i].name),
          subtitle: Text("${items[i].quantity}x - Rp ${items[i].subtotal}"),
          trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => CartModel.instance.removeItem(items[i].productId)),
        ),
      ),
      bottomNavigationBar: items.isEmpty ? null : ElevatedButton(
        onPressed: _showCheckout,
        child: Text("Bayar (${CartModel.instance.totalHarga})"),
      ),
    );
  }

void _showCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tambahkan ini agar tidak tertutup keyboard
      builder: (context) => StatefulBuilder(
        builder: (context, setST) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pilih Tanggal Kunjungan", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30))
                        );
                        if (d != null) setST(() => _start = d);
                      },
                      child: Text(_start == null ? "Tanggal Mulai" : _start.toString().split(' ')[0]),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _start ?? DateTime.now(),
                          firstDate: _start ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30))
                        );
                        if (d != null) setST(() => _end = d);
                      },
                      child: Text(_end == null ? "Tanggal Selesai" : _end.toString().split(' ')[0]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_start == null || _end == null)
                      ? null
                      : () async {
                          // Tampilkan loading
                          showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

                          String? bId = await ApiService.createDraftBooking(_start!, _end!);

                          Navigator.pop(context); // Tutup loading

                          if (bId != null) {
                            Navigator.pop(context); // Tutup BottomSheet
                            
                            // 🔥 FIX DI SINI: Panggil CartModel.instance.items secara langsung
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingPage(
                                  bookingId: bId,
                                  items: CartModel.instance.items.toList(), // AMBIL DARI MODEL
                                  tanggalMulai: _start!,
                                  tanggalSelesai: _end!,
                                  totalHarga: CartModel.instance.totalHarga,
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: const Text("Konfirmasi Bayar", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}