import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/cart_models.dart';
import 'package:http_parser/http_parser.dart'; // Wajib ditambahkan

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3001";
  static Map<String, dynamic>? userData;

  static final http.Client _client = http.Client();

  // ─── Helper: Ambil cookie dari SharedPreferences ───
  static Future<Map<String, String>> _authHeaders({
    bool json = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString('cookie') ?? '';
    return {
      if (json) "Content-Type": "application/json",
      if (cookie.isNotEmpty) "Cookie": cookie,
    };
  }

  // ═══════════════════════════════════════════════════
  //  AUTH — Register / Login / Logout
  // ═══════════════════════════════════════════════════

  // ── REGISTER ──
  static Future<bool> register(
    String fullname,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/users"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullname": fullname,
          "phone": phone,
          "email": email,
          "password": password,
        }),
      );

      print("REGISTER: ${response.statusCode}");
      print(response.body);

      return response.statusCode == 201;
    } catch (e) {
      print("REGISTER ERROR: $e");
      return false;
    }
  }

  // ── LOGIN (menangkap cookie session) ──
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        // Tangkap cookie session dari backend
        String? rawCookie = response.headers['set-cookie'];

        if (rawCookie != null) {
          int index = rawCookie.indexOf(';');
          String sessionCookie =
              (index == -1) ? rawCookie : rawCookie.substring(0, index);

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
      print("LOGIN ERROR: $e");
    }

    return null;
  }

  // ── LOGOUT ──
  static Future<bool> logout() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.post(
        Uri.parse("$baseUrl/users/logout"),
        headers: headers,
      );

      print("LOGOUT STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cookie');
        await prefs.remove('role');
        await prefs.remove('fullname');
        await prefs.remove('email');
        userData = null;
        return true;
      }
    } catch (e) {
      print("LOGOUT ERROR: $e");
    }
    return false;
  }

  // ═══════════════════════════════════════════════════
  //  PRODUCTS
  // ═══════════════════════════════════════════════════

  // ── GET ALL PRODUCTS ──
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/product"),
      );

      print("GET PRODUCTS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final inner = data['data'];

          if (inner is Map && inner['product'] != null) {
            return List<dynamic>.from(inner['product']);
          }

          if (inner is List) {
            return List<dynamic>.from(inner);
          }
        }

        if (data is List) {
          return List<dynamic>.from(data);
        }
      }
    } catch (e) {
      print("GET PRODUCTS ERROR: $e");
    }

    return [];
  }

  // ── GET PRODUCT BY ID ──
  static Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/product/$productId"),
      );

      print("GET PRODUCT BY ID: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['product'] != null) {
            return Map<String, dynamic>.from(inner['product']);
          }
        }
      }
    } catch (e) {
      print("GET PRODUCT BY ID ERROR: $e");
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════════════════

  // ── GET ALL CATEGORIES ──
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/category"),
      );

      print("GET CATEGORIES: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['categories'] != null) {
            return List<dynamic>.from(inner['categories']);
          }
          if (inner is List) {
            return List<dynamic>.from(inner);
          }
        }
      }
    } catch (e) {
      print("GET CATEGORIES ERROR: $e");
    }
    return [];
  }

  // ── GET CATEGORY BY ID ──
  static Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/category/$id"),
      );

      print("GET CATEGORY BY ID: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['category'] != null) {
            return Map<String, dynamic>.from(inner['category']);
          }
        }
      }
    } catch (e) {
      print("GET CATEGORY BY ID ERROR: $e");
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  CART (Redis via booking routes)
  // ═══════════════════════════════════════════════════

  // ── ADD TO CART ──
  static Future<bool> addToCart(String productId, int quantity) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/add-item"),
        headers: headers,
        body: jsonEncode({
          "productId": productId,
          "quantity": quantity,
        }),
      );

      print("ADD CART STATUS: ${response.statusCode}");
      print("ADD CART BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("ADD CART ERROR: $e");
      return false;
    }
  }

