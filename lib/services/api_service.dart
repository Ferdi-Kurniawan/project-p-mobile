import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> registerUser({
    required String fullname,
    required String password,
    required String email, 
    required String phone,
  }) async {
    final url = Uri.parse('http://localhost:3000/users'); 

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    // Jika status bukan 200 atau 201 (berarti error 409 atau 500)
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      // Lempar pesan dari backend (misal: "Email sudah digunakan")
      throw errorData['message'] ?? "Gagal mendaftar";
    }
  }
}