import 'package:flutter/material.dart';
import '../main.dart';

class RegisterAdminPage extends StatefulWidget {
  const RegisterAdminPage({super.key});

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _adminNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePassword() => setState(() => _obscurePassword = !_obscurePassword);

  void _registerAdmin() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin berhasil masuk')),
      );
    }
  }

  @override
  void dispose() {
    _adminNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _adminNameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Admin',
                      prefixIcon: Icon(Icons.admin_panel_settings, color: colors.primary),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Nama admin tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 20),
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerAdmin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Masuk Admin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text('Daftar Pengguna Terdaftar:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            registeredUsers.isEmpty
                ? const Text('Belum ada pengguna yang mendaftar')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: registeredUsers.length,
                    itemBuilder: (context, index) {
                      final user = registeredUsers[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primary.withOpacity(0.7),
                            child: Text(
                              user['username']![0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user['fullname'] ?? ''),
                          subtitle: Text('Username: ${user['username']}'),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}