class WeeklyRecapItem {
  final int routineId;
  final String kategoriNama;
  final String tipeTarget;
  final int totalCheckin;
  final int targetMin;
  final int targetMax;
  final String statusPencapaian; // BELUM_TERCAPAI, TERCAPAI, OPTIMAL, FLEKSIBEL
  final double estimasiMlTerpakai;

  WeeklyRecapItem({
    required this.routineId,
    required this.kategoriNama,
    required this.tipeTarget,
    required this.totalCheckin,
    required this.targetMin,
    required this.targetMax,
    required this.statusPencapaian,
    required this.estimasiMlTerpakai,
  });

  factory WeeklyRecapItem.fromJson(Map<String, dynamic> json) {
    return WeeklyRecapItem(
      routineId: (json['routine_id'] as num?)?.toInt() ?? 0,
      kategoriNama: json['kategori_nama'] ?? '',
      tipeTarget: json['tipe_target'] ?? 'MINGGUAN',
      totalCheckin: (json['total_checkin'] as num?)?.toInt() ?? 0,
      targetMin: (json['target_min'] as num?)?.toInt() ?? 1,
      targetMax: (json['target_max'] as num?)?.toInt() ?? 7,
      statusPencapaian: json['status_pencapaian'] ?? 'BELUM_TERCAPAI',
      estimasiMlTerpakai: (json['estimasi_ml_terpakai'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get statusDisplayLabel {
    switch (statusPencapaian) {
      case 'OPTIMAL':
        return 'Optimal 🌟';
      case 'TERCAPAI':
        return 'Tercapai ✅';
      case 'BELUM_TERCAPAI':
        return 'Belum Tercapai';
      default:
        return 'Fleksibel';
    }
  }
}

class WeeklyRecapData {
  final int siklusKe;
  final String tanggalMulai;
  final String tanggalSelesai;
  final double totalMlTerpakai;
  final double stokSisaMl;
  final double? prediksiSisaMinggu;
  final bool canUnlockVerifiedReview;
  final List<WeeklyRecapItem> items;

  WeeklyRecapData({
    required this.siklusKe,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.totalMlTerpakai,
    required this.stokSisaMl,
    this.prediksiSisaMinggu,
    required this.canUnlockVerifiedReview,
    required this.items,
  });

  factory WeeklyRecapData.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    return WeeklyRecapData(
      siklusKe: (json['siklus_ke'] as num?)?.toInt() ?? 1,
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      totalMlTerpakai: (json['total_ml_terpakai'] as num?)?.toDouble() ?? 0.0,
      stokSisaMl: (json['stok_sisa_ml'] as num?)?.toDouble() ?? 1000.0,
      prediksiSisaMinggu: (json['prediksi_sisa_minggu'] as num?)?.toDouble(),
      canUnlockVerifiedReview: json['can_unlock_verified_review'] == true,
      items: rawItems.map((e) => WeeklyRecapItem.fromJson(e)).toList(),
    );
  }
}
