import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

// =====================================================================
//  USER PAGE  — Management Data User via ApiService
// =====================================================================
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  static const teal500 = Color(0xFF319795);
  static const charcoal = Color(0xFF2D3748);

  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _loading = false;

  final _searchCtrl = TextEditingController();

  // FIX: Tambahkan FocusNode untuk mengunci keyboard agar tidak turun
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose(); // FIX: Pastikan dibuang
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final list = await ApiService.getAllUsers();
    setState(() {
      _users = list;
      _filtered = list;
      _loading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final q = query.trim();

      if (q.isEmpty) {
        setState(() {
          _filtered = _users;
        });
        return;
      }

      setState(() => _loading = true);
      ApiService.searchUsers(q).then((list) {
        setState(() {
          _filtered = list;
          _loading = false;
        });
      });
    });
  }

  void _showDetail(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 36,
              backgroundColor: teal500.withOpacity(0.12),
              child: Text(
                _initial(user['fullname']),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: teal500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user['fullname'] ?? '-',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: charcoal,
              ),
            ),
            const SizedBox(height: 4),
            _roleChip(user['role']),
            const SizedBox(height: 20),
            _infoRow(Icons.email_outlined, 'Email', user['email'] ?? '-'),
            _infoRow(Icons.phone_outlined, 'Telepon', user['phone'] ?? '-'),
            _infoRow(Icons.badge_outlined, 'User ID', user['id'] ?? '-'),
            if (user['created_at'] != null) ...[
              _infoRow(
                Icons.calendar_today_outlined,
                'Bergabung',
                _formatDate(user['created_at']),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _initial(dynamic name) {
    final s = (name ?? '').toString().trim();
    if (s.isEmpty) return '?';
    final parts = s.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return s[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Data User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _searchCtrl.clear();
              _fetchUsers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── HEADER & SEARCH BAR ──
          Container(
            color: teal500,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  focusNode: _searchFocus, // FIX: Mengunci fokus keyboard
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau telepon...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white70,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statBadge('Total User', _users.length),
                    const SizedBox(width: 10),
                    _statBadge(
                      'User',
                      _users
                          .where(
                            (u) =>
                                (u['role'] ?? '').toString().toLowerCase() ==
                                'user',
                          )
                          .length,
                    ),
                    const SizedBox(width: 10),
                    _statBadge(
                      'Admin',
                      _users
                          .where(
                            (u) =>
                                (u['role'] ?? '').toString().toLowerCase() ==
                                'admin',
                          )
                          .length,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── AREA DAFTAR DATA ──
          Expanded(
            child: Stack(
              children: [
                // 1. Tampilkan Kosong ATAU List (Layout tidak pernah hancur)
                if (_filtered.isEmpty && !_loading)
                  _buildEmpty()
                else
                  RefreshIndicator(
                    onRefresh: () async {
                      _searchCtrl.clear();
                      await _fetchUsers();
                    },
                    color: teal500,
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Agar tetap bisa di-scroll saat kosong
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final u = _filtered[i] as Map<String, dynamic>;
                        return _buildCard(u);
                      },
                    ),
                  ),

                // 2. Loading UI Halus (Tidak mengganggu ketikan)
                if (_loading)
                  _users.isEmpty
                      // Jika data awal kosong = loading spinner di tengah
                      ? const Center(
                          child: CircularProgressIndicator(color: teal500),
                        )
                      // Jika sedang mencari = loading bar halus di bagian atas
                      : const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            color: teal500,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () => _showDetail(user),
      child: Container(
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: teal500.withOpacity(0.12),
            child: Text(
              _initial(user['fullname']),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: teal500,
                fontSize: 16,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user['fullname'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: charcoal,
                  ),
                ),
              ),
              _roleChip(user['role']),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 11,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      user['email'] ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (user['phone'] != null && user['phone'] != '') ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 11,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        user['phone'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _roleChip(dynamic role) {
    final r = (role ?? 'user').toString().toLowerCase();
    final isAdmin = r == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFF319795).withOpacity(0.1)
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isAdmin ? teal500 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: teal500.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: teal500, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchCtrl.text.isNotEmpty
                ? 'User tidak ditemukan'
                : 'Belum ada data user',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
