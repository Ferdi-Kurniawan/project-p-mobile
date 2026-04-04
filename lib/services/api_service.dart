import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> registerUser({
    required String fullname,
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('http://192.168.56.1:3000/users');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "username": username,
        "password": password,
      }),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("Gagal register");
    }
  }
}