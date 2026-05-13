import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

// Sesuaikan path import ini dengan struktur folder proyekmu
// Contoh: jika login_page.dart ada di lib/pages/ maka:
import '../pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _notifEnabled = true;
  bool _editingEmail = false;
  bool _editingPhone = false;
  bool _editingPassword = false;

  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ─── Palette: selaras dengan halaman Tiket & LoginPage ────────────────────
  static const Color teal500  = Color(0xFF319795); // sama dengan tealDeep di LoginPage
  static const Color teal400  = Color(0xFF4DB6AC);
  static const Color teal100  = Color(0xFFB2DFDB);
  static const Color charcoal = Color(0xFF2D3748); // sama dengan charcoalGrey di LoginPage
  static const Color white    = Color(0xFFFFFFFF);

  // ─── Foto wisata Indonesia dari Unsplash ──────────────────────────────────
  // Raja Ampat, Papua Barat
  static const String _bgImageUrl =
      'https://images.unsplash.com/photo-1516690561799-46d8f74f9abf'
      '?q=85&w=1600&auto=format&fit=crop';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? 'penjelajah@email.com',
    );
    _phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '+62 812-3456-7890',
    );
    _passwordController = TextEditingController(text: '••••••••');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Logout: hapus SharedPreferences → navigasi ke LoginPage asli ─────────
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
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7E8D),
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              // Tombol Batal
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
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tombol Keluar
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx); // tutup dialog

                    // Hapus semua data sesi dari SharedPreferences
                
                    // Tambahkan key lain yang perlu dihapus sesuai kebutuhan

                    if (!mounted) return;

                    // Navigasi ke LoginPage asli, hapus seluruh stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const LoginPage(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                      (route) => false, // hapus semua route sebelumnya
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

  @override
  Widget build(BuildContext context) {
    final String fullname = widget.userData['fullname'] ?? 'Penjelajah';

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Background foto wisata Unsplash ────────────────────────────
          Positioned.fill(
            child: Image.network(
              _bgImageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF0D2137),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: teal400,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0D2137)),
            ),
          ),

          // ── 2. Gradient overlay ───────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.72),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Konten utama ───────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildProfileHero(fullname),
                          const SizedBox(height: 28),

                          _buildSectionHeader('Keamanan Akun'),
                          const SizedBox(height: 10),
                          _buildEditableField(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email',
                            controller: _emailController,
                            isEditing: _editingEmail,
                            onEditTap: () => setState(() {
                              _editingEmail = !_editingEmail;
                              _editingPhone = false;
                              _editingPassword = false;
                            }),
                          ),
                          const SizedBox(height: 10),
                          _buildEditableField(
                            icon: Icons.phone_iphone_rounded,
                            label: 'Nomor Telepon',
                            controller: _phoneController,
                            isEditing: _editingPhone,
                            onEditTap: () => setState(() {
                              _editingPhone = !_editingPhone;
                              _editingEmail = false;
                              _editingPassword = false;
                            }),
                          ),
                          const SizedBox(height: 10),
                          _buildEditableField(
                            icon: Icons.lock_outline_rounded,
                            label: 'Kata Sandi',
                            controller: _passwordController,
                            isEditing: _editingPassword,
                            isObscured: !_editingPassword,
                            onEditTap: () => setState(() {
                              _editingPassword = !_editingPassword;
                              if (_editingPassword) {
                                _passwordController.clear();
                              } else {
                                _passwordController.text = '••••••••';
                              }
                              _editingEmail = false;
                              _editingPhone = false;
                            }),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionHeader('Preferensi'),
                          const SizedBox(height: 10),
                          _buildToggleCard(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifikasi Push',
                            subtitle: 'Promo & info tiket terbaru',
                            value: _notifEnabled,
                            onChanged: (v) => setState(() => _notifEnabled = v),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionHeader('Aktivitas'),
                          const SizedBox(height: 10),
                          _buildNavCard(
                            icon: Icons.receipt_long_outlined,
                            label: 'Riwayat Tiket',
                            subtitle: 'Lihat tiket yang pernah dipesan',
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildNavCard(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Metode Pembayaran',
                            subtitle: 'Kelola dompet & kartu',
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _buildNavCard(
                            icon: Icons.help_outline_rounded,
                            label: 'Pusat Bantuan',
                            subtitle: 'Layanan pelanggan 24/7',
                            onTap: () {},
                          ),
                          const SizedBox(height: 32),

                          _buildSaveButton(),
                          const SizedBox(height: 12),
                          _buildLogoutButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Profil Saya',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
                shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
              ),
            ),
          ),
          const SizedBox(width: 38),
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
                color: Colors.white.withOpacity(0.25), width: 1.2),
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
                      child: Icon(Icons.person_outline_rounded,
                          size: 42, color: Colors.white),
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
                    child: const Icon(Icons.edit_rounded,
                        size: 12, color: Colors.white),
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
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: teal500.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border:
                      Border.all(color: teal400.withOpacity(0.5), width: 1),
                ),
                child: const Text(
                  'PREMIUM TRAVELER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
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
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white70,
          letterSpacing: 1.6,
          shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    bool isActive = false,
    double radius = 16,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.22)
                : Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isActive
                  ? teal400.withOpacity(0.6)
                  : Colors.white.withOpacity(0.22),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditTap,
    bool isObscured = false,
  }) {
    return _glassCard(
      isActive: isEditing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isEditing
                    ? teal500.withOpacity(0.35)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 17,
                  color: isEditing ? teal100 : Colors.white70),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isEditing ? teal100 : Colors.white60,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  isEditing
                      ? TextField(
                          controller: controller,
                          obscureText: isObscured,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          cursorColor: teal400,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          autofocus: true,
                        )
                      : Text(
                          isObscured ? '••••••••' : controller.text,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: isEditing
                      ? teal500
                      : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEditing
                        ? teal500
                        : Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  isEditing ? 'Simpan' : 'Edit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white60)),
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

  Widget _buildNavCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _glassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white38, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _editingEmail = false;
            _editingPhone = false;
            _editingPassword = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perubahan berhasil disimpan'),
              backgroundColor: teal500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: teal500,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          'SIMPAN PERUBAHAN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: OutlinedButton(
            onPressed: _handleLogout, // ← dialog → hapus prefs → LoginPage
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.12),
              side: BorderSide(
                  color: Colors.white.withOpacity(0.35), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'KELUAR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}