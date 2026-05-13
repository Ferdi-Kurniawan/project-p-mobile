import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/api_service.dart';

class CartItem {
  final String productId;
  final String name;
  final String loc;
  final String img;
  final String harga;
  final String kategori;
  final DateTime? addedAt;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.loc,
    required this.img,
    required this.harga,
    required this.kategori,
    this.quantity = 1,
    this.addedAt,
  });

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
    for (var data in serverCart) {
      if (data is Map) {
        _items.add(CartItem(
          productId: (data['productId'] ?? '').toString(),
          name: data['name']?.toString() ?? 'Tiket Wisata',
          // ✅ DITAMBAH: Fallback string jika server tidak mengirimkan loc & kategori
          loc: data['loc']?.toString() ?? 'Lokasi tidak diketahui',
          img: data['img']?.toString() ?? '',
          harga: (data['price'] ?? data['harga'] ?? '0').toString(),
          kategori: data['kategori']?.toString() ?? 'Tiket',
          quantity: data['quantity'] ?? 1,
          addedAt: DateTime.now(),
        ));
      }
    }
    notifyListeners();
  }

  // tambah item dengan quantity langsung (dipakai dari tiket_page)
  void addItemWithQuantity(Map<String, String> data, int qty) {
    final existing = _items.where((i) => i.name == data['name']).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += qty;
    } else {
      _items.add(CartItem(
        productId: data['productId'] ?? '',
        name: data['name'] ?? '',
        loc: data['loc'] ?? 'Lokasi tidak diketahui',
        img: data['img'] ?? '',
        harga: data['harga'] ?? '0',
        kategori: data['kategori'] ?? 'Tiket',
        quantity: qty,
        addedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  Future<void> addItem(Map<String, String> data, int qty) async {
    final String? pId = data['productId'];
    if (pId == null || pId.isEmpty) return;

    bool success = await ApiService.addToCart(pId, qty);
    print("Add to Cart Success: $success");
    if (success) {
      final idx = _items.indexWhere((i) => i.productId == pId);
      print("Item index in local list: $idx");
      if (idx != -1) {
        _items[idx].quantity += qty;
      } else {
        _items.add(CartItem(
          productId: pId,
          name: data['name'] ?? '',
          loc: data['loc'] ?? 'Lokasi tidak diketahui',
          img: data['img'] ?? '',
          harga: data['hargaNum'] ?? '0',
          kategori: data['kategori'] ?? 'Tiket',
          quantity: qty,
        ));
      }
      notifyListeners();
    }
  }

  // ✅ PERBAIKAN: Memastikan penghapusan menggunakan productId
  Future<void> removeItem(String productId) async {
    if (await ApiService.removeFromCart(productId)) {
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