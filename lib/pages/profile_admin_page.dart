import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'kategori_page.dart';
import 'produk_page.dart';
import 'user_page.dart';
import 'histori_booking_page.dart';
import 'qris_scanner_page.dart';

// =====================================================================
//  PROFILE ADMIN PAGE
// =====================================================================
class ProfileAdminPage extends StatefulWidget {
  const ProfileAdminPage({super.key});

  @override
  State<ProfileAdminPage> createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  // ── Palet warna ──
  static const Color teal500 = Color(0xFF319795);
  static const Color teal400 = Color(0xFF4DB6AC);
  static const Color white   = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF2D3748);

  String _adminName  = 'Admin Wisata';
  String _adminEmail = 'admin@wisata.com';
  bool   _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final res = await ApiService.getProfile();
    if (res['success'] == true && res['user'] != null) {
      final u = res['user'] as Map<String, dynamic>;
      setState(() {
        _adminName  = u['fullname'] ?? _adminName;
        _adminEmail = u['email']    ?? _adminEmail;
      });
    }
    setState(() => _loadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildProfileHero(),
                ),
                const SizedBox(height: 8),

                // ── Manajemen Konten ──
                _buildSectionHeader("MANAJEMEN KONTEN"),
                _buildMenuCard(
                  context,
                  Icons.category_outlined,
                  "Kelola Kategori",
                  subtitle: "Tambah, edit & hapus kategori wisata",
                  onTap: () => _navigateTo(context, const KategoriPage()),
                ),
                _buildMenuCard(
                  context,
                  Icons.inventory_2_outlined,
                  "Kelola Paket",
                  subtitle: "Tambah, edit & hapus paket wisata",
                  onTap: () => _navigateTo(context, const ProdukPage()),
                ),

                const SizedBox(height: 8),
                // ── Manajemen Booking ──
                _buildSectionHeader("MANAJEMEN BOOKING"),
                _buildMenuCard(
                  context,
                  Icons.history_edu_outlined,
                  "Histori Booking",
                  subtitle: "Lihat semua riwayat transaksi",
                  onTap: () => _navigateTo(context, const HistoriBookingPage()),
                ),
                _buildMenuCard(
                  context,
                  Icons.verified_outlined,
                  "Verifikasi Booking",
                  subtitle: "Konfirmasi pembayaran masuk",
                  onTap: () => _navigateTo(
                    context,
                    const HistoriBookingPage(filterStatus: 'PENDING_VERIFICATION'),
                  ),
                ),
                _buildMenuCard(
                  context,
                  Icons.cancel_outlined,
                  "Batal Booking",
                  subtitle: "Tolak & batalkan transaksi",
                  onTap: () => _navigateTo(
                    context,
                    const HistoriBookingPage(filterStatus: 'CANCELLED'),
                  ),
                ),
                _buildMenuCard(
                  context,
                  Icons.qr_code_scanner_rounded,
                  "Scan QRIS Tiket",
                  subtitle: "Verifikasi tiket via kamera",
                  onTap: () => _navigateTo(context, const QrisScannerPage()),
                ),

                const SizedBox(height: 8),
                // ── Manajemen User ──
                _buildSectionHeader("MANAJEMEN USER"),
                _buildMenuCard(
                  context,
                  Icons.people_outline_rounded,
                  "Data User",
                  subtitle: "Lihat & kelola data pengguna",
                  onTap: () => _navigateTo(context, const UserPage()),
                ),

                const SizedBox(height: 8),
                // ── Akun ──
                _buildSectionHeader("AKUN"),
                _buildMenuCard(
                  context,
                  Icons.person_outline_rounded,
                  "Profil Saya",
                  subtitle: "Lihat & edit profil admin",
                  onTap: () => _navigateTo(context, const DetailProfilePage()),
                ),

                const SizedBox(height: 8),
                // ── Sistem ──
                _buildSectionHeader("SISTEM"),
                _buildMenuCard(
                  context,
                  Icons.logout_rounded,
                  "Keluar",
                  subtitle: "Akhiri sesi admin",
                  isDestructive: true,
                  onTap: () => _logout(context),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Hero header bergaya glassmorphism (sama persis dengan aslinya) ──
  Widget _buildProfileHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: _loadingProfile
              ? const SizedBox(
                  height: 86,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: teal500.withOpacity(0.25),
                            border: Border.all(color: teal400, width: 2.5),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: teal500,
                            shape: BoxShape.circle,
                            border: Border.all(color: white, width: 2),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _adminName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _adminEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.black45,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.red.shade400 : teal500;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDestructive ? Colors.red.shade400 : charcoal,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black45))
              : null,
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Colors.black26),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: white,
        title: const Text(
          'Keluar dari Admin?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: charcoal),
        ),
        content: const Text(
          'Sesi admin Anda akan berakhir dan Anda harus login kembali.',
          style: TextStyle(
              fontSize: 13, color: Color(0xFF6B7E8D), height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7E8D),
                    side: const BorderSide(color: Color(0xFFCDD7DE)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Batal',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await ApiService.logout();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Keluar',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
//  DETAIL PROFILE PAGE (Edit Profil Admin)
// =====================================================================
class DetailProfilePage extends StatefulWidget {
  const DetailProfilePage({super.key});

  @override
  State<DetailProfilePage> createState() => _DetailProfilePageState();
}

class _DetailProfilePageState extends State<DetailProfilePage> {
  static const teal500 = Color(0xFF319795);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _loading = true;
  bool _saving  = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.getProfile();
    if (res['success'] == true && res['user'] != null) {
      final u = res['user'] as Map<String, dynamic>;
      _nameCtrl.text  = u['fullname'] ?? '';
      _emailCtrl.text = u['email']    ?? '';
      _phoneCtrl.text = u['phone']    ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final res = await ApiService.updateProfile(
      fullname: _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
    );
    setState(() => _saving = false);
    _showSnack(res['message'] ?? 'Selesai',
        success: res['success'] == true);
  }

  void _showSnack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? teal500 : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Profil Saya',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: teal500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  _field(_nameCtrl,  'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(_emailCtrl, 'Email',        Icons.email_outlined),
                  const SizedBox(height: 12),
                  _field(_phoneCtrl, 'No. Telepon',  Icons.phone_outlined,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Perubahan',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: teal500),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: teal500, width: 1.5)),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong' : null,
    );
  }
}