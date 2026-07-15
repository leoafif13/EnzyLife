import 'package:flutter/material.dart';
import '../../app_color.dart';
import '../../models/product.dart';
import '../../state/cart_state.dart';
import '../../widgets/animated_press_card.dart';
import '../../widgets/purchase_bottom_sheet.dart';
import '../detail_produk_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String Function(int) fmtPrice;
  final VoidCallback onChanged;
  const ProductCard({
    super.key,
    required this.product,
    required this.fmtPrice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cart = CartState.instance;
    final qty = cart.qty(product.id);
    final heroTag = 'list_prod_${product.id}';

    return AnimatedPressCard(
      // Tap card → detail produk
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(product: product, heroTag: heroTag),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Hero(
                    tag: heroTag,
                    child: Image.network(
                      'https://undergo-refill-bonehead.ngrok-free.dev/gambar/produk/${product.image.split('/').last}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.stock > 0
                                ? 'Stok: ${product.stock}'
                                : 'Stok Habis',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: product.stock > 0
                                  ? AppColors.green500
                                  : Colors.red,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text1,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' (${product.ratingCount})',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.text3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.salesCount > 0) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '|  ${product.salesCount} terjual',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            fmtPrice(product.price),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            if (product.stock > 0) ...[
                              // Tombol keranjang
                              _IconBtn(
                                icon: Icons.shopping_cart_outlined,
                                onTap: () {
                                  if (cart.qty(product.id) < product.stock) {
                                    cart.add(product.id);
                                    onChanged();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Batas stok maksimum tercapai (${product.stock} item)',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.orange[800],
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              // Tombol Beli → modal bottom sheet
                              _SmallBtn(
                                label: 'Beli',
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) =>
                                      PurchaseBottomSheet(product: product),
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Habis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    // Badge qty di keranjang
                    if (qty > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 11,
                            color: AppColors.green500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$qty item di keranjang',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.green500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Icon button keranjang ─────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green200),
      ),
      child: const Icon(
        Icons.shopping_cart_outlined,
        size: 16,
        color: AppColors.green500,
      ),
    ),
  );
}

// ── Small button ──────────────────────────────
class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.green500,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
