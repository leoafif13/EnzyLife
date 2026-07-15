import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../app_color.dart';
import '../../models/product.dart';
import '../detail_produk_page.dart';
import 'qty_control.dart';

class CartItemTile extends StatelessWidget {
  final Product product;
  final int qty;
  final bool checked;
  final String Function(int) fmtPrice;
  final ValueChanged<bool?> onToggleCheck;
  final VoidCallback onAdd, onRemove, onDelete;

  const CartItemTile({
    super.key,
    required this.product,
    required this.qty,
    required this.checked,
    required this.fmtPrice,
    required this.onToggleCheck,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Hapus',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
            border: Border.all(
              color: checked ? AppColors.green500.withAlpha(120) : AppColors.border.withAlpha(80),
              width: checked ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: checked,
                    onChanged: onToggleCheck,
                    activeColor: AppColors.green500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                ),
                const SizedBox(width: 10),

                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${AppConfig.webBaseUrl}/gambar/produk/${product.image.split('/').last}',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 64,
                        height: 64,
                        color: AppColors.green50,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Info produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmtPrice(product.price),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Subtotal
                          Flexible(
                            child: Text(
                              'Subtotal: ${fmtPrice(product.price * qty)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Qty control
                          QtyControl(qty: qty, onAdd: onAdd, onRemove: onRemove),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
