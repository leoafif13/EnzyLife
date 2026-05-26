import 'dart:convert';
import 'package:http/http.dart' as http;

import '../belanja_page.dart';

class ProductService {
  static List<Product> cachedProducts = [];
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      final products = List<Product>.from(
        data['data'].map((x) => Product.fromJson(x)),
      );

      cachedProducts = products;

      if (response.statusCode == 200) {
        return products;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}