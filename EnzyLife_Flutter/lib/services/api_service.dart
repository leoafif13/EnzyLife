import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/artikel.dart';

class ApiService {

  // Android Emulator
  static const String _baseUrl = 'http://localhost:8000/api';

  // Cache
  static List<Product> cachedProducts = [];
  static List<ArtikelModel> cachedArtikel = [];

  // =====================================================
  // PRODUCTS
  // =====================================================

  static Future<List<Product>> getProducts() async {
    try {

      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Accept': 'application/json',
        },
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
        headers: {
          'Accept': 'application/json',
        },
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
        headers: {
          'Accept': 'application/json',
        },
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
}