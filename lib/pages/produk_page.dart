import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

// =====================================================================
//  PRODUK PAGE  — CRUD lengkap via ApiService
//  API:
//    GET    /product             → getProducts()
//    GET    /product/:id         → getProductById(id)
//    POST   /product             → createProduct(name, price, stock, categoryId)
//    PUT    /product/:id         → updateProduct(productId, name, price, stock, categoryId)
//    DELETE /product/:id         → deleteProduct(id)
//    GET    /category            → getCategories()  (untuk dropdown)
// =====================================================================
class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  static const teal500  = Color(0xFF319795);
  static const charcoal = Color(0xFF2D3748);

  List<dynamic> _products   = [];
  List<dynamic> _categories = [];
  bool _loading = false;

  // Filter & search
  String _searchQuery = '';
  String? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getProducts(),
      ApiService.getCategories(),
    ]);
    setState(() {
      _products   = results[0];
      _categories = results[1];
      _loading    = false;
    });
  }

  List<dynamic> get _filtered {
    return _products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          name.contains(_searchQuery.toLowerCase());
      final matchCat = _filterCategoryId == null ||
          p['category_id'].toString() == _filterCategoryId;
      return matchSearch && matchCat;
    }).toList();
  }

  void _snack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? teal500 : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Format harga Rupiah ──
  String _formatRupiah(dynamic price) {
    if (price == null) return 'Rp 0';
    final num val = num.tryParse(price.toString()) ?? 0;
    final str = val.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // ── Nama kategori dari ID ──
  String _categoryName(dynamic catId) {
    final found = _categories.firstWhere(
      (c) => c['id'].toString() == catId.toString(),
      orElse: () => null,
    );
    return found?['name'] ?? 'Tanpa Kategori';
  }

  // ── Dialog Tambah / Edit ──
  void _showFormDialog({Map<String, dynamic>? existing}) {
    final nameCtrl  = TextEditingController(text: existing?['name']  ?? '');
    final priceCtrl = TextEditingController(
        text: existing?['price']?.toString() ?? '');
    final stockCtrl = TextEditingController(
        text: existing?['stock']?.toString() ?? '0');
    String? selectedCatId = existing?['category_id']?.toString();
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEdit ? 'Edit Paket Wisata' : 'Tambah Paket Wisata',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: charcoal,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama
                  _modalField(nameCtrl, 'Nama Paket',
                      Icons.inventory_2_outlined,
                      hint: 'Contoh: Paket Pahawang 2D1N'),
                  const SizedBox(height: 12),

                  // Harga
                  _modalField(
                    priceCtrl,
                    'Harga (Rp)',
                    Icons.payments_outlined,
                    hint: 'Contoh: 250000',
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),

                  // Stok
                  _modalField(
                    stockCtrl,
                    'Stok / Kuota',
                    Icons.people_alt_outlined,
                    hint: 'Contoh: 20',
                    keyboard: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),

                  // Dropdown kategori
                  DropdownButtonFormField<String>(
                    value: selectedCatId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category_outlined,
                          color: teal500),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: teal500, width: 1.5)),
                    ),
                    hint: const Text('Pilih Kategori'),
                    items: _categories
                        .map((c) => DropdownMenuItem<String>(
                              value: c['id'].toString(),
                              child: Text(c['name'] ?? '-'),
                            ))
                        .toList(),
                    onChanged: (v) => setModal(() => selectedCatId = v),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              final price =
                                  int.tryParse(priceCtrl.text.trim()) ?? 0;
                              final stock =
                                  int.tryParse(stockCtrl.text.trim()) ?? 0;

                              if (name.isEmpty) {
                                _snack('Nama paket tidak boleh kosong',
                                    success: false);
                                return;
                              }
                              if (selectedCatId == null) {
                                _snack('Pilih kategori terlebih dahulu',
                                    success: false);
                                return;
                              }

                              setModal(() => saving = true);
                              Map<String, dynamic> res;

                              if (isEdit) {
                                res = await ApiService.updateProduct(
                                  productId:  existing!['id'].toString(),
                                  name:       name,
                                  price:      price,
                                  stock:      stock,
                                  categoryId: selectedCatId!,
                                );
                              } else {
                                res = await ApiService.createProduct(
                                  name:       name,
                                  price:      price,
                                  stock:      stock,
                                  categoryId: selectedCatId!,
                                );
                              }

                              setModal(() => saving = false);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              _snack(res['message'] ?? 'Berhasil',
                                  success: res['success'] == true);
                              if (res['success'] == true) _fetchAll();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal500,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambah Paket',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _confirmDelete(Map<String, dynamic> prod) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Paket?',
            style:
                TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(
          'Paket "${prod['name']}" akan dihapus secara permanen.',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService.deleteProduct(
                  prod['id'].toString());
              _snack(res['message'] ?? 'Selesai',
                  success: res['success'] == true);
              if (res['success'] == true) _fetchAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Kelola Paket Wisata',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Paket',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: teal500))
          : Column(
              children: [
                // ── Search & Filter bar ──
                Container(
                  color: teal500,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // Search
                      TextField(
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari paket wisata...',
                          hintStyle:
                              const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Filter kategori
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip('Semua', null),
                            ..._categories.map(
                              (c) => _filterChip(
                                  c['name'], c['id'].toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Daftar produk ──
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _fetchAll,
                          color: teal500,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 16, 16, 100),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final p =
                                  filtered[i] as Map<String, dynamic>;
                              return _buildCard(p);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String label, String? catId) {
    final selected = _filterCategoryId == catId;
    return GestureDetector(
      onTap: () => setState(() => _filterCategoryId = catId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? teal500 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> prod) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF319795), Color(0xFF4DB6AC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.place_rounded,
              color: Colors.white, size: 24),
        ),
        title: Text(
          prod['name'] ?? '-',
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: charcoal),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              _formatRupiah(prod['price']),
              style: const TextStyle(
                  color: teal500,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 11, color: Colors.black38),
                const SizedBox(width: 3),
                Text(
                  _categoryName(prod['category_id']),
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black38),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.people_alt_outlined,
                    size: 11, color: Colors.black38),
                const SizedBox(width: 3),
                Text(
                  'Stok: ${prod['stock'] ?? 0}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: teal500, size: 20),
              tooltip: 'Edit',
              onPressed: () => _showFormDialog(existing: prod),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.shade400, size: 20),
              tooltip: 'Hapus',
              onPressed: () => _confirmDelete(prod),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada paket wisata',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk menambahkan',
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  // ── Field helper untuk modal ──
  Widget _modalField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: teal500),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: teal500, width: 1.5)),
      ),
    );
  }
}
