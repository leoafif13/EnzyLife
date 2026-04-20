import 'package:flutter/material.dart';
import 'app_color.dart';
import 'widgets/sub_page_appbar.dart';
import 'belanja_page.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Daftar produk untuk lookup harga dan nama
  // TODO: idealnya diambil dari satu sumber data terpusat
  static const _products = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: '', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: '', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: '', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: '', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: '', price: 500000),
  ];

  static Product? _findProduct(String id) {
    try { return _products.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  static String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  @override
  void initState() {
    super.initState();
    CartState.instance.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    CartState.instance.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart  = CartState.instance;
    final items = cart.items;

    int total = 0;
    for (final entry in items.entries) {
      final p = _findProduct(entry.key);
      if (p != null) total += p.price * entry.value;
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Keranjang',
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Kosongkan keranjang?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  content: const Text('Semua produk di keranjang akan dihapus.',
                      style: TextStyle(fontSize: 13)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal')),
                    TextButton(
                      onPressed: () { cart.clear(); Navigator.of(context).pop(); },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              child: const Text('Hapus semua',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: items.entries.map((e) {
                      final p = _findProduct(e.key);
                      if (p == null) return const SizedBox.shrink();
                      return _CartItem(
                        product: p, qty: e.value, fmtPrice: _fmt,
                        onAdd:    () => cart.add(p.id),
                        onRemove: () => cart.remove(p.id),
                      );
                    }).toList(),
                  ),
                ),
                // Summary + checkout
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08),
                          blurRadius: 12, offset: const Offset(0, -2))
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${cart.totalItems} produk',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          Text(_fmt(total),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                                  color: AppColors.text1)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: navigasi ke halaman checkout / pembayaran
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur checkout segera hadir!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green500,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Checkout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Cart item ─────────────────────────────────
class _CartItem extends StatelessWidget {
  final Product product;
  final int qty;
  final String Function(int) fmtPrice;
  final VoidCallback onAdd, onRemove;

  const _CartItem({
    required this.product, required this.qty,
    required this.fmtPrice, required this.onAdd, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Container(
                width: 68, height: 68, color: AppColors.green50,
                child: Icon(Icons.image_outlined, size: 24,
                    color: AppColors.green500.withOpacity(0.3)),
                // TODO: ganti dengan Image.network(url) / Image.asset(path)
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.text1)),
                  const SizedBox(height: 4),
                  Text(fmtPrice(product.price),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.green500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal: ${fmtPrice(product.price * qty)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      _QtyControl(qty: qty, onAdd: onAdd, onRemove: onRemove),
                    ],
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

// ── Qty control ───────────────────────────────
class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _QtyControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.green500),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Icon(Icons.remove, size: 14, color: AppColors.green500),
            ),
          ),
          Text('$qty',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.green500)),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Icon(Icons.add, size: 14, color: AppColors.green500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96, height: 96,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 44, color: AppColors.green500),
          ),
          const SizedBox(height: 20),
          const Text('Keranjang kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 8),
          Text('Tambahkan produk dari halaman belanja',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green500,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}