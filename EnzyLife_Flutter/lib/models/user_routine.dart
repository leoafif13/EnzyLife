import 'product.dart';

class RoutineCalendarDay {
  final int index;
  final String date;
  final String dayName;
  final String dayNum;
  final bool isToday;
  final bool isPast;
  final bool isFuture;

  RoutineCalendarDay({
    required this.index,
    required this.date,
    required this.dayName,
    required this.dayNum,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
  });

  factory RoutineCalendarDay.fromJson(Map<String, dynamic> json) {
    return RoutineCalendarDay(
      index: (json['index'] as num?)?.toInt() ?? 1,
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      dayNum: json['day_num'] ?? '',
      isToday: json['is_today'] == true,
      isPast: json['is_past'] == true,
      isFuture: json['is_future'] == true,
    );
  }
}

class UserRoutineItem {
  final int id;
  final int? trackerId;
  final String kategoriNama;
  final String tipeTarget; // HARIAN, MINGGUAN, FLEKSIBEL
  final int targetMin;
  final int targetMax;
  final int totalCheckin;
  final bool hasCheckedToday;
  final int? daysSinceLast;
  final String statusLabel; // Optimal, Tercapai, Belum Tercapai, Fleksibel
  final double takaranMlPerPakai;
  final String? takaranLengkap;
  final String? airLabel;
  final String? wadahLabel;
  final int siklusKe;
  final int hariKe;
  final String? tanggalMulai;
  final bool isRecapReady;
  final String? customRasioLabel;
  final String? jadwalRekomendasi;
  final List<String> checkedDates;
  final double stokSisaMl;
  final Product? produk;

  UserRoutineItem({
    required this.id,
    this.trackerId,
    required this.kategoriNama,
    this.siklusKe = 1,
    this.hariKe = 1,
    this.tanggalMulai,
    this.isRecapReady = false,
    required this.tipeTarget,
    required this.targetMin,
    required this.targetMax,
    required this.totalCheckin,
    required this.hasCheckedToday,
    this.daysSinceLast,
    required this.statusLabel,
    required this.takaranMlPerPakai,
    this.takaranLengkap,
    this.airLabel,
    this.wadahLabel,
    this.customRasioLabel,
    this.jadwalRekomendasi,
    this.checkedDates = const [],
    required this.stokSisaMl,
    this.produk,
  });

  factory UserRoutineItem.fromJson(Map<String, dynamic> json) {
    var rawChecked = json['checked_dates'] as List? ?? [];
    return UserRoutineItem(
      id: json['id'] ?? 0,
      trackerId: (json['tracker_id'] as num?)?.toInt(),
      kategoriNama: json['kategori_nama'] ?? '',
      siklusKe: (json['siklus_ke'] as num?)?.toInt() ?? 1,
      hariKe: (json['hari_ke'] as num?)?.toInt() ?? 1,
      tanggalMulai: json['tanggal_mulai'] as String?,
      isRecapReady: json['is_recap_ready'] == true,
      tipeTarget: json['tipe_target'] ?? 'MINGGUAN',
      targetMin: (json['target_min'] as num?)?.toInt() ?? 1,
      targetMax: (json['target_max'] as num?)?.toInt() ?? 7,
      totalCheckin: (json['total_checkin'] as num?)?.toInt() ?? 0,
      hasCheckedToday: json['has_checked_today'] == true,
      daysSinceLast: (json['days_since_last'] as num?)?.toInt(),
      statusLabel: json['status_label'] ?? 'Dalam Progres',
      takaranMlPerPakai: (json['takaran_ml_per_pakai'] as num?)?.toDouble() ?? 50.0,
      takaranLengkap: json['takaran_lengkap'] as String?,
      airLabel: json['air_label'] as String?,
      wadahLabel: json['wadah_label'] as String?,
      customRasioLabel: json['rasio_label'] as String?,
      jadwalRekomendasi: json['jadwal_rekomendasi'] as String?,
      checkedDates: rawChecked.map((e) => e.toString()).toList(),
      stokSisaMl: (json['stok_sisa_ml'] as num?)?.toDouble() ?? 1000.0,
      produk: json['produk'] != null ? Product.fromJson(json['produk']) : null,
    );
  }

