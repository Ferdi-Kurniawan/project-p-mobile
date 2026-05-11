import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/cart_models.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:3000";

  static Map<String, dynamic>? userData;

  static final http.Client _client = http.Client();

  // ================= REGISTER =================
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

  // ================= LOGIN =================
  static Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/users/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("LOGIN: ${response.statusCode}");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        userData = data["data"]["user"];

        return data["data"]["user"];
      }
    } catch (e) {
      print("LOGIN ERROR: $e");
    }

    return null;
  }

  // ================= GET PRODUCTS =================
  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/products"),
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

  // ================= ADD TO CART =================
  static Future<bool> addToCart(
    String productId,
    int quantity,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/add-item"),
        headers: {"Content-Type": "application/json"},
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

  // ================= GET CART =================
  static Future<List<Map<String, dynamic>>> getCart() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/booking/cart"),
      );

      print("GET CART: ${response.statusCode}");
      print("GET CART BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['cart'] != null) {
          return List<Map<String, dynamic>>.from(data['cart']);
        }

        if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      print("GET CART ERROR: $e");
    }

    return [];
  }

  // ================= REMOVE FROM CART =================
  static Future<bool> removeFromCart(String productId) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/remove-item"),
        headers: {"Content-Type": "application/json"},
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

  // ================= CLEAR CART =================
  static Future<bool> clearCart() async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/booking/clear-cart"),
      );

      print("CLEAR CART: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("CLEAR CART ERROR: $e");
      return false;
    }
  }

  // ================= CREATE BOOKING =================
  static Future<Map<String, dynamic>?> createBooking({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse("$baseUrl/booking"),
        headers: {"Content-Type": "application/json"},
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

  // ================= GET BOOKINGS =================
  static Future<List<dynamic>> getBookings() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/booking"),
      );

      print("GET BOOKINGS: ${response.statusCode}");

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

  // ================= CHECKOUT =================
  static Future<bool> checkout(CartModel cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse("$baseUrl/booking"),
        headers: {
          "Content-Type": "application/json",
          if (token != null)
            "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "startDate": DateTime.now().toIso8601String(),
          "endDate": DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
          "userId": userData?['id'],
          "items": cart.items.map((item) {
            return {
              "name": item.name,
              "price": item.hargaInt,
              "quantity": item.quantity,
              "total": item.subtotal,
              "productId": item.productId,
            };
          }).toList(),
        }),
      );

      print("CHECKOUT STATUS: ${response.statusCode}");
      print("CHECKOUT BODY: ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("CHECKOUT ERROR: $e");
      return false;
    }
  }
}