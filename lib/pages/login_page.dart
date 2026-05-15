import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk efek Frosted Glass / BackdropFilter
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../helper/snackbar_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Palette Warna 2026: Sunlit, Modern & Airy
  static const Color tealDeep = Color(0xFF319795);
  static const Color oceanBlueDeep = Color(0xFF2C5282);
  static const Color charcoalGrey = Color(0xFFFFFFFF);

  void login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      CustomSnackBar.show(context, "Email & Password wajib diisi", false);
      return;
    }

    setState(() => isLoading = true);

    // Ambil hasil Map dari ApiService
    final result = await ApiService.login(email.text, password.text);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      final user = result['user'];

      // Simpan data ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', user['role']);
      await prefs.setString('fullname', user['fullname']);
      await prefs.setString('email', user['email']);

      // Tampilkan pesan sukses dari backend
      CustomSnackBar.show(context, result['message'], true);

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      });
    } else {
      // Tampilkan pesan error murni dari backend (misal: "Password salah")
      CustomSnackBar.show(context, result['message'], false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND: Tropical Landscape dengan filter terang
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=2070',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.60),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. AMBIENT GLOWS
          Positioned(
            top: 100,
            right: -50,
            child: _buildAmbientOrb(tealDeep.withOpacity(0.12)),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: _buildAmbientOrb(oceanBlueDeep.withOpacity(0.12)),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildTopLogo(),
                    const SizedBox(height: 25),

                    // 3. MAIN FORM CARD: Glassmorphism Effect
                    ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Selamat Datang",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: charcoalGrey,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Masuk untuk eksplorasi nusantara",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 35),

                              // INPUT EMAIL
                              _buildGlassInput(
                                controller: email,
                                label: "Alamat Email",
                                icon: Icons.mail_outline_rounded,
                                hintText: "nama@email.com",
                              ),
                              const SizedBox(height: 20),

                              // INPUT PASSWORD
                              _buildGlassInput(
                                controller: password,
                                label: "Password",
                                icon: Icons.lock_outline_rounded,
                                isObscure: !isPasswordVisible,
                                hintText: "Masukkan kata sandi",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: tealDeep.withOpacity(0.6),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () =>
                                        isPasswordVisible = !isPasswordVisible,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 35),

                              // SUBMIT BUTTON
                              _buildSubmitButton(),

                              const SizedBox(height: 25),

                              // LINK KE REGISTER
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/register'),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: charcoalGrey,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(text: "Belum punya akun? "),
                                      TextSpan(
                                        text: "Daftar Sekarang",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: tealDeep,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET INPUT DENGAN PERBAIKAN TATA LETAK PLACEHOLDER
  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        textAlignVertical: TextAlignVertical
            .center, // Teks input tepat di tengah secara vertikal
        style: const TextStyle(
          color: charcoalGrey,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          // Pengaturan Label & Placeholder
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
          floatingLabelStyle: const TextStyle(
            color: tealDeep,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),

          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 13,
          ),

          // Ikon Prefix (Ikon di kiri)
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: tealDeep, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),

          // Ikon Suffix (Ikon di kanan, misal: mata password)
          suffixIcon: suffixIcon,

          // Menghilangkan Border Default agar menggunakan style Container
          border: InputBorder.none,

          // Padding konten untuk merapihkan teks placeholder & input
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTopLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 42,
            color: tealDeep,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "TRIP NUSA DESA",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 6,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [tealDeep, oceanBlueDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tealDeep.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "MASUK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildAmbientOrb(Color color) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
