import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CheckoutService {
  static const String baseUrl =
      'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> items,
    required String metodePembayaran,
    String? jenisCod,
  }) async {
    final token = await ApiService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items,
        'metode_pembayaran': metodePembayaran,
        'jenis_cod': jenisCod,
      }),
    );

    return jsonDecode(response.body);
  }
}