import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../app_color.dart';
import '../../models/product.dart';
import '../../widgets/animated_press_card.dart';
import '../detail_produk_page.dart';

class FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onChanged;
  final String Function(int) fmt;
  const FeaturedCard({
    super.key,
    required this.product,
    required this.onChanged,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = 'featured_prod_${product.id}';
    return AnimatedPressCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(product: product, heroTag: heroTag),
        ),
      ),
      child: Container(
        height: 135,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.green700, AppColors.green500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.white.withAlpha(38),
                      child: Hero(
                        tag: heroTag,
                        child: Image.network(
                          '${AppConfig.webBaseUrl}/gambar/produk/${product.image.split('/').last}',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🔥 Terlaris',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          fmt(product.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              product.stock > 0
                                  ? 'Stok: ${product.stock}'
                                  : 'Habis',
                              style: TextStyle(
                                color: product.stock > 0
                                    ? Colors.white.withAlpha(230)
                                    : Colors.red[100],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '|  ${product.salesCount} terjual',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(204),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
