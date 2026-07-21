import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _baseUrl = '${AppConfig.webBaseUrl}/api';

  // ── Token Storage ──────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString('user');

    if (userString == null) return null;

    return jsonDecode(userString);
  }

  static Future<void> incrementMenuVisit(String label) async {
    final user = await getUser();
    final userId = user?['id']?.toString() ?? 'guest';
    final prefs = await SharedPreferences.getInstance();
    final key = 'menu_visits_${userId}_$label';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/user'), headers: await _headers(auth: true))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await removeToken();
        return {'unauthorized': true};
      }
    } catch (e) {
      // Kesalahan jaringan
    }
    return null;
  }

  // ── Headers ────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ── LOGIN ──────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ── REGISTER ───────────────────────────────
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Register gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }

  // ── LOGOUT ─────────────────────────────────
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: await _headers(auth: true),
      );
    } catch (e) {
      // sengaja dikosongkan
    } finally {
      // token tetap dihapus walaupun request gagal
      await removeToken();
    }
  }

  static Future<Map<String, dynamic>> checkout({
    required String metodePembayaran,
    String? jenisCod,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/checkout'),
        headers: await _headers(auth: true),
        body: jsonEncode({
          'metode_pembayaran': metodePembayaran,
          'jenis_cod': jenisCod,
          'items': items,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyEmail(String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/verify'),
        headers: await _headers(auth: true),
        body: jsonEncode({'otp': otp}),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  static Future<Map<String, dynamic>> resendVerificationOtp() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/email/resend'),
        headers: await _headers(auth: true),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/password/forgot'),
        headers: await _headers(),
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/password/reset'),
        headers: await _headers(),
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/google'),
        headers: await _headers(),
        body: jsonEncode({'id_token': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login Google gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server'};
    }
  }
}
