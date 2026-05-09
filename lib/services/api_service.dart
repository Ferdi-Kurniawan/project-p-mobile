import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/cart_models.dart';
class ApiService {
  static const String baseUrl = "http://127.0.0.1:3000";
  static Map<String, dynamic>? userData;

  // ================= REGISTER =================
  static Future<bool> register(
    String fullname,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullname": fullname,
          "phone": phone,
          "email": email,
          "password": password,
        }),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("ERROR REGISTER: $e");
      return false;
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/login"), // 🔥 INI YANG PENTING
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = data["data"]["user"];
        return data["data"]["user"];
      }
    } catch (e) {
      print("ERROR LOGIN: $e");
    }

    return null;
  }


   static Future<bool> checkout(CartModel cart) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    // Catatan: Backend saat ini menggunakan Session (Cookie), 
    // jika Anda ingin menggunakan Token/Bearer, pastikan backend sudah mendukungnya.
    
    final response = await http.post(
      Uri.parse("$baseUrl/booking"), // Menyesuaikan dengan route backend '/booking'
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "startDate": DateTime.now().toIso8601String(), // Backend booking butuh startDate/endDate
        "endDate": DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        "userId": userData?['id'],
        "items": cart.items.map((item) {
          return {
            "name": item.name,
            "price": item.hargaInt,
            "quantity": item.quantity,
            "total": item.subtotal,
            "productId": item.productId 
          };
        }).toList()
      }),
    );

    print("CHECKOUT STATUS: ${response.statusCode}");
    print("CHECKOUT BODY: ${response.body}");
    return response.statusCode == 201;
  }
}