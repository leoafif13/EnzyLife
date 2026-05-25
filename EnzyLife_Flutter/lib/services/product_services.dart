import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<Product>> getProducts() async {

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      List products = data['data'];

      return products
          .map((e) => Product.fromJson(e))
          .toList();

    } else {
      throw Exception('Gagal mengambil produk');
    }
  }
}