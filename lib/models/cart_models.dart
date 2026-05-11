import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String name;
  final String loc;
  final String harga;
  final String kategori;
  int quantity;
  final DateTime addedAt;

  CartItem({
    required this.productId,
    required this.name,
    required this.loc,
    required this.harga,
    required this.kategori,
    this.quantity = 1,
    required this.addedAt,
  });

  int get hargaInt {
    final clean = harga.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  int get subtotal => hargaInt * quantity;
}

class CartModel extends ChangeNotifier {
  CartModel._internal();
  static final CartModel instance = CartModel._internal();

  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalHarga => _items.fold(0, (sum, i) => sum + i.subtotal);

  void addItem(Map<String, String> data) {
    final existing = _items.where((i) => i.name == data['name']).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity++;
    } else {
      _items.add(CartItem(
        productId: data['productId'] ?? '',
        name: data['name'] ?? '',
        loc: data['loc'] ?? '',
        harga: data['harga'] ?? '',
        kategori: data['kategori'] ?? '',
        addedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  // ✅ DITAMBAH: tambah item dengan quantity langsung (dipakai dari tiket_page)
  void addItemWithQuantity(Map<String, String> data, int qty) {
    final existing = _items.where((i) => i.name == data['name']).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += qty;
    } else {
      _items.add(CartItem(
        productId: data['productId'] ?? '',
        name: data['name'] ?? '',
        loc: data['loc'] ?? '',
        harga: data['harga'] ?? '',
        kategori: data['kategori'] ?? '',
        quantity: qty,
        addedAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  void removeItem(String name) {
    _items.removeWhere((i) => i.name == name);
    notifyListeners();
  }

  void increment(String name) {
    final item = _items.firstWhere((i) => i.name == name);
    item.quantity++;
    notifyListeners();
  }

  void decrement(String name) {
    final item = _items.firstWhere((i) => i.name == name);
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.removeWhere((i) => i.name == name);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}