import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/cart_models.dart';

class ApiService {
  // 🔥 IP 10.0.2.2 khusus untuk Emulator Android terhubung ke localhost laptop
  static const String baseUrl = "http://10.0.2.2:3001";
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

  // ================= LOGIN (Dilengkapi Penangkap Cookie & Debug 302) =================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      // Kita pakai Client khusus agar tidak otomatis ter-redirect jika kena 302
      final client = http.Client();
      final request = http.Request('POST', Uri.parse("$baseUrl/users/login"))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          "email": email,
          "password": password,
        });

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN HEADERS: ${response.headers}");
      
      // 🔥 BILA KENA 302, KITA LACAK DILEMPAR KE MANA:
      if (response.statusCode == 302 || response.statusCode == 301) {
        print("🚨 TERDETEKSI REDIRECT 302!");
        print("🚨 DILEMPAR KE: ${response.headers['location']}");
      }

      if (response.statusCode == 200) {
        // 🔥 TANGKAP COOKIE SESSION DARI BACKEND
        String? rawCookie = response.headers['set-cookie'];
        
        if (rawCookie != null) {
          int index = rawCookie.indexOf(';');
          String sessionCookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', sessionCookie);
          print("✅ COOKIE TERSIMPAN: $sessionCookie");
        } else {
          print("⚠️ Backend tidak mengirimkan set-cookie");
        }

        final data = jsonDecode(response.body);
        userData = data["data"]["user"];
        return data["data"]["user"];
      }
    } catch (e) {
      print("ERROR LOGIN: $e");
    }

    return null;
  }

static Future<bool> addToRedisCart(String productId, int quantity) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('cookie');

    final response = await http.post(
      Uri.parse("$baseUrl/booking/add-item"),
      headers: {
        "Content-Type": "application/json",
        if (sessionCookie != null) "Cookie": sessionCookie,
      },
      body: jsonEncode({
        "productId": productId,
        "quantity": quantity,
      }),
    );
    print("ADD TO CART STATUS: ${response.statusCode}");
    print("ADD TO CART BODY: ${response.body}");
    return response.statusCode == 200;
  } catch (e) {
    print("Error sync Redis: $e");
    return false;
  }
}

static Future<bool> removeFromRedisCart(String productId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie = prefs.getString('cookie');

    final response = await http.post(
      Uri.parse("$baseUrl/booking/remove-item"),
      headers: {
        "Content-Type": "application/json",
        if (sessionCookie != null) "Cookie": sessionCookie,
      },
      body: jsonEncode({"productId": productId}),
    );
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

  // ================= 1. BUAT DRAFT BOOKING (Dari Cart) =================
  static Future<String?> createDraftBooking(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('cookie');

      print("MENGIRIM REQUEST DRAFT DENGAN COOKIE: $sessionCookie");

      final response = await http.post(
        Uri.parse("$baseUrl/booking"),
        headers: {
          "Content-Type": "application/json",
          // 🔥 Kirim Cookie, bukan Bearer Token
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
        body: jsonEncode({
          "startDate": startDate.toIso8601String(),
          "endDate": endDate.toIso8601String(),
          // Items tidak dikirim karena backend ambil dari Redis
        }),
      );

      print("CREATE DRAFT STATUS: ${response.statusCode}");
      print("CREATE DRAFT BODY: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['id'].toString();
      }
      return null;
    } catch (e) {
      print("ERROR CREATE DRAFT: $e");
      return null;
    }
  }

  // ================= 2. UPDATE PEMBAYARAN BOOKING (Konfirmasi Bayar) =================
  static Future<bool> updatePaymentBooking(
    String bookingId,
    String paymentMethod,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('cookie');

      final response = await http.put(
        Uri.parse("$baseUrl/booking/$bookingId/payment"),
        headers: {
          "Content-Type": "application/json",
          // 🔥 Kirim Cookie, bukan Bearer Token
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
        body: jsonEncode({
          "paymentMethod": paymentMethod,
          "status": "PENDING_VERIFICATION",
        }),
      );

      print("UPDATE PAYMENT STATUS: ${response.statusCode}");
      print("UPDATE PAYMENT BODY: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR UPDATE PAYMENT: $e");
      return false;
    }
  }

static Future<List<dynamic>> getProducts() async {
  try {
    final response = await http.get(Uri.parse("$baseUrl/product")); 

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      // Berdasarkan kode Express kamu, strukturnya adalah:
      // decoded['data']['product']
      if (decoded is Map && decoded.containsKey('data')) {
        final dataWrapper = decoded['data'];
        if (dataWrapper is Map && dataWrapper.containsKey('product')) {
          return dataWrapper['product'] as List<dynamic>;
        }
      }
      
      // Fallback jika strukturnya berbeda
      if (decoded is List) return decoded;
      
      return [];
    } else {
      return [];
    }
  } catch (e) {
    print("ERROR GET PRODUCTS: $e");
    return [];
  }
}

  // ================= AMBIL DATA KERANJANG DARI REDIS =================
  static Future<List<dynamic>> fetchCartFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('cookie');

      final response = await http.get(
        Uri.parse("$baseUrl/booking/cart"), // Sesuaikan route routerBooking kamu
        headers: {
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
      );

      print("FETCH CART STATUS: ${response.statusCode}");
      print("FETCH CART BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Sesuai respons Express kamu: { "cart": [...] }
        return decoded['cart'] ?? [];
      }
      return [];
    } catch (e) {
      print("ERROR FETCH CART: $e");
      return [];
    }
  }



  // ================= KOSONGKAN KERANJANG =================
  static Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('cookie');

      final response = await http.post(
        Uri.parse("$baseUrl/booking/clear-cart"),
        headers: {
          if (sessionCookie != null) "Cookie": sessionCookie,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ERROR CLEAR CART: $e");
      return false;
    }
  }

  // ================= LOGOUT =================
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('cookie');
      await http.post(Uri.parse("$baseUrl/users/logout"), headers: { if (sessionCookie != null) "Cookie": sessionCookie });
      await prefs.remove('cookie');
      await prefs.remove('role');
      await prefs.remove('fullname');
      await prefs.remove('email');
      userData = null;
      CartModel.instance.clearLocal();
      return true;
    } catch (e) {
      print("ERROR LOGOUT: $e");
      return false;
    }
  }
}