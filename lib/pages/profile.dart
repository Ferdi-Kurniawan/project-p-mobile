import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
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

  // Variabel untuk menampung nama dari session
  String _fullname = '';

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

    // Memuat data nama dari session SharedPreferences
    _loadSessionData();

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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  // Fungsi untuk mengambil nama lengkap dari SharedPreferences
  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullname =
          prefs.getString('fullname') ??
          widget.userData['fullname'] ??
          'Penjelajah';
    });
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

  @override
  Widget build(BuildContext context) {
    // Menggunakan nama yang sudah dimuat dari session
    final String displayFullname = _fullname.isEmpty ? 'Memuat...' : _fullname;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHero(displayFullname),
            const SizedBox(height: 24),

            _buildSectionHeader("Aktivitas"),
            _buildMenuCard(
              Icons.favorite_outline,
              "Wisata Favorit",
              subtitle: "Lihat daftar favorit kamu",
            ),
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
            ),
            _buildMenuCard(
              Icons.lock_outline_rounded,
              "Ubah Password",
              subtitle: "Perbarui kata sandi kamu",
            ),

            const SizedBox(height: 8),
            _buildSectionHeader("Preferensi"),
            _buildToggleCard(
              icon: Icons.notifications_outlined,
              label: "Notifikasi",
              subtitle: "Aktifkan pemberitahuan",
              value: _notifEnabled,
              onChanged: (val) => setState(() => _notifEnabled = val),
            ),
            _buildToggleCard(
              icon: Icons.dark_mode_outlined,
              label: "Mode Gelap",
              subtitle: "Ubah tema tampilan",
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),

            const SizedBox(height: 8),
            _buildSectionHeader("Lainnya"),
            _buildMenuCard(
              Icons.help_outline_rounded,
              "Bantuan & FAQ",
              subtitle: "Pusat bantuan pengguna",
            ),
            _buildMenuCard(
              Icons.info_outline_rounded,
              "Tentang Aplikasi",
              subtitle: "Versi 1.0.0",
            ),
            _buildMenuCard(
              Icons.logout_rounded,
              "Logout",
              subtitle: "Keluar dari akun",
              isDestructive: true,
              onTap: () => _handleLogout(),
            ),
          ],
        ),
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
              // Bagian Premium Traveler telah dihilangkan agar desain lebih bersih
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

  void _showBookingHistory() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