// ── GET CART ──
  static Future<List<dynamic>> getCart() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/cart"),
        headers: headers,
      );
      print("GET CART: ${response.statusCode}");
      print("GET CART BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Langsung kembalikan array as List<dynamic> tanpa konversi paksa
        if (data is Map && data['cart'] != null) {
          return data['cart'] as List<dynamic>;
        }

        if (data is Map && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }

        if (data is List) {
          return data as List<dynamic>;
        }
      }
    } catch (e) {
      print("GET CART ERROR: $e");
    }

    return [];
  }

  // ── REMOVE FROM CART ──
  static Future<bool> removeFromCart(String productId) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/remove-item"),
        headers: headers,
        body: jsonEncode({
          "productId": productId,
        }),
      );

      print("REMOVE CART: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("REMOVE CART ERROR: $e");
      return false;
    }
  }

  // ── CLEAR CART ──
  static Future<bool> clearCart() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/clear-cart"),
        headers: headers,
      );

      print("CLEAR CART: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("CLEAR CART ERROR: $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════════════
  //  BOOKING
  // ═══════════════════════════════════════════════════

  // ── CREATE BOOKING (dari isi cart Redis) ──
  static Future<Map<String, dynamic>?> createBooking({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking"),
        headers: headers,
        body: jsonEncode({
          "startDate": startDate,
          "endDate": endDate,
        }),
      );

      print("CREATE BOOKING STATUS: ${response.statusCode}");
      print("CREATE BOOKING BODY: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print("CREATE BOOKING ERROR: $e");
    }

    return null;
  }

  // ── GET MY BOOKINGS (semua booking milik user yang login) ──
  static Future<List<dynamic>> getBookings() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking"),
        headers: headers,
      );

      print("GET BOOKINGS STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['bookings'] != null) {
            return List<dynamic>.from(inner['bookings']);
          }
        }
      }
    } catch (e) {
      print("GET BOOKINGS ERROR: $e");
    }
    return [];
  }

  // ── GET BOOKING BY ID ──
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/$bookingId"),
        headers: headers,
      );

      print("GET BOOKING BY ID STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['booking'] != null) {
            return Map<String, dynamic>.from(inner['booking']);
          }
        }
      }
    } catch (e) {
      print("GET BOOKING BY ID ERROR: $e");
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  PAYMENT
  // ═══════════════════════════════════════════════════

  // ── UPLOAD PAYMENT PROOF (multipart/form-data) ──
  static Future<Map<String, dynamic>?> uploadPaymentProof({
    required String bookingId,
    required String paymentMethod,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie') ?? '';

      final uri = Uri.parse("$baseUrl/payment/$bookingId");
      final request = http.MultipartRequest('POST', uri);

      // Header cookie 
      if (cookie.isNotEmpty) {
        request.headers['Cookie'] = cookie;
      }

      // Field teks 
      request.fields['payment_method'] = paymentMethod;

      // --- LOGIKA PERBAIKAN: Deteksi MIME Type ---
      final String extension = imageFile.path.split('.').last.toLowerCase();
      MediaType contentType;

      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        contentType = MediaType('image', 'webp');
      } else {
        contentType = MediaType('image', 'jpeg'); // Default untuk jpg/jpeg
      }

      // File gambar bukti bayar dengan contentType 
      request.files.add(
        await http.MultipartFile.fromPath(
          'payment_proof',
          imageFile.path,
          contentType: contentType, // Mengirimkan identitas file ke backend
        ),
      );

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);

      print("UPLOAD PAYMENT STATUS: ${response.statusCode}");
      print("UPLOAD PAYMENT BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print("UPLOAD PAYMENT ERROR: $e");
    }
    return null;
  }

  // ── GET PAYMENT PROOF ──
  static Future<Map<String, dynamic>?> getPaymentProof(
      String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/payment/$bookingId/proof"),
        headers: headers,
      );

      print("GET PAYMENT PROOF STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      print("GET PAYMENT PROOF ERROR: $e");
    }
    return null;
  }
}