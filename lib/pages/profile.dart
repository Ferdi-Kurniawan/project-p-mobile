import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../helper/snackbar_helper.dart'; // Ditambahkan untuk notifikasi
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _notifEnabled = true;
  bool _darkMode = false;
  bool _editingEmail = false;
  bool _editingPhone = false;
  bool _editingPassword = false;

  // Variabel state untuk menampung data user
  String _fullname = '';
  String _email = '';
  String _phone = '';
  String _username = '';

  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color teal500 = Color(0xFF319795);
  static const Color teal400 = Color(0xFF4DB6AC);
  static const Color teal100 = Color(0xFFB2DFDB);
  static const Color charcoal = Color(0xFF2D3748);
  static const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal dari data yang dilempar dari halaman sebelumnya
    _email = widget.userData['email'] ?? '';
    _phone = widget.userData['phone'] ?? '';
    _username = widget.userData['username'] ?? '';

    // Memuat data nama dari session lokal
    _loadSessionData();

    // Tarik data terbaru dari server (GET PROFILE)
    _fetchProfileFromServer();

    _emailController = TextEditingController(text: _email);
    _phoneController = TextEditingController(text: _phone);
    _passwordController = TextEditingController(text: '••••••••');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  // Mengambil nama lengkap dari SharedPreferences sebagai fallback awal
  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullname =
          prefs.getString('fullname') ??
          widget.userData['fullname'] ??
          'Penjelajah';
    });
  }

  // ── GET PROFILE DARI BACKEND ──
  Future<void> _fetchProfileFromServer() async {
    final res = await ApiService.getProfile();
    if (res['success'] == true && res['user'] != null) {
      if (mounted) {
        setState(() {
          _fullname = res['user']['fullname'] ?? _fullname;
          _email = res['user']['email'] ?? _email;
          _phone = res['user']['phone'] ?? _phone;
          _username = res['user']['username'] ?? _username;
        });
        // Update data session agar tetap sinkron
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullname', _fullname);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: white,
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: charcoal,
          ),
        ),
        content: const Text(
          'Kamu perlu login kembali untuk mengakses fitur premium.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7E8D), height: 1.5),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
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

                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const LoginPage(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // POPUP: Edit Profil (UPDATE PROFILE)
  // ─────────────────────────────────────────────
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _fullname);
    final usernameCtrl = TextEditingController(text: _username);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: teal500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: teal500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: charcoal,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Perbarui informasi akun kamu di bawah ini.',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              const SizedBox(height: 24),

              // Field: Nama Lengkap
              _buildDialogField(
                controller: nameCtrl,
                label: 'Nama Lengkap',
                icon: Icons.badge_outlined,
                hint: 'Masukkan nama lengkap',
              ),
              const SizedBox(height: 14),

              // Field: Username
              _buildDialogField(
                controller: usernameCtrl,
                label: 'Username',
                icon: Icons.alternate_email_rounded,
                hint: 'Masukkan username',
              ),
              const SizedBox(height: 14),

              // Field: Email
              _buildDialogField(
                controller: emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              // Field: No. Handphone
              _buildDialogField(
                controller: phoneCtrl,
                label: 'No. Handphone',
                icon: Icons.phone_outlined,
                hint: 'Contoh: +62 812-3456-7890',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7E8D),
                        side: const BorderSide(color: Color(0xFFCDD7DE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameCtrl.text.trim();
                        final newEmail = emailCtrl.text.trim();
                        final newPhone = phoneCtrl.text.trim();

                        if (newName.isEmpty || newEmail.isEmpty) {
                          CustomSnackBar.show(
                            context,
                            "Nama dan Email tidak boleh kosong",
                            false,
                          );
                          return;
                        }

                        Navigator.pop(ctx); // Tutup form dialog

                        // Tampilkan loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(color: teal500),
                          ),
                        );

                        // Panggil API Update Profile
                        final res = await ApiService.updateProfile(
                          fullname: newName,
                          email: newEmail,
                          phone: newPhone.isNotEmpty ? newPhone : null,
                        );

                        if (!mounted) return;
                        Navigator.pop(context); // Tutup loading dialog

                        final bool isSuccess = res['success'] == true;
                        final String msg =
                            res['message'] ??
                            (isSuccess
                                ? 'Profil berhasil diperbarui'
                                : 'Gagal memperbarui profil');

                        CustomSnackBar.show(context, msg, isSuccess);

                        if (isSuccess && res['user'] != null) {
                          setState(() {
                            _fullname = res['user']['fullname'] ?? newName;
                            _email = res['user']['email'] ?? newEmail;
                            _phone = res['user']['phone'] ?? newPhone;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('fullname', _fullname);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal500,
                        foregroundColor: white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // POPUP: Ubah Password (CHANGE PASSWORD)
  // ─────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: teal500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: teal500,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: charcoal,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pastikan password baru kamu kuat dan mudah diingat.',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 24),

                // Field: Password Lama
                _buildPasswordField(
                  controller: oldPassCtrl,
                  label: 'Password Saat Ini',
                  hint: 'Masukkan password saat ini',
                  obscure: obscureOld,
                  onToggle: () =>
                      setDialogState(() => obscureOld = !obscureOld),
                ),
                const SizedBox(height: 14),

                // Field: Password Baru
                _buildPasswordField(
                  controller: newPassCtrl,
                  label: 'Password Baru',
                  hint: 'Minimal 8 karakter',
                  obscure: obscureNew,
                  onToggle: () =>
                      setDialogState(() => obscureNew = !obscureNew),
                ),
                const SizedBox(height: 14),

                // Field: Konfirmasi Password
                _buildPasswordField(
                  controller: confirmPassCtrl,
                  label: 'Konfirmasi Password Baru',
                  hint: 'Ulangi password baru',
                  obscure: obscureConfirm,
                  onToggle: () =>
                      setDialogState(() => obscureConfirm = !obscureConfirm),
                ),
                const SizedBox(height: 28),

                // Tombol aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7E8D),
                          side: const BorderSide(color: Color(0xFFCDD7DE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final oldP = oldPassCtrl.text;
                          final newP = newPassCtrl.text;
                          final confP = confirmPassCtrl.text;

                          if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
                            CustomSnackBar.show(
                              context,
                              "Semua kolom password harus diisi!",
                              false,
                            );
                            return;
                          }

                          if (newP != confP) {
                            CustomSnackBar.show(
                              context,
                              "Password baru dan konfirmasi tidak cocok!",
                              false,
                            );
                            return;
                          }

                          if (newP.length < 8) {
                            CustomSnackBar.show(
                              context,
                              "Password baru minimal 8 karakter!",
                              false,
                            );
                            return;
                          }

                          Navigator.pop(ctx); // Tutup form dialog

                          // Tampilkan loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(color: teal500),
                            ),
                          );

                          // Panggil API Change Password
                          final res = await ApiService.changePassword(
                            oldPassword: oldP,
                            newPassword: newP,
                            confirmNewPassword: confP,
                          );

                          if (!mounted) return;
                          Navigator.pop(context); // Tutup loading

                          final bool isSuccess = res['success'] == true;
                          final String msg =
                              res['message'] ??
                              (isSuccess
                                  ? 'Password berhasil diubah'
                                  : 'Gagal mengubah password');

                          CustomSnackBar.show(context, msg, isSuccess);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal500,
                          foregroundColor: white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helper: Field teks biasa untuk dialog
  // ─────────────────────────────────────────────
  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: charcoal,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: charcoal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
            prefixIcon: Icon(icon, size: 18, color: teal500),
            filled: true,
            fillColor: const Color(0xFFF7F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teal500, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Helper: Field password dengan toggle visibility
  // ─────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: charcoal,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: charcoal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: teal500,
            ),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: Colors.black38,
              ),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: teal500, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan nama yang sudah dimuat dari session / API
    final String displayFullname = _fullname.isEmpty ? 'Memuat...' : _fullname;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHero(displayFullname),
                const SizedBox(height: 24),

                _buildSectionHeader("Aktivitas"),
                _buildMenuCard(
                  Icons.receipt_long_outlined,
                  "Riwayat Tiket",
                  subtitle: "Cek tiket yang pernah dibeli",
                  onTap: () => _showBookingHistory(),
                ),

                const SizedBox(height: 8),
                _buildSectionHeader("Pengaturan Akun"),
                _buildMenuCard(
                  Icons.person_outline_rounded,
                  "Edit Profil",
                  subtitle: "Ubah nama dan informasi akun",
                  onTap: () => _showEditProfileDialog(),
                ),
                _buildMenuCard(
                  Icons.lock_outline_rounded,
                  "Ubah Password",
                  subtitle: "Perbarui kata sandi kamu",
                  onTap: () => _showChangePasswordDialog(),
                ),

                const SizedBox(height: 8),
                _buildSectionHeader("Lainnya"),
                _buildMenuCard(
                  Icons.help_outline_rounded,
                  "Bantuan & FAQ",
                  subtitle: "Pusat bantuan pengguna",
                  onTap: () => _showFaqDialog(),
                ),
                _buildMenuCard(
                  Icons.info_outline_rounded,
                  "Tentang Aplikasi",
                  subtitle: "Versi 1.0.0",
                  onTap: () => _showAboutDialog(),
                ),
                _buildMenuCard(
                  Icons.logout_rounded,
                  "Logout",
                  subtitle: "Keluar dari akun",
                  isDestructive: true,
                  onTap: () => _handleLogout(),
                ),

                // padding bawah agar konten tidak terpotong navbar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(String fullname) {
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
          child: Column(
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
                        Icons.person_outline_rounded,
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
                      Icons.edit_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                fullname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
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
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.black54,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // POPUP: Bantuan & FAQ
  // ─────────────────────────────────────────────
  void _showFaqDialog() {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Bagaimana cara memesan tiket wisata?',
        'a':
            'Pilih destinasi wisata yang kamu inginkan, lalu klik tombol "Pesan Tiket". Isi data pemesan dan lakukan pembayaran sesuai instruksi.',
      },
      {
        'q': 'Bagaimana cara melihat riwayat pembelian tiket?',
        'a':
            'Kamu bisa melihat riwayat tiket melalui menu "Riwayat Tiket" di halaman Profil ini.',
      },
      {
        'q': 'Apakah tiket yang sudah dibeli bisa dibatalkan?',
        'a':
            'Pembatalan tiket dapat dilakukan maksimal 24 jam sebelum tanggal kunjungan. Hubungi tim kami melalui layanan pelanggan untuk proses pembatalan.',
      },
      {
        'q': 'Bagaimana cara mengubah data profil saya?',
        'a':
            'Masuk ke menu "Edit Profil" pada halaman ini, perbarui informasi yang diinginkan, lalu klik "Simpan".',
      },
      {
        'q': 'Apa yang harus dilakukan jika lupa password?',
        'a':
            'Klik tombol "Lupa Password" di halaman Login, lalu ikuti instruksi yang dikirimkan ke email kamu untuk mereset password.',
      },
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: teal500.withOpacity(0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: teal500.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: teal500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bantuan & FAQ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: charcoal,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FAQ list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.52,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: faqs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Theme(
                        data: Theme.of(
                          ctx,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            14,
                            0,
                            14,
                            14,
                          ),
                          leading: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: teal500,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(
                                  color: white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            item['q']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: charcoal,
                            ),
                          ),
                          iconColor: teal500,
                          collapsedIconColor: Colors.black38,
                          children: [
                            Text(
                              item['a']!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6B7E8D),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal500,
                    foregroundColor: white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // POPUP: Tentang Aplikasi
  // ─────────────────────────────────────────────
  void _showAboutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon aplikasi
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [teal400, teal500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: teal500.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),

              // Nama & versi
              const Text(
                'Wisata App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: charcoal,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: teal500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: teal500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              const Text(
                'Aplikasi pemandu wisata lokal yang memudahkan kamu menemukan, memesan, dan menikmati berbagai destinasi wisata terbaik di sekitarmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7E8D),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Divider info
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildAboutRow(
                      Icons.code_rounded,
                      'Dikembangkan oleh',
                      'Tim Developer',
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFFE2E8F0),
                      indent: 50,
                    ),
                    _buildAboutRow(
                      Icons.update_rounded,
                      'Terakhir diperbarui',
                      'Januari 2025',
                    ),
                    Divider(
                      height: 1,
                      color: const Color(0xFFE2E8F0),
                      indent: 50,
                    ),
                    _buildAboutRow(
                      Icons.gavel_rounded,
                      'Lisensi',
                      'MIT License',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol tutup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal500,
                    foregroundColor: white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: teal500),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7E8D)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: charcoal,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingHistory() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: teal500)),
    );
    final bookings = await ApiService.getBookings();
    if (mounted) Navigator.pop(context);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Riwayat Tiket",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Belum ada riwayat tiket",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (_, i) {
                        final b = bookings[i];
                        final status = b['status'] ?? 'PENDING';
                        final total = b['total_price'] ?? 0;
                        final code = b['ticket_code'] ?? '-';
                        final date = b['createdAt'] ?? '';
                        Color statusColor;
                        switch (status) {
                          case 'PAID':
                          case 'SUCCESS':
                            statusColor = Colors.green;
                            break;
                          case 'CANCELLED':
                          case 'EXPIRED':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.orange;
                            break;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Total: Rp ${_formatRp(total)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              if (date.isNotEmpty)
                                Text(
                                  "Tanggal: ${date.substring(0, 10)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRp(dynamic amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _glassCard({required Widget child, bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMenuCard(
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(fontSize: 12))
              : null,
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: Colors.white70),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white60),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: teal500,
              activeTrackColor: teal100.withOpacity(0.4),
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}
