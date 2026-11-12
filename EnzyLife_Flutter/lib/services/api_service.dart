import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/artikel.dart';
import '../models/infografik.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/product_tracker.dart';
import '../models/user_routine.dart';
import '../models/weekly_recap.dart';
import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = '${AppConfig.webBaseUrl}/api';

  // Cache
  static List<Product> cachedProducts = [];
  static List<ArtikelModel> cachedArtikel = [];
  static List<InfografikModel> cachedInfografik = [];
  static UserModel? cachedUser;

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  // =====================================================
  // PRODUCTS
  // =====================================================

  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final products = List<Product>.from(
          data['data'].map((x) => Product.fromJson(x)),
        );

        cachedProducts = products;

        return products;
      }

      return [];
    } catch (e) {
      print('Error getProducts: $e');

      return [];
    }
  }

  static Future<Map<String, dynamic>> getProductsPaginated({
    int page = 1,
    int perPage = 6,
    String? sortBy,
    String? sortOrder,
    String? search,
    int? rating,
    List<String>? kategori,
  }) async {
    try {
      String url = '$_baseUrl/products?page=$page&per_page=$perPage';
      if (sortBy != null) url += '&sort_by=$sortBy';
      if (sortOrder != null) url += '&sort_order=$sortOrder';
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }
      if (rating != null) {
        url += '&rating=$rating';
      }
      if (kategori != null && kategori.isNotEmpty) {
        url += '&kategori=${Uri.encodeComponent(kategori.join(','))}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawData = decoded['data'];
        List<Product> products = [];
        int lastPage = 1;

        if (rawData is Map && rawData.containsKey('data')) {
          products = List<Product>.from(
            rawData['data'].map((x) => Product.fromJson(x)),
          );
          lastPage = rawData['last_page'] ?? 1;
        } else if (rawData is List) {
          products = List<Product>.from(
            rawData.map((x) => Product.fromJson(x)),
          );
        }

        // Cache first page
        if (page == 1 && (search == null || search.isEmpty)) {
          cachedProducts = products;
        }

        return {'products': products, 'last_page': lastPage};
      }
      return {'products': <Product>[], 'last_page': 1};
    } catch (e) {
      print('Error getProductsPaginated: $e');
      return {'products': <Product>[], 'last_page': 1};
    }
  }

  // =====================================================
  // ARTIKEL
  // =====================================================

  static Future<List<ArtikelModel>> getArtikel() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/artikel'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final artikel = List<ArtikelModel>.from(
          data['data'].map((x) => ArtikelModel.fromJson(x)),
        );

        cachedArtikel = artikel;

        return artikel;
      }

      return [];
    } catch (e) {
      print('Error getArtikel: $e');

      return [];
    }
  }

  // =====================================================
  // DETAIL ARTIKEL
  // =====================================================

  static Future<ArtikelModel?> getDetailArtikel(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/artikel/$id'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return ArtikelModel.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      print('Error getDetailArtikel: $e');

      return null;
    }
  }

  // =====================================================
  // INFOGRAFIK
  // =====================================================

  static Future<List<InfografikModel>> getInfografik() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/infografik'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final infografik = data
            .map((e) => InfografikModel.fromJson(e))
            .toList();

        cachedInfografik = infografik;

        return infografik;
      }

      return [];
    } catch (e) {
      print('Error getInfografik: $e');

      return [];
    }
  }

  // =====================================================
  // PROFILE
  // =====================================================

  static Future<UserModel?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = UserModel.fromJson(data['user']);

        cachedUser = user;

        return user;
      }

      return null;
    } catch (e) {
      print('Error getProfile: $e');

      return null;
    }
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  static Future<bool> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? postalCode,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: await _authHeaders(),
        body: {
          'name': name,
          'phone': phone ?? '',
          'address': address ?? '',
          'postal_code': postalCode ?? '',
        }, 
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updateProfile: $e');

      return false;
    }
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/profile/password'),
        headers: await _authHeaders(),
        body: {
          'current_password': oldPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah password',
        };
      }
    } catch (e) {
      print('Error updatePassword: $e');
      return {'success': false, 'message': 'Gagal menghubungkan ke server.'};
    }
  }

  // =====================================================
  // CHECKOUT / PEMESANAN
  // =====================================================

  static Future<Map<String, dynamic>?> checkout({
    required List<Map<String, dynamic>> items,
    required String metodePembayaran,
    String? jenisCod,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/checkout'),
        headers: headers,
        body: jsonEncode({
          'items': items,
          'metode_pembayaran': metodePembayaran,
          'jenis_cod': jenisCod,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      print(
        'Checkout error status: ${response.statusCode}, body: ${response.body}',
      );
      return null;
    } catch (e) {
      print('Error checkout: $e');
      return null;
    }
  }

  // =====================================================
  // ORDER HISTORY
  // =====================================================

  static Future<List<OrderModel>> getOrderHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List ordersJson = data['data'] ?? [];
          return ordersJson.map((e) => OrderModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getOrderHistory: $e');
      return [];
    }
  }

  // =====================================================
  // CONFIRM ORDER PAYMENT
  // =====================================================

  static Future<Map<String, dynamic>?> payOrder(
    int orderId, {
    bool simulate = false,
  }) async {
    try {
      final headers = await _authHeaders();
      final body = simulate ? {'simulate': 'true'} : <String, String>{};
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/pay'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error payOrder: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> cancelOrder(int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/orders/$orderId/cancel'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 400) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error cancelOrder: $e');
      return null;
    }
  }

  // =====================================================
  // SUBMIT REVIEW / ULASAN
  // =====================================================
  // SUBMIT REVIEW / ULASAN
  // =====================================================
  static Future<Map<String, dynamic>?> submitReview({
    required int orderId,
    required int productId,
    required int rating,
    required String komentarAroma,
    String? komentarPengiriman,
    int? trackerId,
  }) async {
    try {
      final body = <String, String>{
        'pemesanan_id': orderId.toString(),
        'produk_id': productId.toString(),
        'rating': rating.toString(),
        'komentar_aroma': komentarAroma,
        'komentar_pengiriman': komentarPengiriman ?? '',
      };
      if (trackerId != null) {
        body['tracker_id'] = trackerId.toString();
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/review'),
        headers: await _authHeaders(),
        body: body,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 400 ||
          response.statusCode == 500) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error submitReview: $e');
      return null;
    }
  }

  // =====================================================
  // GET PRODUCT REVIEW SUMMARY
  // =====================================================
  static Future<Map<String, dynamic>?> getProductReviewSummary(
    int productId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/produk/$productId/review-summary'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getProductReviewSummary: $e');
      return null;
    }
  }

  // =====================================================
  // PRODUCT TRACKER
  // =====================================================

  /// Mulai tracking baru untuk produk dalam pesanan selesai
  static Future<Map<String, dynamic>?> startTracker({
    required int pemesananId,
    required int productId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tracker'),
        headers: await _authHeaders(),
        body: {
          'pemesanan_id': pemesananId.toString(),
          'produk_id': productId.toString(),
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error startTracker: $e');
      return null;
    }
  }

  /// List semua tracker milik user (aktif & riwayat selesai)
  static Future<List<ProductTracker>> getTrackers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tracker'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => ProductTracker.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getTrackers: $e');
      return [];
    }
  }

  /// Detail tracker beserta riwayat log dan stats
  static Future<ProductTracker?> getTrackerDetail(int trackerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tracker/$trackerId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return ProductTracker.fromJson(
            decoded['data'],
            statsJson: decoded['stats'] is Map<String, dynamic> ? decoded['stats'] : null,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getTrackerDetail: $e');
      return null;
    }
  }

  /// Tambah log pemakaian harian
  static Future<Map<String, dynamic>?> addTrackerLog({
    required int trackerId,
    required String tanggal,
    required String waktu,
    String? catatan,
  }) async {
    try {
      final body = <String, String>{
        'tanggal': tanggal,
        'waktu': waktu,
      };
      if (catatan != null && catatan.isNotEmpty) {
        body['catatan'] = catatan;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/tracker/$trackerId/log'),
        headers: await _authHeaders(),
        body: body,
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error addTrackerLog: $e');
      return null;
    }
  }

  /// Hapus log pemakaian tertentu
  static Future<bool> deleteTrackerLog({
    required int trackerId,
    required int logId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/tracker/$trackerId/log/$logId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleteTrackerLog: $e');
      return false;
    }
  }

  /// Perpanjang tracker (1 atau 2 minggu tambahan)
  static Future<Map<String, dynamic>?> perpanjangTracker({
    required int trackerId,
    required int durasiTambahanMinggu,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tracker/$trackerId/perpanjang'),
        headers: await _authHeaders(),
        body: {
          'durasi_tambahan_minggu': durasiTambahanMinggu.toString(),
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error perpanjangTracker: $e');
      return null;
    }
  }

  /// Selesaikan tracking + catatan hasil akhir
  static Future<Map<String, dynamic>?> selesaiTracker({
    required int trackerId,
    String? catatanHasil,
  }) async {
    try {
      final body = <String, String>{};
      if (catatanHasil != null && catatanHasil.isNotEmpty) {
        body['catatan_hasil'] = catatanHasil;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/tracker/$trackerId/selesai'),
        headers: await _authHeaders(),
        body: body,
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error selesaiTracker: $e');
      return null;
    }
  }

  /// Batalkan tracker
  static Future<Map<String, dynamic>?> batalkanTracker(int trackerId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tracker/$trackerId/batalkan'),
        headers: await _authHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error batalkanTracker: $e');
      return null;
    }
  }

  /// Ambil statistik chart tracker
  static Future<Map<String, dynamic>?> getTrackerStats(int trackerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tracker/$trackerId/stats'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getTrackerStats: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════
  //  ROUTINE TRACKER (SIKLUS 7 HARI)
  // ═══════════════════════════════════════════════════

  /// Dapatkan template kategori rutinitas
  static Future<List<Map<String, dynamic>>> getRoutineCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/routines/categories'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error getRoutineCategories: $e');
      return [];
    }
  }

  /// Setup rutinitas awal
  static Future<Map<String, dynamic>?> setupRoutines({
    required List<String> kategori,
    int? trackerId,
    String? jamPengingat,
    double? stokAwalMl,
    int? pemesananId,
    int? produkId,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/routines/setup'),
        headers: headers,
        body: jsonEncode({
          'kategori': kategori,
          if (trackerId != null) 'tracker_id': trackerId,
          'jam_pengingat': jamPengingat ?? '19:00',
          'stok_awal_ml': stokAwalMl ?? 1000,
          if (pemesananId != null) 'pemesanan_id': pemesananId,
          if (produkId != null) 'produk_id': produkId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error setupRoutines: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> sendAiMessage({
    required int conversationId,
    required String pertanyaan,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/percakapan/$conversationId/pesan'),
        headers: headers,
        body: jsonEncode({
          'pertanyaan': pertanyaan,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print('Send AI message: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error sendAiMessage: $e');
      return null;
    }
  }

  /// Dashboard rutinitas hari ini
  static Future<RoutineDashboardData?> getRoutineDashboard({int? trackerId}) async {
    try {
      final url = trackerId != null
          ? '$_baseUrl/routines/dashboard?tracker_id=$trackerId'
          : '$_baseUrl/routines/dashboard';

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RoutineDashboardData.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getRoutineDashboard: $e');
      return null;
    }
  }

  // Ambil detail percakapan beserta riwayat pesan.
  static Future<Map<String, dynamic>?> getAiConversationDetail(
    int conversationId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/percakapan/$conversationId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      print('Detail AI error: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error getAiConversationDetail: $e');
      return null;
    }
  }

  /// 1-Tap Checkin pemakaian hari ini
  static Future<Map<String, dynamic>?> routineCheckin(int routineId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/routines/$routineId/checkin'),
        headers: await _authHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error routineCheckin: $e');
      return null;
    }
  }

  /// Batalkan checkin hari ini
  static Future<Map<String, dynamic>?> routineUncheckin(int routineId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/routines/$routineId/checkin'),
        headers: await _authHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error routineUncheckin: $e');
      return null;
    }
  }

  /// Ambil data rekap hari ke-7
  static Future<WeeklyRecapData?> getWeeklyRecap({int? trackerId}) async {
    try {
      final url = trackerId != null
          ? '$_baseUrl/routines/weekly-recap?tracker_id=$trackerId'
          : '$_baseUrl/routines/weekly-recap';

      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeeklyRecapData.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getWeeklyRecap: $e');
      return null;
    }
  }

  // Simpan percakapan.
  static Future<Map<String, dynamic>?> saveAiConversation(
    int conversationId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/percakapan/$conversationId/simpan'),
        headers: await _authHeaders(),
      );

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return {
          ...data,
          'success': response.statusCode >= 200 &&
              response.statusCode < 300,
        };
      }

      return null;
    } catch (e) {
      print('Error saveAiConversation: $e');
      return null;
    }
  }

  /// Submit feedback rekap hari ke-7 & mulai siklus berikutnya
  static Future<Map<String, dynamic>?> submitWeeklyRecap({
    int? trackerId,
    String? chipFeedback,
    String? catatanRefleksi,
    bool tandaiSelesai = false,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/routines/weekly-recap/submit'),
        headers: headers,
        body: jsonEncode({
          if (trackerId != null) 'tracker_id': trackerId,
          'chip_feedback': chipFeedback,
          'catatan_refleksi': catatanRefleksi,
          'tandai_selesai': tandaiSelesai,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error submitWeeklyRecap: $e');
      return null;
    }
  }

  // Kirim feedback untuk percakapan.
  static Future<Map<String, dynamic>?> sendAiFeedback({
    required int conversationId,
    required bool membantu,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        Uri.parse('$_baseUrl/percakapan/$conversationId/feedback'),
        headers: headers,
        body: jsonEncode({
          'feedback': membantu ? 'membantu' : 'tidak_membantu',
        }),
      );

      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return {
          ...data,
          'success': response.statusCode >= 200 &&
              response.statusCode < 300,
        };
      }

      return null;
    } catch (e) {
      print('Error sendAiFeedback: $e');
      return null;
    }
  }

  /// Simulasi waktu / progres siklus tracker untuk pengujian (Hari 7, Minggu 2, Minggu 3, Minggu 4, Reset)
  static Future<Map<String, dynamic>?> simulateRoutineProgress({
    required int trackerId,
    required String target,
  }) async {
    try {
      final headers = await _authHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        Uri.parse('$_baseUrl/routines/simulate-progress'),
        headers: headers,
        body: jsonEncode({
          'tracker_id': trackerId,
          'target': target,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error simulateRoutineProgress: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> deleteAiConversation(
    int conversationId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/percakapan/$conversationId'),
        headers: await _authHeaders(),
      );

      final dynamic data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return {
          ...data,
          'success': response.statusCode >= 200 &&
              response.statusCode < 300,
        };
      }

      return null;
    } catch (e) {
      print('Error deleteAiConversation: $e');
      return null;
    }
  }
}
