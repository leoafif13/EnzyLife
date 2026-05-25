class Product {
  final int id;
  final String nama;
  final String deskripsi;
  final int harga;
  final String gambar;
  final int stok;

  Product({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.gambar,
    required this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'] ?? '',
      harga: json['harga'],
      gambar: json['gambar'] ?? '',
      stok: json['stok'] ?? 0,
    );
  }
}