  String get rasioLabel {
    if (customRasioLabel != null && customRasioLabel!.isNotEmpty) {
      return customRasioLabel!;
    }
    switch (kategoriNama) {
      case 'Kompor & Area Dapur':
        return '1:10 (Semprot 500 ml)';
      case 'Pel Lantai':
      case 'Pembersih Lantai (Pel)':
        return '1:50 (Ember 5 Liter)';
      case 'Cuci Piring':
      case 'Cuci Piring / Wastafel':
        return '1:1 (Botol Sabun)';
      case 'Cuci Pakaian':
        return '1:10 (Mesin Cuci)';
      case 'Kamar Mandi':
        return '1:10 (Sikat Toilet)';
      case 'Saluran Air':
      case 'Penjernih Saluran Air':
        return '1:1 (Gayung 1 Liter)';
      case 'Penghilang Bau':
        return '1:500 (Botol Semprot)';
      case 'Pupuk Organik':
      case 'Penyubur Tanaman':
        return '1:1000 (Semprotan 1 Liter)';
      case 'Pestisida Sayuran':
        return '1:500 (Semprotan 1 Liter)';
      case 'Kompos':
        return '1:100 (Siram 1 Liter)';
      case 'Air Purifier':
        return '1:1000 (Diffuser 500 ml)';
      default:
        return '1:10 Air';
    }
  }

  String get ringkasanTakaran {
    if (takaranLengkap != null && takaranLengkap!.isNotEmpty) {
      return takaranLengkap!;
    }
    return '${takaranMlPerPakai.toStringAsFixed(0)} mL Eco Enzyme + Air';
  }

  String get targetProgressText {
    if (tipeTarget == 'FLEKSIBEL') {
      return '$totalCheckin kali dipakai';
    }
    return '$totalCheckin dari $targetMin-$targetMax target';
  }
}

class RoutineDashboardData {
  final bool hasRoutines;
  final int siklusKe;
  final int maxSiklus;
  final int hariKe;
  final bool isRecapReady;
  final double totalTerpakaiSiklusMl;
  final double stokSisaMl;
  final double? prediksiSisaMinggu;
  final bool canUnlockVerifiedReview;
  final List<RoutineCalendarDay> calendarDays;
  final List<UserRoutineItem> routines;

  RoutineDashboardData({
    required this.hasRoutines,
    this.siklusKe = 1,
    this.maxSiklus = 4,
    this.hariKe = 1,
    this.isRecapReady = false,
    this.totalTerpakaiSiklusMl = 0.0,
    this.stokSisaMl = 1000.0,
    this.prediksiSisaMinggu,
    this.canUnlockVerifiedReview = false,
    this.calendarDays = const [],
    this.routines = const [],
  });

  factory RoutineDashboardData.fromJson(Map<String, dynamic> json) {
    var rawRoutines = json['routines'] as List? ?? [];
    var rawCalendar = json['calendar_days'] as List? ?? [];
    return RoutineDashboardData(
      hasRoutines: json['has_routines'] == true,
      siklusKe: (json['siklus_ke'] as num?)?.toInt() ?? 1,
      maxSiklus: (json['max_siklus'] as num?)?.toInt() ?? 4,
      hariKe: (json['hari_ke'] as num?)?.toInt() ?? 1,
      isRecapReady: json['is_recap_ready'] == true,
      totalTerpakaiSiklusMl: (json['total_terpakai_siklus_ml'] as num?)?.toDouble() ?? 0.0,
      stokSisaMl: (json['stok_sisa_ml'] as num?)?.toDouble() ?? 1000.0,
      prediksiSisaMinggu: (json['prediksi_sisa_minggu'] as num?)?.toDouble(),
      canUnlockVerifiedReview: json['can_unlock_verified_review'] == true,
      calendarDays: rawCalendar.map((e) => RoutineCalendarDay.fromJson(e)).toList(),
      routines: rawRoutines.map((e) => UserRoutineItem.fromJson(e)).toList(),
    );
  }
}
