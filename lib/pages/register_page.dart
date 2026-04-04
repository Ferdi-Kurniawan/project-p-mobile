import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePassword() => setState(() => _obscurePassword = !_obscurePassword);

void _submit() async {
  if (_formKey.currentState!.validate()) {
    try {
      await ApiService.registerUser(
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil ke server!')),
      );

      _usernameController.clear();
      _fullnameController.clear();
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary.withOpacity(0.1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: FadeTransition(
            opacity: _opacityAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Daftar Akun Pengguna',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Buat akun untuk mulai pesan tiket wisata favoritmu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.account_circle, color: colors.primary),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Username tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),

                      // Fullname
                      TextFormField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person, color: colors.primary),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: colors.primary),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: colors.primary,
                            ),
                            onPressed: _togglePassword,
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: colors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: colors.primary.withOpacity(0.5),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin');
                        },
                        child: Text(
                          'Masuk ke Admin',
                          style: TextStyle(
                            color: colors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}