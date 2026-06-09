import 'product.dart';
import '../profil/riwayat_belanja_page.dart';
import 'package:flutter/material.dart';
import '../app_color.dart';

class OrderItemModel {
  final int id;
  final int quantity;
  final int price;
  final int subtotal;
  final Product? product;

  OrderItemModel({
    required this.id,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      quantity: json['kuantitas'] ?? 0,
      price: double.parse((json['harga'] ?? 0).toString()).toInt(),
      subtotal: double.parse((json['subtotal'] ?? 0).toString()).toInt(),
      product: json['produk'] != null ? Product.fromJson(json['produk']) : null,
    );
  }
}

class OrderModel {
  final int id;
  final int totalHarga;
  final String metodePembayaran;
  final String? jenisCod;
  final String statusPemesanan;
  final String createdAt;
  final List<OrderItemModel> items;
  final String? snapToken;

  OrderModel({
    required this.id,
    required this.totalHarga,
    required this.metodePembayaran,
    this.jenisCod,
    required this.statusPemesanan,
    required this.createdAt,
    required this.items,
    this.snapToken,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['detail_pemesanan'] as List? ?? [];
    String? token;
    if (json['pembayaran'] != null) {
      token = json['pembayaran']['snap_token'];
    }
    return OrderModel(
      id: json['id'] ?? 0,
      totalHarga: double.parse((json['total_harga'] ?? 0).toString()).toInt(),
      metodePembayaran: json['metode_pembayaran'] ?? '',
      jenisCod: json['jenis_cod'],
      statusPemesanan: json['status_pemesanan'] ?? 'MENUNGGU_PEMBAYARAN',
      createdAt: json['created_at'] ?? '',
      items: itemsList.map((e) => OrderItemModel.fromJson(e)).toList(),
      snapToken: token,
    );
  }

  OrderStatus get orderStatus {
    switch (statusPemesanan) {
      case 'DIKIRIM':
        return OrderStatus.dikirim;
      case 'SELESAI':
      case 'DIBATALKAN':
        return OrderStatus.selesai;
      default:
        return OrderStatus.dipesan;
    }
  }

  String get statusDescription {
    switch (statusPemesanan) {
      case 'MENUNGGU_PEMBAYARAN':
        return 'Menunggu Pembayaran';
      case 'DIPROSES':
        return 'Pesanan sedang Diproses';
      case 'DIKEMAS':
        return 'Pesanan sedang Dikemas';
      case 'SIAP_DIAMBIL':
        return 'Pesanan Siap Diambil di Lab';
      case 'DIKIRIM':
        return 'Pesanan dalam Pengiriman';
      case 'SELESAI':
        return 'Pesanan Selesai';
      case 'DIBATALKAN':
        return 'Pesanan Dibatalkan';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  Color get statusColor {
    switch (statusPemesanan) {
      case 'MENUNGGU_PEMBAYARAN':
        return const Color(0xFFE65100);
      case 'DIPROSES':
      case 'DIKEMAS':
        return const Color(0xFF512DA8);
      case 'SIAP_DIAMBIL':
      case 'SELESAI':
        return AppColors.green700;
      case 'DIKIRIM':
        return const Color(0xFF1565C0);
      case 'DIBATALKAN':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color get statusBgColor {
    switch (statusPemesanan) {
      case 'MENUNGGU_PEMBAYARAN':
        return const Color(0xFFFFF3E0);
      case 'DIPROSES':
      case 'DIKEMAS':
        return const Color(0xFFEDE7F6);
      case 'SIAP_DIAMBIL':
      case 'SELESAI':
        return AppColors.green50;
      case 'DIKIRIM':
        return const Color(0xFFE3F2FD);
      case 'DIBATALKAN':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
