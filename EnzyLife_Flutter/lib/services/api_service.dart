import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/artikel.dart';
import '../models/infografik.dart';
import '../models/user.dart';
import '../models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Android Emulator
  static const String _baseUrl =
      'https://undergo-refill-bonehead.ngrok-free.dev/api';

  // Cache
  static List<Product> cachedProducts = [];
  static List<ArtikelModel> cachedArtikel = [];
  static List<InfografikModel> cachedInfografik = [];
  static UserModel? cachedUser;

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // =====================================================
  // PRODUCTS
  // =====================================================

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final products = List<Product>.from(
          data['data'].map((x) => Product.fromJson(x)),
        );

        cachedProducts = products;

        return products;
      }

      return [];
    } catch (e) {
      print('Error getProducts: $e');

      return [];
    }
  }

  static Future<Map<String, dynamic>> getProductsPaginated({
    int page = 1,
    int perPage = 6,
    String? sortBy,
    String? sortOrder,
    String? search,
    int? rating,
  }) async {
    try {
      String url = '$_baseUrl/products?page=$page&per_page=$perPage';
      if (sortBy != null) url += '&sort_by=$sortBy';
      if (sortOrder != null) url += '&sort_order=$sortOrder';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (rating != null) {
        url += '&rating=$rating';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawData = decoded['data'];
        List<Product> products = [];
        int lastPage = 1;

        if (rawData is Map && rawData.containsKey('data')) {
          products = List<Product>.from(
            rawData['data'].map((x) => Product.fromJson(x)),
          );
          lastPage = rawData['last_page'] ?? 1;
        } else if (rawData is List) {
          products = List<Product>.from(
            rawData.map((x) => Product.fromJson(x)),
          );
        }

        // Cache first page
        if (page == 1 && (search == null || search.isEmpty)) {
          cachedProducts = products;
        }

        return {'products': products, 'last_page': lastPage};
      }
      return {'products': <Product>[], 'last_page': 1};
    } catch (e) {
      print('Error getProductsPaginated: $e');
      return {'products': <Product>[], 'last_page': 1};
    }
  }

  // =====================================================
  // ARTIKEL
  // =====================================================

  static Future<List<ArtikelModel>> getArtikel() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/artikel'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final artikel = List<ArtikelModel>.from(
          data['data'].map((x) => ArtikelModel.fromJson(x)),
        );

        cachedArtikel = artikel;

        return artikel;
      }

      return [];
    } catch (e) {
      print('Error getArtikel: $e');

      return [];
    }
  }

  // =====================================================
  // DETAIL ARTIKEL
  // =====================================================

  static Future<ArtikelModel?> getDetailArtikel(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/artikel/$id'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return ArtikelModel.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      print('Error getDetailArtikel: $e');

      return null;
    }
  }

  // =====================================================
  // INFOGRAFIK
  // =====================================================

  static Future<List<InfografikModel>> getInfografik() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/infografik'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final infografik = data
            .map((e) => InfografikModel.fromJson(e))
            .toList();

        cachedInfografik = infografik;

        return infografik;
      }

      return [];
    } catch (e) {
      print('Error getInfografik: $e');

      return [];
    }
  }

  // =====================================================
  // PROFILE
  // =====================================================

  static Future<UserModel?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = UserModel.fromJson(data['user']);

        cachedUser = user;

        return user;
      }

      return null;
    } catch (e) {
      print('Error getProfile: $e');

      return null;
    }
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  static Future<bool> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? postalCode,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: await _authHeaders(),
        body: {
          'name': name,
          'phone': phone ?? '',
          'address': address ?? '',
          'postal_code': postalCode ?? '',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updateProfile: $e');

      return false;
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/password'),
        headers: await _authHeaders(),
        body: {
          'current_password': oldPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah password',
        };
      }
    } catch (e) {
      print('Error updatePassword: $e');
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  // =====================================================
  // CHECKOUT / PEMESANAN
  // =====================================================

  static Future<Map<String, dynamic>?> checkout({
    required List<Map<String, dynamic>> items,
    required String metodePembayaran,
    String? jenisCod,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/checkout'),
        headers: headers,
        body: jsonEncode({
          'items': items,
          'metode_pembayaran': metodePembayaran,
          'jenis_cod': jenisCod,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      print(
        'Checkout error status: ${response.statusCode}, body: ${response.body}',
      );
      return null;
    } catch (e) {
      print('Error checkout: $e');
      return null;
    }
  }

  // =====================================================
  // ORDER HISTORY
  // =====================================================

  static Future<List<OrderModel>> getOrderHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List ordersJson = data['data'] ?? [];
          return ordersJson.map((e) => OrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getOrderHistory: $e');
      return [];
    }
  }

  // =====================================================
  // CONFIRM ORDER PAYMENT
  // =====================================================

  static Future<Map<String, dynamic>?> payOrder(
    int orderId, {
    bool simulate = false,
  }) async {
    try {
      final headers = await _authHeaders();
      final body = simulate ? {'simulate': 'true'} : <String, String>{};
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/pay'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error payOrder: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> cancelOrder(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/cancel'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error cancelOrder: $e');
      return null;
    }
  }

  // =====================================================
  // SUBMIT REVIEW / ULASAN
  // =====================================================
  static Future<Map<String, dynamic>?> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String komentarAroma,
    String? komentarPengiriman,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review'),
        headers: await _authHeaders(),
        body: {
          'pemesanan_id': orderId.toString(),
          'produk_id': productId.toString(),
          'rating': rating.toString(),
          'komentar_aroma': komentarAroma,
          'komentar_pengiriman': komentarPengiriman ?? '',
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 500) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error submitReview: $e');
      return null;
    }
  }

  // =====================================================
  // GET PRODUCT REVIEW SUMMARY
  // =====================================================
  static Future<Map<String, dynamic>?> getProductReviewSummary(
    int productId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/produk/$productId/review-summary'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getProductReviewSummary: $e');
      return null;
    }
  }

  // =====================================================
  // CHATBOT
  // =====================================================
  static Future<String?> sendChat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chatbot'),
        headers: await _authHeaders(),
        body: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      }

      // Jika statusnya 500 karena AI server mati, kita decode pesan error ramah dari Laravel
      try {
        final errorData = jsonDecode(response.body);
        if (errorData != null && errorData['reply'] != null) {
          return errorData['reply'];
        }
      } catch (_) {}

      return null;
    } catch (e) {
      print('Error sendChat: $e');
      return null;
    }
  }
}
