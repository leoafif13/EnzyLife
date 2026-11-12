import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String image;
  final bool isPopular;
  final int salesCount;
  final double ratingAvg;
  final int ratingCount;
  final Map<String, dynamic>? spesifikasi;
  final List<String> kategoriList;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.isPopular = false,
    this.salesCount = 0,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.spesifikasi,
    this.kategoriList = const [],
  });

  /// Getter untuk backward compatibility dengan kode lama yang membaca prod.kategori sebagai String
  String get kategori => kategoriList.isNotEmpty ? kategoriList.join(' • ') : 'Eco Enzyme';

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedKategori = [];
    if (json['kategori'] is List) {
      parsedKategori = (json['kategori'] as List).map((e) => e.toString()).toList();
    } else if (json['kategori'] is String && json['kategori'].toString().trim().isNotEmpty) {
      // Jika string berformat koma atau tunggal
      final str = json['kategori'].toString().trim();
      if (str.startsWith('[') && str.endsWith(']')) {
        // format json string
        try {
          parsedKategori = (jsonDecode(str) as List).map((e) => e.toString()).toList();
        } catch (_) {
          parsedKategori = [str];
        }
      } else {
        parsedKategori = str.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    }

    return Product(
      id: json['id'],
      name: json['nama'] ?? '',
      description: json['deskripsi'] ?? '',
      price: double.parse(json['harga'].toString()).toInt(),
      stock: double.parse(json['stok'].toString()).toInt(),
      image: json['gambar'] ?? '',
      isPopular: json['is_popular'] ?? false,
      salesCount: double.parse((json['sales_count'] ?? 0).toString()).toInt(),
      ratingAvg: double.parse((json['rating_avg'] ?? 0.0).toString()),
      ratingCount: int.parse((json['rating_count'] ?? 0).toString()),
      spesifikasi: json['spesifikasi'] is Map ? Map<String, dynamic>.from(json['spesifikasi']) : null,
      kategoriList: parsedKategori,
    );
  }
}