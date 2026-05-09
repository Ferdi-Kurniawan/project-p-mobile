import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:flutter_application_2/services/api_service.dart';

class TiketPage extends StatefulWidget {
  const TiketPage({super.key});
  @override
  State<TiketPage> createState() => _TiketPageState();
}

class _TiketPageState extends State<TiketPage> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Destinasi Wisata"), backgroundColor: Colors.deepOrange),
      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                child: ListTile(
                  title: Text(p['name'] ?? ''),
                  subtitle: Text("Rp ${p['price']} - ${p['location']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showQtySheet(p),
                    child: const Text("Pesan"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showQtySheet(dynamic p) {
    int qty = 1;
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setST) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () => setST(() => qty > 1 ? qty-- : null), icon: const Icon(Icons.remove)),
                  Text("$qty", style: const TextStyle(fontSize: 24)),
                  IconButton(onPressed: () => setST(() => qty++), icon: const Icon(Icons.add)),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  await CartModel.instance.addItem({
                    'productId': p['id'].toString(),
                    'name': p['name'],
                    'loc': p['location'] ?? '',
                    'hargaNum': p['price'].toString(),
                  }, qty);
                  Navigator.pop(context);
                },
                child: const Text("Tambah ke Keranjang"),
              )
            ],
          ),
        ),
      ),
    );
  }
}