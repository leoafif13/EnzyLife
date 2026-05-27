class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int stock;
  final String image;
  final bool isPopular;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    this.isPopular = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['nama'] ?? '',
      description: json['deskripsi'] ?? '',
      price: int.parse(json['harga'].toString()),
      stock: int.parse(json['stok'].toString()),
      image: json['gambar'] ?? '',
      isPopular: json['is_popular'] ?? false,
    );
  }
}