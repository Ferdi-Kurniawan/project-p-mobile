import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});

  final Map<String, dynamic> userData;
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifEnabled = true;
  bool _darkMode = false;
  String _selectedLang = 'Indonesia';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          "Profile Pengguna",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          backgroundColor: Colors.deepOrange.shade800,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
          
          ],
        ),

        backgroundColor: Colors.deepOrange.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildUserProfile(),
    );
  }

  Widget _buildUserProfile() {

    final String fullname = widget.userData['fullname'];
    final String email = widget.userData['email'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(fullname, email),
          const SizedBox(height: 24),

          _buildSectionLabel("Aktivitas"),
          _buildMenuCard(
            Icons.favorite_outline,
            "Wisata Favorit",
            subtitle: "Lihat daftar favorit kamu",
          ),
          _buildMenuCard(
            Icons.receipt_long_outlined,
            "Riwayat Tiket",
            subtitle: "Cek tiket yang pernah dibeli",
          ),

          const SizedBox(height: 8),
          _buildSectionLabel("Pengaturan Akun"),
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
          _buildSectionLabel("Preferensi"),
          _buildToggleCard(
            Icons.notifications_outlined,
            "Notifikasi",
            subtitle: "Aktifkan pemberitahuan",
            value: _notifEnabled,
            onChanged: (val) => setState(() => _notifEnabled = val),
          ),
          _buildToggleCard(
            Icons.dark_mode_outlined,
            "Mode Gelap",
            subtitle: "Ubah tema tampilan",
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          _buildLanguageCard(),

          const SizedBox(height: 8),
          _buildSectionLabel("Lainnya"),
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
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ================= COMPONENT =================

  Widget _buildHeader(String name, String email) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Gradient header background
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepOrange.shade800, Colors.orange.shade400],
            ),
          ),
        ),

        // Avatar di tengah
        Positioned(
          top: 60,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: Colors.deepOrange.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // Badge role
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.deepOrange.withOpacity(0.25),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Spacer untuk tinggi total header + avatar
        const SizedBox(height: 310),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    IconData icon,
    String title, {
    String? subtitle,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade400 : Colors.deepOrange;
    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.08)
                : Colors.deepOrange.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDestructive
                ? Colors.red.shade400
                : const Color(0xFF1A1A1A),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildToggleCard(
    IconData icon,
    String title, {
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.deepOrange, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepOrange,
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.language_rounded,
            color: Colors.deepOrange,
            size: 20,
          ),
        ),
        title: const Text(
          "Bahasa",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          "Pilih bahasa aplikasi",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLang,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade400,
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade700,
            ),
            items: ['Indonesia', 'English'].map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLang = val);
            },
          ),
        ),
      ),
    );
  }
}
