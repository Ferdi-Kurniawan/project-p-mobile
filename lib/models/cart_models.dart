import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/api_service.dart';

class CartItem {
  final String productId;
  final String name;
  final String loc;
  final String harga;
  int quantity;

  CartItem({required this.productId, required this.name, required this.loc, required this.harga, this.quantity = 1});

  int get hargaInt => int.tryParse(harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get subtotal => hargaInt * quantity;
}

class CartModel extends ChangeNotifier {
  CartModel._internal();
  static final CartModel instance = CartModel._internal();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  int get totalHarga => _items.fold(0, (sum, i) => sum + i.subtotal);
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  void updateItemsFromServer(List<dynamic> serverCart) {
    _items.clear();
    for (var item in serverCart) {
      _items.add(CartItem(
        productId: item['productId'].toString(),
        name: item['name'] ?? 'Tiket',
        loc: item['location'] ?? 'Lampung',
        harga: item['price'].toString(),
        quantity: item['quantity'] ?? 1,
      ));
    }
    notifyListeners();
  }

  Future<void> addItem(Map<String, String> data, int qty) async {
    final String? pId = data['productId'];
    if (pId == null || pId.isEmpty) return;

    bool success = await ApiService.addToRedisCart(pId, qty);
    print("Add to Redis Cart Success: $success");
    if (success) {
      final idx = _items.indexWhere((i) => i.productId == pId);
      print("Item index in local list: $idx");
      if (idx != -1) {
        _items[idx].quantity += qty;
      } else {
        _items.add(CartItem(
          productId: pId,
          name: data['name'] ?? '',
          loc: data['loc'] ?? '',
          harga: data['hargaNum'] ?? '0',
          quantity: qty,
        ));
      }
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    if (await ApiService.removeFromRedisCart(productId)) {
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
    }
  }

  Future<void> clear() async {
    await ApiService.clearCart();
    _items.clear();
    notifyListeners();
  }
  void clearLocal() {
    _items.clear();
    notifyListeners();
  }
}
