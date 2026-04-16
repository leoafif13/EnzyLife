import 'package:flutter/material.dart';
import 'shopping_cart.dart';
import 'detail_produk.dart';

// ══════════════════════════════════════════════
//  Model produk
// ══════════════════════════════════════════════
class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final bool isPopular;
  const Product({required this.id, required this.name, required this.description, required this.price, this.isPopular = false});
}

// ══════════════════════════════════════════════
//  CartState — singleton ChangeNotifier
//  bisa diakses dari BelanjaScreen & CartScreen
// ══════════════════════════════════════════════
class CartState extends ChangeNotifier {
  static final CartState instance = CartState._();
  CartState._();

  final Map<String, int> _items = {};
  Map<String, int> get items => Map.unmodifiable(_items);
  int get totalItems => _items.values.fold(0, (a, b) => a + b);

  void add(String id)    { _items[id] = (_items[id] ?? 0) + 1; notifyListeners(); }
  void remove(String id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]! - 1;
      if (_items[id]! <= 0) _items.remove(id);
      notifyListeners();
    }
  }
  void clear() { _items.clear(); notifyListeners(); }
  int qty(String id) => _items[id] ?? 0;
}

// ══════════════════════════════════════════════
//  BelanjaScreen
// ══════════════════════════════════════════════
class BelanjaScreen extends StatefulWidget {
  const BelanjaScreen({super.key});
  @override
  State<BelanjaScreen> createState() => _BelanjaScreenState();
}

class _BelanjaScreenState extends State<BelanjaScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);

  // TODO: ganti dengan data dari API/database
  static const _products = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
  ];

  List<Product> get _filtered => _products
      .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()) ||
                    p.description.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    CartState.instance.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    CartState.instance.removeListener(_refresh);
    _searchController.dispose();
    super.dispose();
  }

  void _openCart() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()))
        .then((_) => setState(() {}));
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
  Widget build(BuildContext context) {
    final cart     = CartState.instance;
    final popular  = _products.where((p) => p.isPopular).isNotEmpty
                     ? _products.firstWhere((p) => p.isPopular) : null;
    final listProds = _filtered.where((p) => _query.isNotEmpty || !p.isPopular).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari produk eco enzim..',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFBDBDBD), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune_rounded, color: _green500, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Featured card
            if (popular != null && _query.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FeaturedCard(product: popular, onChanged: _refresh),
              ),
              const SizedBox(height: 16),
            ],

            // Product list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: listProds.map((p) => _ProductCard(product: p, fmtPrice: _fmt, onChanged: _refresh)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Featured card (produk populer)
// ══════════════════════════════════════════════
class _FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onChanged;
  const _FeaturedCard({required this.product, required this.onChanged});

  static const _green900 = Color(0xFF1B5E20);
  static const _green700 = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_green900, _green700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _green900.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Container(width: 120, height: 120,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle))),
          Positioned(right: 20, bottom: -30, child: Container(width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Populer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 10),
                      Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(product.description, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, height: 1.4)),
                      const SizedBox(height: 14),
                      Builder(
                        builder: (ctx) => ElevatedButton(
                        onPressed: () { Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, foregroundColor: _green900, elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Lihat Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 90, height: 90,
                    color: Colors.white.withOpacity(0.15),
                    child: const Icon(Icons.image_outlined, size: 36, color: Colors.white38),
                    // TODO: ganti dengan Image.network(url) / Image.asset(path)
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

// ══════════════════════════════════════════════
//  Product card
// ══════════════════════════════════════════════
class _ProductCard extends StatelessWidget {
  final Product product;
  final String Function(int) fmtPrice;
  final VoidCallback onChanged;
  const _ProductCard({required this.product, required this.fmtPrice, required this.onChanged});

  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final cart = CartState.instance;
    final qty  = cart.qty(product.id);

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
                width: 80, height: 80, color: _green50,
                child: Icon(Icons.image_outlined, size: 28, color: _green500.withOpacity(0.3)),
                // TODO: ganti dengan Image.network(url) / Image.asset(path)
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 13, color: Color(0xFF4CAF50)),
                          const SizedBox(width: 4),
                          Text(fmtPrice(product.price),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        ],
                      ),
                      Row(
                        children: [
                          _Btn(label: 'Detail', outlined: true, onTap: () { Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))); }),
                          const SizedBox(width: 6),
                          if (qty == 0)
                            _Btn(label: 'Beli', onTap: () { cart.add(product.id); onChanged(); })
                          else
                            _QtyRow(qty: qty,
                              onAdd: () { cart.add(product.id); onChanged(); },
                              onRemove: () { cart.remove(product.id); onChanged(); }),
                        ],
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

class _Btn extends StatelessWidget {
  final String label;
  final bool outlined;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap, this.outlined = false});
  static const _green500 = Color(0xFF4CAF50);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : _green500,
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: _green500) : null,
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: outlined ? _green500 : Colors.white)),
    ),
  );
}

class _QtyRow extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _QtyRow({required this.qty, required this.onAdd, required this.onRemove});
  static const _green500 = Color(0xFF4CAF50);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(border: Border.all(color: _green500), borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        GestureDetector(onTap: onRemove, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Icon(Icons.remove, size: 14, color: _green500))),
        Text('$qty', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green500)),
        GestureDetector(onTap: onAdd, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Icon(Icons.add, size: 14, color: _green500))),
      ],
    ),
  );
}