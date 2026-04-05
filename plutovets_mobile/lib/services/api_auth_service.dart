import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAuthService {
  final String baseUrl;
  ApiAuthService({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      final body = jsonDecode(response.body);
      
      return {
        'statusCode': response.statusCode,
        'body': body,
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'error': 'Network error: ${e.toString()}'},
      };
    }
  }
}
