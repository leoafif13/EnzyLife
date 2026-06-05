import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/artikel.dart';
import '../models/infografik.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {

  // Android Emulator
  static const String _baseUrl = 'http://localhost:8000/api';

  // Cache
  static List<Product> cachedProducts = [];
  static List<ArtikelModel> cachedArtikel = [];
  static List<InfografikModel> cachedInfografik = [];
  static UserModel? cachedUser;

  static Future<Map<String, String>> _authHeaders() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
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

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
}