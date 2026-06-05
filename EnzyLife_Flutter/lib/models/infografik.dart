class InfografikModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String gambar;
  final String createdAt;

  InfografikModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambar,
    required this.createdAt,
  });

  factory InfografikModel.fromJson(Map<String, dynamic> json) {
    return InfografikModel(
      id: json['id_infografik'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}