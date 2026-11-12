import 'product.dart';
import 'tracker_log.dart';

class TrackerStats {
  final int hariKe;
  final int totalHari;
  final int totalLogs;
  final double progresPersen;
  final bool sudahMingguKeTiga;
  final bool bisaPerpanjang;
  final int streakSaatIni;
  final int streakTerpanjang;
  final Map<String, int> logsPerHari;
  final Map<String, int> logsPerMinggu;

  TrackerStats({
    required this.hariKe,
    required this.totalHari,
    required this.totalLogs,
    required this.progresPersen,
    this.sudahMingguKeTiga = false,
    this.bisaPerpanjang = false,
    this.streakSaatIni = 0,
    this.streakTerpanjang = 0,
    this.logsPerHari = const {},
    this.logsPerMinggu = const {},
  });

  factory TrackerStats.fromJson(Map<String, dynamic> json) {
    Map<String, int> parsedLogsPerHari = {};
    if (json['logs_per_hari'] is Map) {
      json['logs_per_hari'].forEach((k, v) {
        parsedLogsPerHari[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
    }

    Map<String, int> parsedLogsPerMinggu = {};
    if (json['logs_per_minggu'] is Map) {
      json['logs_per_minggu'].forEach((k, v) {
        parsedLogsPerMinggu[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
    }

    return TrackerStats(
      hariKe: int.tryParse((json['hari_ke'] ?? 1).toString()) ?? 1,
      totalHari: int.tryParse((json['total_hari'] ?? 21).toString()) ?? 21,
      totalLogs: int.tryParse((json['total_logs'] ?? 0).toString()) ?? 0,
      progresPersen: double.tryParse((json['progres_persen'] ?? 0).toString()) ?? 0.0,
      sudahMingguKeTiga: json['sudah_minggu_ke_tiga'] == true,
      bisaPerpanjang: json['bisa_perpanjang'] == true,
      streakSaatIni: int.tryParse((json['streak_saat_ini'] ?? 0).toString()) ?? 0,
      streakTerpanjang: int.tryParse((json['streak_terpanjang'] ?? 0).toString()) ?? 0,
      logsPerHari: parsedLogsPerHari,
      logsPerMinggu: parsedLogsPerMinggu,
    );
  }
}

class ProductTracker {
  final int id;
  final int userId;
  final int pemesananId;
  final int produkId;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String? tanggalPerpanjangan;
  final String? catatanHasil;
  final String status;
  final int hariKe;
  final String? batasAkhir;
  final int logsCount;
  final Product? product;
  final List<TrackerLog> logs;
  final TrackerStats? stats;

  ProductTracker({
    required this.id,
    required this.userId,
    required this.pemesananId,
    required this.produkId,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.tanggalPerpanjangan,
    this.catatanHasil,
    required this.status,
    this.hariKe = 1,
    this.batasAkhir,
    this.logsCount = 0,
    this.product,
    this.logs = const [],
    this.stats,
  });

  bool get isAktif => status == 'AKTIF' || status == 'PERPANJANGAN';
  bool get isSelesai => status == 'SELESAI';
  bool get isDibatalkan => status == 'DIBATALKAN';

  factory ProductTracker.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? statsJson}) {
    List<TrackerLog> parsedLogs = [];
    if (json['logs'] is List) {
      parsedLogs = (json['logs'] as List)
          .map((item) => TrackerLog.fromJson(item))
          .toList();
    }

    Product? parsedProduct;
    if (json['produk'] is Map) {
      parsedProduct = Product.fromJson(json['produk']);
    }

    String tMulai = '';
    if (json['tanggal_mulai'] != null) {
      tMulai = json['tanggal_mulai'].toString().split('T').first;
    }

    String tSelesai = '';
    if (json['tanggal_selesai'] != null) {
      tSelesai = json['tanggal_selesai'].toString().split('T').first;
    }

    String? tPerpanjangan;
    if (json['tanggal_perpanjangan'] != null) {
      tPerpanjangan = json['tanggal_perpanjangan'].toString().split('T').first;
    }

    String? bAkhir;
    if (json['batas_akhir'] != null) {
      bAkhir = json['batas_akhir'].toString().split('T').first;
    }

    return ProductTracker(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      pemesananId: json['pemesanan_id'] is int ? json['pemesanan_id'] : int.tryParse(json['pemesanan_id'].toString()) ?? 0,
      produkId: json['produk_id'] is int ? json['produk_id'] : int.tryParse(json['produk_id'].toString()) ?? 0,
      tanggalMulai: tMulai,
      tanggalSelesai: tSelesai,
      tanggalPerpanjangan: tPerpanjangan,
      catatanHasil: json['catatan_hasil'],
      status: json['status'] ?? 'AKTIF',
      hariKe: int.tryParse((json['hari_ke'] ?? 1).toString()) ?? 1,
      batasAkhir: bAkhir ?? (tPerpanjangan ?? tSelesai),
      logsCount: int.tryParse((json['logs_count'] ?? parsedLogs.length).toString()) ?? parsedLogs.length,
      product: parsedProduct,
      logs: parsedLogs,
      stats: statsJson != null ? TrackerStats.fromJson(statsJson) : null,
    );
  }
}
