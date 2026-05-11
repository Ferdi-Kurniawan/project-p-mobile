import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk efek Frosted Glass & Blur

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userData});

  final Map<String, dynamic> userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notifEnabled = true;

  // Palette Warna 2026: Sunlit, Airy, & Natural
  static const Color mintPastel = Color(0xFFE6FFFA);
  static const Color skyBluePastel = Color(0xFFEBF8FF);
  static const Color tealGlow = Color(0xFF4FD1C5);
  static const Color charcoalGrey = Color(0xFF2D3748);
  static const Color oceanBlueGradient = Color(0xFF3182CE);
  static const Color mintGradient = Color(0xFF81E6D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFF), // Soft Ivory Background
      body: Stack(
        children: [
          // 1. BACKGROUND TERBARU: Pemandangan Alam Tropis (High Stability Link)
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.network(
                'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=2070', // Landscape Danau/Tropis yang tenang
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.white); // Fallback jika internet lambat
                },
              ),
            ),
          ),

          // 2. DECORATIVE 3D ASSETS: Ambient Glow
          Positioned(top: 80, left: -40, child: _buildAmbientOrb(mintPastel, 300)),
          Positioned(bottom: 100, right: -40, child: _buildAmbientOrb(skyBluePastel, 300)),
          
          // 3. MAIN INTERFACE
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // PROFILE HEADER: Glass Frame & 3D Avatar
                        _buildProfileHeader(),
                        
                        const SizedBox(height: 50),

                        // MENU SECTION: Floating Glassmorphic Cards
                        _buildSectionLabel("AKTIVITAS"),
                        _buildGlassMenuCard(
                          Icons.receipt_long_outlined, 
                          "Riwayat Tiket", 
                          "Cek tiket yang telah dipesan"
                        ),
                        _buildGlassMenuCard(
                          Icons.account_balance_wallet_outlined, 
                          "Metode Pembayaran", 
                          "Kelola dompet digital & kartu"
                        ),
                        
                        const SizedBox(height: 30),
                        
                        _buildSectionLabel("PENGATURAN & BANTUAN"),
                        _buildGlassToggleCard(
                          Icons.notifications_none_rounded, 
                          "Notifikasi", 
                          _notifEnabled, 
                          (v) => setState(() => _notifEnabled = v)
                        ),
                        _buildGlassMenuCard(
                          Icons.help_outline_rounded, 
                          "Pusat Bantuan", 
                          "Layanan pelanggan 24/7"
                        ),
                        
                        const SizedBox(height: 40),

                        // BOTTOM ACTION: Refreshing Gradient Button
                        _buildActionButton("KELUAR"),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String fullname = widget.userData['fullname'] ?? "Penjelajah";
    
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: tealGlow.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  size: 60,
                  color: tealGlow,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          fullname,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: charcoalGrey,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: tealGlow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "PREMIUM TRAVELER",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: charcoalGrey.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMenuCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _glassBoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Icon(icon, color: tealGlow, size: 24),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, color: charcoalGrey, fontSize: 15),
            ),
            subtitle: Text(
              subtitle, 
              style: TextStyle(color: charcoalGrey.withOpacity(0.5), fontSize: 12)
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black12),
            onTap: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildGlassToggleCard(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _glassBoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            secondary: Icon(icon, color: tealGlow, size: 24),
            title: Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.w700, color: charcoalGrey, fontSize: 15)
            ),
            value: value,
            activeColor: tealGlow,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [mintGradient, oceanBlueGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: oceanBlueGradient.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.6), Colors.transparent],
        ),
      ),
    );
  }

  BoxDecoration _glassBoxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 30,
          offset: const Offset(0, 15),
        )
      ],
    );
  }
}