import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.9:3001";
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
  // POST /users
  // Body: fullname, phone, email, password
  // Returns: { success, message }
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

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 201,
        "message": data["message"] ?? data["status"],
      };
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem. Silakan coba lagi.",
      };
    }
  }

  // ── LOGIN ──
  // POST /users/login
  // Body: email, password
  // Returns: { success, message, user? }
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          final int index = rawCookie.indexOf(';');
          final String sessionCookie = (index == -1)
              ? rawCookie
              : rawCookie.substring(0, index);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cookie', sessionCookie);
        }

        userData = data["data"]["user"];
        return {
          "success": true,
          "message": data["message"] ?? "Login Berhasil",
          "user": data["data"]["user"],
        };
      } else {
        return {"success": false, "message": data["message"] ?? "Login Gagal"};
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
  // POST /users/logout
  // Returns: bool
  static Future<bool> logout() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.post(
        Uri.parse("$baseUrl/users/logout"),
        headers: headers,
      );

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
      return false;
    } catch (e) {
      return false;
    }
    return false;
  }

  // ── GET PROFILE ──
  // GET /users/profile  [AUTH]
  // Returns: { success, message, user? }
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/users/profile"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Berhasil mengambil profil",
          "user": data["data"]["users"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal mengambil profil",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── UPDATE PROFILE ──
  // PATCH /users/profile  [AUTH]
  // Body: fullname?, phone?, email?  (minimal 1 field)
  // Returns: { success, message, user? }
  static Future<Map<String, dynamic>> updateProfile({
    String? fullname,
    String? phone,
    String? email,
  }) async {
    try {
      final headers = await _authHeaders();
      final Map<String, dynamic> body = {};
      if (fullname != null) body['fullname'] = fullname;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;

      final response = await _client.patch(
        Uri.parse("$baseUrl/users/profile"),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Profile berhasil diperbarui",
          "user": data["data"]["users"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal memperbarui profil",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── CHANGE PASSWORD ──
  // PATCH /users/change-password  [AUTH]
  // Body: oldPassword, newPassword, confirmNewPassword
  // Returns: { success, message }
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.patch(
        Uri.parse("$baseUrl/users/change-password"),
        headers: headers,
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmNewPassword": confirmNewPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Password berhasil diperbarui",
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ?? data["message"] ?? "Gagal mengubah password",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── GET ALL USERS ──
  // GET /users/data-user  [AUTH]
  // Returns: List<dynamic> (list of users)
  static Future<List<dynamic>> getAllUsers() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/users/data-user"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['users'] != null) {
            return List<dynamic>.from(inner['users']);
          }
        }
      }
    } on SocketException {
      // no-op
    } catch (e) {
      // no-op
    }
    return [];
  }

  // ═══════════════════════════════════════════════════
  //  CATEGORIES
  // ═══════════════════════════════════════════════════

  // ── GET ALL CATEGORIES ──
  // GET /category
  // Returns: List<dynamic>
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await _client.get(Uri.parse("$baseUrl/category"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['categories'] != null) {
            return List<dynamic>.from(inner['categories']);
          }
        }
      }
    } on SocketException {
      // no-op
    } catch (e) {
      // no-op
    }
    return [];
  }

  // ── GET CATEGORY BY ID ──
  // GET /category/:id
  // Returns: Map<String, dynamic>? (single category)
  static Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await _client.get(Uri.parse("$baseUrl/category/$id"));

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
      // no-op
    } catch (e) {
      // no-op
    }
    return null;
  }

  // ── CREATE CATEGORY ──  [ADMIN]
  // POST /category
  // Body: name
  // Returns: { success, message, category? }
  static Future<Map<String, dynamic>> createCategory(String name) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/category"),
        headers: headers,
        body: jsonEncode({"name": name}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Kategori berhasil dibuat",
          "category": data["data"]?["category"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal membuat kategori",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── UPDATE CATEGORY ──  [ADMIN]
  // PUT /category/:id
  // Body: name
  // Returns: { success, message, category? }
  static Future<Map<String, dynamic>> updateCategory(
    String id,
    String name,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.put(
        Uri.parse("$baseUrl/category/$id"),
        headers: headers,
        body: jsonEncode({"name": name}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Kategori berhasil diperbarui",
          "category": data["data"]?["category"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal memperbarui kategori",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── DELETE CATEGORY ──  [ADMIN]
  // DELETE /category/:id
  // Returns: { success, message }
  static Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.delete(
        Uri.parse("$baseUrl/category/$id"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Kategori berhasil dihapus",
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal menghapus kategori",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ═══════════════════════════════════════════════════
  //  PRODUCTS
  // ═══════════════════════════════════════════════════

  // ── GET ALL PRODUCTS ──
  // GET /product
  // Returns: List<dynamic>
  // FIX: key API adalah 'products' (plural), bukan 'product'
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await _client.get(Uri.parse("$baseUrl/product"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['products'] != null) {
            return List<dynamic>.from(inner['products']);
          }
        }
      }
    } on SocketException {
      // no-op
    } catch (e) {
      // no-op
    }
    return [];
  }

  // ── GET PRODUCT BY ID ──
  // GET /product/:productId
  // Returns: Map<String, dynamic>?
  static Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/product/$productId"),
      );

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
      // no-op
    } catch (e) {
      // no-op
    }
    return null;
  }

  // ── CREATE PRODUCT ──  [ADMIN]
  // POST /product
  // Body: name, price, stock?, category_id (UUID)
  // Returns: { success, message, product? }
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required int price,
    required String categoryId,
    int stock = 0,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/product"),
        headers: headers,
        body: jsonEncode({
          "name": name,
          "price": price,
          "stock": stock,
          "category_id": categoryId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Produk berhasil dibuat",
          "product": data["data"]?["product"],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? data["error"] ?? "Gagal membuat produk",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── UPDATE PRODUCT ──  [ADMIN]
  // PUT /product/:productId
  // Body: name, price, stock?, category_id (UUID)
  // Returns: { success, message, product? }
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String name,
    required int price,
    required String categoryId,
    int stock = 0,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.put(
        Uri.parse("$baseUrl/product/$productId"),
        headers: headers,
        body: jsonEncode({
          "name": name,
          "price": price,
          "stock": stock,
          "category_id": categoryId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Produk berhasil diperbarui",
          "product": data["data"]?["product"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal memperbarui produk",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── DELETE PRODUCT ──  [ADMIN]
  // DELETE /product/:productId
  // Returns: { success, message }
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.delete(
        Uri.parse("$baseUrl/product/$productId"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Produk berhasil dihapus",
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal menghapus produk",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ═══════════════════════════════════════════════════
  //  CART (Redis via booking routes)
  // ═══════════════════════════════════════════════════

  // ── ADD TO CART ──
  // POST /booking/add-item  [AUTH]
  // Body: productId, quantity
  // Returns: { success, message, cart? }
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message":
              data["message"] ?? "Barang berhasil ditambahkan ke keranjang",
          "cart": data["cart"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ??
              data["message"] ??
              "Gagal menambahkan ke keranjang",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── GET CART ──
  // GET /booking/cart  [AUTH]
  // Returns: { success, cart, total_cart_price }
  // FIX: dikembalikan sebagai Map agar total_cart_price bisa diakses
  static Future<Map<String, dynamic>> getCart() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/cart"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "cart": data["cart"] ?? [],
          "total_cart_price": data["total_cart_price"] ?? 0,
        };
      } else {
        return {
          "success": false,
          "message": data["error"] ?? "Gagal mengambil keranjang",
          "cart": [],
          "total_cart_price": 0,
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
        "cart": [],
        "total_cart_price": 0,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem.",
        "cart": [],
        "total_cart_price": 0,
      };
    }
  }

  // ── REMOVE FROM CART ──
  // POST /booking/remove-item  [AUTH]
  // Body: productId
  // Returns: { success, message, cart? }
  static Future<Map<String, dynamic>> removeFromCart(String productId) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/remove-item"),
        headers: headers,
        body: jsonEncode({"productId": productId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message":
              data["message"] ?? "Barang berhasil dihapus dari keranjang",
          "cart": data["cart"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ??
              data["message"] ??
              "Gagal menghapus dari keranjang",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── CLEAR CART ──
  // POST /booking/clear-cart  [AUTH]
  // Returns: { success, message }
  static Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/clear-cart"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Keranjang berhasil dikosongkan",
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ??
              data["message"] ??
              "Gagal mengosongkan keranjang",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ═══════════════════════════════════════════════════
  //  BOOKING
  // ═══════════════════════════════════════════════════

  // ── CREATE BOOKING ──
  // POST /booking  [AUTH]
  // Body: startDate (ISO 8601), endDate (ISO 8601)
  // Catatan: Keranjang harus terisi sebelum create booking.
  //          Setelah berhasil, keranjang otomatis dikosongkan oleh server.
  // Returns: { success, message, data? }
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking berhasil dibuat",
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ?? data["message"] ?? "Gagal membuat booking",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── GET MY BOOKINGS ──
  // GET /booking  [AUTH]
  // Returns: List<dynamic> (booking milik user yang login)
  // FIX: key API adalah 'booking' (singular), bukan 'bookings'
  static Future<List<dynamic>> getBookings() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['booking'] != null) {
            return List<dynamic>.from(inner['booking']);
          }
        }
      }
    } on SocketException {
      // no-op
    } catch (e) {
      // no-op
    }
    return [];
  }

  // ── GET BOOKING BY ID ──
  // GET /booking/:bookingId  [AUTH]
  // Returns: Map<String, dynamic>? (detail booking milik user)
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/$bookingId"),
        headers: headers,
      );

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
      // no-op
    } catch (e) {
      // no-op
    }
    return null;
  }

  // ── GET HISTORY BOOKINGS ──  [ADMIN]
  // GET /booking/history
  // Returns: List<dynamic> (semua booking dari semua user)
  static Future<List<dynamic>> getHistoryBookings() async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/history"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['data'] != null) {
          final inner = data['data'];
          if (inner is Map && inner['booking'] != null) {
            return List<dynamic>.from(inner['booking']);
          }
        }
      }
    } on SocketException {
      // no-op
    } catch (e) {
      // no-op
    }
    return [];
  }

  // ── GET HISTORY BOOKING BY ID ──  [ADMIN]
  // GET /booking/history/:bookingId
  // Returns: Map<String, dynamic>? (detail booking siapapun)
  static Future<Map<String, dynamic>?> getHistoryBookingById(
    String bookingId,
  ) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/history/$bookingId"),
        headers: headers,
      );

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
      // no-op
    } catch (e) {
      // no-op
    }
    return null;
  }

  // ── DELETE BOOKING ──  [ADMIN]
  // DELETE /booking/history/:bookingId
  // Returns: { success, message }
  static Future<Map<String, dynamic>> deleteBooking(String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.delete(
        Uri.parse("$baseUrl/booking/history/$bookingId"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Booking berhasil dihapus",
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal menghapus booking",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ═══════════════════════════════════════════════════
  //  PAYMENT
  // ═══════════════════════════════════════════════════

  // ── UPLOAD PAYMENT PROOF ──
  // POST /payment/:bookingId  [AUTH]  multipart/form-data
  // Fields : payment_method (string)
  // File   : payment_proof (JPG / PNG / WEBP, maks 5MB)
  // Efek   : Status booking → PENDING_VERIFICATION, email dikirim ke user
  // Returns: { success, message, data? }
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
      final MediaType contentType;
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
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Bukti pembayaran berhasil diunggah",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ?? data["error"] ?? "Gagal mengunggah bukti",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem saat mengunggah file.",
      };
    }
  }

  // ── GET PAYMENT PROOF ──
  // GET /payment/:bookingId/proof  [AUTH – pemilik booking]
  // Returns: { success, payment_proof?, payment_proof_url? }
  static Future<Map<String, dynamic>> getPaymentProof(String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.get(
        Uri.parse("$baseUrl/payment/$bookingId/proof"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "payment_proof": data["data"]?["payment_proof"],
          "payment_proof_url": data["data"]?["payment_proof_url"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["message"] ??
              data["error"] ??
              "Gagal mengambil bukti pembayaran",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── VERIFY PAYMENT ──  [ADMIN]
  // PATCH /payment/verify/:bookingId
  // Efek  : Status booking → PAID, QR Code tiket dikirim ke email user
  // Returns: { success, message, data? }
  static Future<Map<String, dynamic>> verifyPayment(String bookingId) async {
    try {
      final headers = await _authHeaders(json: false);
      final response = await _client.patch(
        Uri.parse("$baseUrl/payment/verify/$bookingId"),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Pembayaran berhasil diverifikasi",
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ??
              data["message"] ??
              "Gagal memverifikasi pembayaran",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── CANCEL PAYMENT ──  [ADMIN]
  // PATCH /payment/cancel/:bookingId
  // Body : reason (string, wajib) — alasan penolakan
  // Efek : Status booking → CANCELLED, email penolakan dikirim ke user
  // Returns: { success, message }
  static Future<Map<String, dynamic>> cancelPayment({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await _client.patch(
        Uri.parse("$baseUrl/payment/cancel/$bookingId"),
        headers: headers,
        body: jsonEncode({"reason": reason}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Pembayaran berhasil dibatalkan",
        };
      } else {
        return {
          "success": false,
          "message":
              data["error"] ??
              data["message"] ??
              "Gagal membatalkan pembayaran",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan sistem."};
    }
  }

  // ── Check In Scan QR code ──  [ADMIN]
  // ── CHECK IN via QR Scan ──  [ADMIN]
  // PATCH /payment/check-in/:ticketCode
  //
  // FIX: ticketCode sekarang dikirim sebagai URL param (bukan body),
  //      sesuai dengan route backend: /payment/check-in/:ticketCode
  //
  // Returns: { success, message, data? }
  static Future<Map<String, dynamic>> checkIn({
    required String ticketCode,
  }) async {
    try {
      final headers = await _authHeaders(
        json: false,
      ); // tidak perlu Content-Type JSON karena no body

      final response = await _client.patch(
        Uri.parse(
          "$baseUrl/payment/check-in/$ticketCode",
        ), // FIX: ticketCode di URL
        headers: headers,
        // FIX: tidak ada body — data dikirim via path param
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": data["message"] ?? "Verifikasi berhasil dilakukan",
          "data":
              data["data"], // berisi booking_id, id, ticket_code, check_in_time
        };
      } else {
        return {
          "success": false,
          "message": data["error"] ?? data["message"] ?? "Tiket tidak valid",
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Gagal terhubung ke server. Periksa koneksi internet Anda.",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Terjadi kesalahan sistem: ${e.toString()}",
      };
    }
  }

  static Future<List<dynamic>> searchBookings(String query) async {
    try {
      final headers = await _authHeaders(json: false);

      // Memasukkan keyword ke dalam URL sebagai query string
      final url = Uri.parse("$baseUrl/booking/search?q=$query");

      final response = await _client.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data']['bookings'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    try {
      final headers = await _authHeaders(json: false);

      // Kirim teks pencarian sebagai query parameter '?q='
      final url = Uri.parse("$baseUrl/users/search?q=$query");

      final response = await _client.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data']['users'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
