import 'package:flutter/material.dart';
import 'dart:ui'; // Diperlukan untuk efek Frosted Glass
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullname = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  // Palette Warna 2026: Muted & Premium (Konsisten dengan Login)
  static const Color tealDeep = Color(0xFF319795);
  static const Color oceanBlueDeep = Color(0xFF2C5282);
  static const Color charcoalGrey = Color(0xFF2D3748);

  void register() async {
    if (fullname.text.isEmpty ||
        phone.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService.register(
      fullname.text,
      phone.text,
      email.text,
      password.text,
    );

    setState(() => isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register gagal")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND: Menggunakan Image yang sama dengan Login agar konsisten
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
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),

          // 2. AMBIENT LIGHTS (Floating Orbs)
          Positioned(top: -50, left: -50, child: _buildAmbientOrb(tealDeep.withOpacity(0.1))),
          Positioned(bottom: -50, right: -50, child: _buildAmbientOrb(oceanBlueDeep.withOpacity(0.1))),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  children: [
                    // 3. HEADER AREA
                    _buildTopHeader(),
                    const SizedBox(height: 25),

                    // 4. REGISTER CARD (Deep Shadow & Glassmorphism)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: charcoalGrey,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Bergabunglah untuk mulai menjelajah Indonesia",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: charcoalGrey, fontSize: 13),
                              ),
                              const SizedBox(height: 30),

                              // INPUT FIELDS
                              _buildGlassInput(
                                controller: fullname,
                                label: "Full Name",
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 15),
                              _buildGlassInput(
                                controller: phone,
                                label: "Nomor HP",
                                icon: Icons.phone_android_rounded,
                              ),
                              const SizedBox(height: 15),
                              _buildGlassInput(
                                controller: email,
                                label: "Email Address",
                                icon: Icons.mail_outline_rounded,
                              ),
                              const SizedBox(height: 15),
                              _buildGlassInput(
                                controller: password,
                                label: "Password",
                                icon: Icons.lock_outline_rounded,
                                isObscure: true,
                              ),
                              const SizedBox(height: 35),

                              // BUTTON REGISTER
                              _buildRegisterButton(),

                              const SizedBox(height: 20),
                              
                              // LOGIN LINK
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(color: charcoalGrey, fontSize: 14),
                                    children: [
                                      TextSpan(text: "Sudah punya akun? "),
                                      TextSpan(
                                        text: "Login",
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

  Widget _buildTopHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: const Icon(Icons.person_add_alt_1_rounded, size: 40, color: tealDeep),
        ),
        const SizedBox(height: 12),
        const Text(
          "TRIP NUSA DESA",
          style: TextStyle(
            color: charcoalGrey,
            letterSpacing: 6,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: charcoalGrey, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
          prefixIcon: Icon(icon, color: tealDeep, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: tealDeep, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [tealDeep, oceanBlueDeep],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tealDeep.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                "REGISTER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildAmbientOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}