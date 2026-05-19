import 'package:flutter/material.dart';
import '../services/api_service.dart';

// =====================================================================
//  KATEGORI PAGE  — CRUD lengkap via ApiService
//  API:
//    GET    /category            → getCategories()
//    GET    /category/:id        → getCategoryById(id)
//    POST   /category            → createCategory(name)
//    PUT    /category/:id        → updateCategory(id, name)
//    DELETE /category/:id        → deleteCategory(id)
// =====================================================================
class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  static const teal500 = Color(0xFF319795);
  static const charcoal = Color(0xFF2D3748);

  List<dynamic> _categories = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // ── Fetch semua kategori ──
  Future<void> _fetchCategories() async {
    setState(() => _loading = true);
    final list = await ApiService.getCategories();
    setState(() {
      _categories = list;
      _loading = false;
    });
  }

  // ── Snackbar helper ──
  void _snack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? teal500 : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Dialog Tambah / Edit ──
  void _showFormDialog({Map<String, dynamic>? existing}) {
    final ctrl = TextEditingController(text: existing?['name'] ?? '');
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
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
                  isEdit ? 'Edit Kategori' : 'Tambah Kategori',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Contoh: Wisata Alam',
                    prefixIcon:
                        const Icon(Icons.category_outlined, color: teal500),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: teal500, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            final name = ctrl.text.trim();
                            if (name.isEmpty) {
                              _snack('Nama kategori tidak boleh kosong',
                                  success: false);
                              return;
                            }
                            setModal(() => saving = true);

                            Map<String, dynamic> res;
                            if (isEdit) {
                              res = await ApiService.updateCategory(
                                existing!['id'].toString(),
                                name,
                              );
                            } else {
                              res = await ApiService.createCategory(name);
                            }

                            setModal(() => saving = false);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            _snack(res['message'] ?? 'Berhasil',
                                success: res['success'] == true);
                            if (res['success'] == true) _fetchCategories();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(isEdit ? 'Simpan Perubahan' : 'Tambah',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Dialog konfirmasi hapus ──
  void _confirmDelete(Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kategori?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(
          'Kategori "${cat['name']}" akan dihapus secara permanen.',
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
              final res =
                  await ApiService.deleteCategory(cat['id'].toString());
              _snack(res['message'] ?? 'Selesai',
                  success: res['success'] == true);
              if (res['success'] == true) _fetchCategories();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Kelola Kategori',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _fetchCategories,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Kategori',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: teal500))
          : _categories.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _fetchCategories,
                  color: teal500,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i] as Map<String, dynamic>;
                      return _buildCard(cat);
                    },
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> cat) {
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: teal500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.category_outlined,
              color: teal500, size: 22),
        ),
        title: Text(
          cat['name'] ?? '-',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: charcoal),
        ),
        subtitle: Text(
          'ID: ${cat['id'] ?? '-'}',
          style: const TextStyle(fontSize: 11, color: Colors.black38),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: teal500, size: 20),
              tooltip: 'Edit',
              onPressed: () => _showFormDialog(existing: cat),
            ),
            // Hapus
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.shade400, size: 20),
              tooltip: 'Hapus',
              onPressed: () => _confirmDelete(cat),
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
          Icon(Icons.category_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada kategori',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk menambahkan',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
