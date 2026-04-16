import 'package:flutter/material.dart';
import 'belanja_page.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);

  // Lookup produk dari id
  static const _products = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
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

    // Hitung total
    int total = 0;
    for (final entry in items.entries) {
      final p = _findProduct(entry.key);
      if (p != null) total += p.price * entry.value;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Keranjang',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        centerTitle: true,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Kosongkan keranjang?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: const Text('Semua produk di keranjang akan dihapus.', style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                      TextButton(
                        onPressed: () { cart.clear(); Navigator.of(context).pop(); },
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Hapus semua', style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: items.entries.map((e) {
                      final p = _findProduct(e.key);
                      if (p == null) return const SizedBox.shrink();
                      return _CartItem(
                        product: p,
                        qty: e.value,
                        fmtPrice: _fmt,
                        onAdd: () { cart.add(p.id); },
                        onRemove: () { cart.remove(p.id); },
                      );
                    }).toList(),
                  ),
                ),

                // Summary + checkout
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${cart.totalItems} produk', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          Text(_fmt(total),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
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
                            backgroundColor: _green500,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

//  Cart item row
class _CartItem extends StatelessWidget {
  final Product product;
  final int qty;
  final String Function(int) fmtPrice;
  final VoidCallback onAdd, onRemove;

  const _CartItem({
    required this.product, required this.qty,
    required this.fmtPrice, required this.onAdd, required this.onRemove,
  });

  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68, height: 68, color: _green50,
                child: Icon(Icons.image_outlined, size: 24, color: _green500.withOpacity(0.3)),
                // TODO: ganti dengan gambar produk
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text(fmtPrice(product.price),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal: ${fmtPrice(product.price * qty)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      // Qty control
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: _green500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: onRemove,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child: Icon(Icons.remove, size: 14, color: _green500),
                              ),
                            ),
                            Text('$qty', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green500)),
                            GestureDetector(
                              onTap: onAdd,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                child: Icon(Icons.add, size: 14, color: _green500),
                              ),
                            ),
                          ],
                        ),
                      ),
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

//  Empty cart state
class _EmptyCart extends StatelessWidget {
  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96, height: 96,
            decoration: const BoxDecoration(color: _green50, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 44, color: _green500),
          ),
          const SizedBox(height: 20),
          const Text('Keranjang kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text('Tambahkan produk dari halaman belanja',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green500,
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