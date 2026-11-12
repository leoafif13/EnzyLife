class TrackerLog {
  final int id;
  final int trackerId;
  final String tanggal;
  final String waktu;
  final String? catatan;
  final DateTime? createdAt;

  TrackerLog({
    required this.id,
    required this.trackerId,
    required this.tanggal,
    required this.waktu,
    this.catatan,
    this.createdAt,
  });

  factory TrackerLog.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    if (json['waktu'] != null) {
      final w = json['waktu'].toString();
      formattedTime = w.length >= 5 ? w.substring(0, 5) : w;
    }

    String formattedDate = '';
    if (json['tanggal'] != null) {
      formattedDate = json['tanggal'].toString().split('T').first;
    }

    return TrackerLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      trackerId: json['tracker_id'] is int ? json['tracker_id'] : int.tryParse(json['tracker_id'].toString()) ?? 0,
      tanggal: formattedDate,
      waktu: formattedTime,
      catatan: json['catatan'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracker_id': trackerId,
      'tanggal': tanggal,
      'waktu': waktu,
      'catatan': catatan,
    };
  }
}
