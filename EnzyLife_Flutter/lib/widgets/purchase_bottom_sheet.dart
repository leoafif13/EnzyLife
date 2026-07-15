import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../app_color.dart';
import '../belanja/checkout_page.dart';
import '../services/format_helper.dart';

class PurchaseBottomSheet extends StatefulWidget {
  final Product product;
  final int initialQty;

  const PurchaseBottomSheet({
    super.key,
    required this.product,
    this.initialQty = 1,
  });

  @override
  State<PurchaseBottomSheet> createState() => _PurchaseBottomSheetState();
}

class _PurchaseBottomSheetState extends State<PurchaseBottomSheet> {
  late int _qty;

  @override
  void initState() {
    super.initState();
    _qty = widget.initialQty;
    // Pastikan qty tidak melebihi stok
    if (_qty > widget.product.stock) {
      _qty = widget.product.stock;
    }
    if (_qty < 1 && widget.product.stock > 0) {
      _qty = 1;
    }
  }

  static String _fmt(int price) => formatPrice(price);

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle geser bawah
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          // Info Produk (Foto, Nama, Harga, Stok)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 88,
                  height: 88,
                  color: AppColors.green50,
                  child: Image.network(
                    '${AppConfig.webBaseUrl}/gambar/produk/${p.image.split('/').last}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.image_not_supported, color: AppColors.green500);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fmt(p.price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.stock > 0 ? 'Stok: ${p.stock}' : 'Stok Habis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p.stock > 0 ? AppColors.green500 : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),
          
          // Selector Jumlah
          Row(
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.green500),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_qty > 1) setState(() => _qty--);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: _qty > 1 ? AppColors.green500 : Colors.grey[300],
                        ),
                      ),
                    ),
                    Text(
                      '$_qty',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_qty < p.stock) {
                          setState(() => _qty++);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Batas pembelian maksimum tercapai (${p.stock} item)'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.orange[800],
                            ),
                          );
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Icon(Icons.add, size: 16, color: AppColors.green500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          // Tombol Beli Sekarang
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: p.stock > 0
                  ? () {
                      Navigator.of(context).pop(); // Tutup bottom sheet
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutPage(
                            items: {p.id: _qty},
                            allProducts: [p],
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.stock > 0 ? AppColors.green500 : Colors.grey[300],
                foregroundColor: p.stock > 0 ? Colors.white : Colors.grey[500],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                p.stock > 0 ? 'Beli Sekarang' : 'Stok Habis',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
