import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/api_service.dart';

class CartItem {
  final String productId;
  final String name;
  final String harga;
  final String kategori;
  final DateTime? addedAt;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.harga,
    required this.kategori,
    this.quantity = 1,
    this.addedAt,
  });

  int get hargaInt =>
      int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get subtotal => hargaInt * quantity;
}

class CartModel extends ChangeNotifier {
  CartModel._internal();
  static final CartModel instance = CartModel._internal();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  int get totalHarga => _items.fold(0, (sum, i) => sum + i.subtotal);
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  // Sync data dari server ke lokal
  void updateItemsFromServer(List<dynamic> serverCart) {
    _items.clear();
    for (var data in serverCart) {
      if (data is Map) {
        _items.add(
          CartItem(
            productId: (data['productId'] ?? '').toString(),
            name: data['name']?.toString() ?? 'Tiket Wisata',
            harga: (data['price'] ?? data['harga'] ?? '0').toString(),
            kategori: data['kategori']?.toString() ?? 'Tiket',
            quantity: data['quantity'] ?? 1,
            addedAt: DateTime.now(),
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> addItem(
    Map<String, String> data,
    int qty,
  ) async {
    final String? pId = data['productId'];
    if (pId == null || pId.isEmpty)
      return {"success": false, "message": "ID Kosong"};

    // result di sini sekarang pasti Map, bukan bool lagi
    Map<String, dynamic> result = await ApiService.addToCart(pId, qty);

    if (result['success'] == true) {
      final idx = _items.indexWhere((i) => i.productId == pId);
      if (idx != -1) {
        _items[idx].quantity += qty;
      } else {
        _items.add(
          CartItem(
            productId: pId,
            name: data['name'] ?? '',
            harga: data['hargaNum'] ?? '0',
            kategori: data['kategori'] ?? 'Tiket',
            quantity: qty,
          ),
        );
      }
      notifyListeners();
    }
    return result; // Pastikan mengembalikan Map
  }

  Future<Map<String, dynamic>> removeItem(String productId) async {
    final result = await ApiService.removeFromCart(productId);
    if (result['success'] == true) {
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
    }
    return result;
  }

  Future<Map<String, dynamic>> clear() async {
    final result = await ApiService.clearCart();
    if (result['success'] == true) {
      _items.clear();
      notifyListeners();
    }
    return result;
  }

  void clearLocal() {
    _items.clear();
    notifyListeners();
  }
}
