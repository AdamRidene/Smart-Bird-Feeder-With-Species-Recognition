import 'dart:convert';
import 'package:http/http.dart' as http;

class EspApi {
  static const String baseUrl = "http://192.168.1.50";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/login.php");

      final response = await http.post(url, body: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "Server error"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/signup.php");

      final response = await http.post(url, body: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"status": "error", "message": "Server error"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
