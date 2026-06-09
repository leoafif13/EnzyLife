class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String image;
  final bool isPopular;
  final int salesCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.isPopular = false,
    this.salesCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['nama'] ?? '',
      description: json['deskripsi'] ?? '',
      price: double.parse(json['harga'].toString()).toInt(),
      stock: double.parse(json['stok'].toString()).toInt(),
      image: json['gambar'] ?? '',
      isPopular: json['is_popular'] ?? false,
      salesCount: double.parse((json['sales_count'] ?? 0).toString()).toInt(),
    );
  }
}