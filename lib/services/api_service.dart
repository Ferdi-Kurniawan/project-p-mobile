import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // Wajib ditambahkan

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";
  static Map<String, dynamic>? userData;
  static final http.Client _client = http.Client();

  // ─── Helper: Ambil cookie dari SharedPreferences ───
  static Future<Map<String, String>> _authHeaders({bool json = true}) async {
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
  static Future<Map<String, dynamic>> register(
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

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 201,
        "message": data["message"] ?? data["status"],
      };
    } on SocketException {
      print("REGISTER ERROR: Tidak ada koneksi internet / Server Down");
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem. Silakan coba lagi.",
      };
    }
  }

  // ── LOGIN ──
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      print("LOGIN STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        // --- Bagian Cookie Tetap Sama ---
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          int index = rawCookie.indexOf(';');
          String sessionCookie = (index == -1)
              ? rawCookie
              : rawCookie.substring(0, index);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', sessionCookie);
          print("LOGIN SUCCESS: Cookie disimpan - $sessionCookie");
        } else {
          print("LOGIN WARNING: Tidak ada cookie di response");
        }

        // --- Simpan ke variabel static dan Return Map Lengkap ---
        userData = data["data"]["user"];
        return {
          "success": true,
          "message": data["message"] ?? data["status"] ?? "Login Berhasil",
          "user": data["data"]["user"],
        };
      } else {
        // Jika status code bukan 200 (misal 401 atau 404)
        return {
          "success": false,
          "message": data["message"] ?? data["status"] ?? "Login Gagal",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
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
    } on SocketException {
      print("LOGOUT ERROR: Tidak ada koneksi internet / Server Down");
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
      final response = await _client.get(Uri.parse("$baseUrl/product"));
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
    } on SocketException {
      print("GET PRODUCTS ERROR: Tidak ada koneksi internet / Server Down");
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
    } on SocketException {
      print(
        "GET PRODUCT BY ID ERROR: Tidak ada koneksi internet / Server Down",
      );
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
      final response = await _client.get(Uri.parse("$baseUrl/category"));
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
    } on SocketException {
      print("GET CATEGORIES ERROR: Tidak ada koneksi internet / Server Down");
    } catch (e) {
      print("GET CATEGORIES ERROR: $e");
    }
    return [];
  }

  // ── GET CATEGORY BY ID ──
  static Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await _client.get(Uri.parse("$baseUrl/category/$id"));
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
    } on SocketException {
      print(
        "GET CATEGORY BY ID ERROR: Tidak ada koneksi internet / Server Down",
      );
    } catch (e) {
      print("GET CATEGORY BY ID ERROR: $e");
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  CART (Redis via booking routes)
  // ═══════════════════════════════════════════════════

  // ── ADD TO CART ──
  static Future<Map<String, dynamic>> addToCart(
    String productId,
    int quantity,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/add-item"),
        headers: headers,
        body: jsonEncode({"productId": productId, "quantity": quantity}),
      );

      final data = jsonDecode(response.body);

      return {
        // Cek status sukses 200 atau 201
        "success": response.statusCode == 200 || response.statusCode == 201,
        // Ambil message dari key 'message' atau 'status'
        "message": data["message"] ?? data["status"] ?? data["error"],
      };
    } on SocketException {
      return {"success": false, "message": "Tidak ada koneksi internet."};
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
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
    } on SocketException {
      print("GET CART ERROR: Tidak ada koneksi internet / Server Down");
    } catch (e) {
      print("GET CART ERROR: $e");
    }
    return [];
  }

  // ── REMOVE FROM CART ──
  static Future<Map<String, dynamic>> removeFromCart(String productId) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/remove-item"),
        headers: headers,
        body: jsonEncode({"productId": productId}),
      );
      print("REMOVE CART: ${response.statusCode}");

      return {
        "success": response.statusCode == 200,
        "message": response.statusCode == 200
            ? "Item removed from cart successfully."
            : "Failed to remove item from cart.",
      };
    } on SocketException {
      print("REMOVE CART ERROR: Tidak ada koneksi internet / Server Down");
      return {"success": false, "message": "Tidak ada koneksi internet."}
          as Map<String, dynamic>;
    } catch (e) {
      print("REMOVE CART ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"}
          as Map<String, dynamic>;
    }
  }

  // ── CLEAR CART ──
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/clear-cart"),
        headers: headers,
      );
      print("CLEAR CART: ${response.statusCode}");

      return {
            "success": response.statusCode == 200,
            "message": response.statusCode == 200
                ? "Cart cleared successfully."
                : "Failed to clear cart.",
          }
          as Map<String, dynamic>;
    } on SocketException {
      print("CLEAR CART ERROR: Tidak ada koneksi internet / Server Down");
      return {"success": false, "message": "Tidak ada koneksi internet."}
          as Map<String, dynamic>;
    } catch (e) {
      print("CLEAR CART ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan: $e"}
          as Map<String, dynamic>;
    }
  }

  // ═══════════════════════════════════════════════════
  //  BOOKING
  // ══════════════════════════════════════════════════

  // ── CREATE BOOKING ──
  static Future<Map<String, dynamic>> createBooking({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking"),
        headers: headers,
        body: jsonEncode({"startDate": startDate, "endDate": endDate}),
      );
      print("CREATE BOOKING STATUS: ${response.statusCode}");
      print("CREATE BOOKING BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message":
              data["message"] ?? data["status"] ?? "Booking berhasil dibuat",
          "data": data['data'],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal membuat booking",
        };
      }
    } on SocketException {
      print("CREATE BOOKING ERROR: Tidak ada koneksi internet / Server Down");
      return {
        "success": false,
        "message": "Tidak ada koneksi internet. Silakan periksa jaringan Anda.",
      };
    } catch (e) {
      print("CREATE BOOKING ERROR: $e");
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── GET MY BOOKINGS ──
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
    } on SocketException {
      print("GET BOOKINGS ERROR: Tidak ada koneksi internet / Server Down");
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
    } on SocketException {
      print(
        "GET BOOKING BY ID ERROR: Tidak ada koneksi internet / Server Down",
      );
    } catch (e) {
      print("GET BOOKING BY ID ERROR: $e");
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  PAYMENT
  // ═══════════════════════════════════════════════════

  // ── UPLOAD PAYMENT PROOF ──
  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String bookingId,
    required String paymentMethod,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('cookie') ?? '';

      final uri = Uri.parse("$baseUrl/payment/$bookingId");
      final request = http.MultipartRequest('POST', uri);

      if (cookie.isNotEmpty) {
        request.headers['Cookie'] = cookie;
      }

      request.fields['payment_method'] = paymentMethod;

      final String extension = imageFile.path.split('.').last.toLowerCase();
      MediaType contentType;
      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        contentType = MediaType('image', 'webp');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'payment_proof',
          imageFile.path,
          contentType: contentType,
        ),
      );

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);

      print("UPLOAD PAYMENT STATUS: ${response.statusCode}");
      print("UPLOAD PAYMENT BODY: ${response.body}");

      // Decode JSON respons dari backend
      final data = jsonDecode(response.body);

      // Tangkap respons sukses (200 atau 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message":
              data["message"] ?? data["status"] ?? "Bukti berhasil diunggah",
          "data": data,
        };
      } else {
        // Tangkap respons gagal (termasuk status 400 - File kebesaran)
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal mengunggah bukti",
        };
      }
    } on SocketException {
      print("UPLOAD PAYMENT ERROR: Tidak ada koneksi internet / Server Down");
      return {
        "success": false,
        "message": "Tidak ada koneksi internet. Silakan periksa jaringan Anda.",
      };
    } catch (e) {
      print("UPLOAD PAYMENT ERROR: $e");
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem saat mengunggah file.",
      };
    }
  }

  // ── GET PAYMENT PROOF ──
  static Future<Map<String, dynamic>?> getPaymentProof(String bookingId) async {
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
    } on SocketException {
      print(
        "GET PAYMENT PROOF ERROR: Tidak ada koneksi internet / Server Down",
      );
    } catch (e) {
      print("GET PAYMENT PROOF ERROR: $e");
    }
    return null;
  }
}
