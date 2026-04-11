import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'pages/register_admin_page.dart';
import 'pages/login_user.dart';
import 'pages/home_page.dart';

// List global untuk menyimpan data user sementara
List<Map<String, String>> registeredUsers = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Wisata',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange.shade700,
          secondary: Colors.blue.shade700,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      
      // 1. UBAH INI: Pastikan route awal adalah login
      initialRoute: '/login', 
      
      routes: {
        // 2. Gunakan LoginPage sebagai gerbang utama
        '/login': (context) => const LoginPage(), 
        '/home': (context) => const HomePage(),
        '/user': (context) => const RegisterPage(),
        '/admin': (context) => const RegisterAdminPage(),
      },
    );
  }
}