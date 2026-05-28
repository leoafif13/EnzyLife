class ArtikelModel {

  final int id;
  final String judul;
  final String ringkasan;
  final String isiKonten;
  final String gambar;
  final String kategori;
  final String createdAt;

  ArtikelModel({
    required this.id,
    required this.judul,
    required this.ringkasan,
    required this.isiKonten,
    required this.gambar,
    required this.kategori,
    required this.createdAt,
  });

  factory ArtikelModel.fromJson(Map<String, dynamic> json) {

    return ArtikelModel(
      id: json['id_artikel'] ?? 0,

      judul: json['judul'] ?? '',

      ringkasan: json['ringkasan'] ?? '',

      isiKonten: json['isi_konten'] ?? '',

      gambar: json['gambar'] ?? '',

      kategori: json['kategori'] ?? '',

      createdAt: json['created_at'] ?? '',
    );
  }
}