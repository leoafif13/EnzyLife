import 'package:flutter/material.dart';
import 'app_color.dart';
import 'shopping_cart.dart';
import 'detail_produk.dart';
import 'checkout_page.dart';

// ══════════════════════════════════════════════
//  Model produk
// ══════════════════════════════════════════════
class Product {
  final String id, name, description;
  final int price;
  final bool isPopular;
  const Product({
    required this.id, required this.name,
    required this.description, required this.price,
    this.isPopular = false,
  });
}

// ══════════════════════════════════════════════
//  CartState — singleton ChangeNotifier
// ══════════════════════════════════════════════
class CartState extends ChangeNotifier {
  static final CartState instance = CartState._();
  CartState._();

  final Map<String, int> _items = {};
  Map<String, int> get items     => Map.unmodifiable(_items);
  int get totalItems             => _items.values.fold(0, (a, b) => a + b);

  void add(String id) {
    _items[id] = (_items[id] ?? 0) + 1;
    notifyListeners();
  }

  void removeOne(String id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]! - 1;
      if (_items[id]! <= 0) _items.remove(id);
      notifyListeners();
    }
  }

  // Hapus seluruh produk dari keranjang (untuk swipe delete)
  void removeAll(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() { _items.clear(); notifyListeners(); }
  int qty(String id) => _items[id] ?? 0;

  // Jumlah ID unik (untuk badge — kaya Shopee)
  int get uniqueItems => _items.length;
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

  // TODO: ganti dengan data dari API/database
  static const _products = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
  ];

  List<Product> get _filtered => _products.where((p) =>
    p.name.toLowerCase().contains(_query.toLowerCase()) ||
    p.description.toLowerCase().contains(_query.toLowerCase())).toList();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart     = CartState.instance;
    final popular  = _products.where((p) => p.isPopular).isNotEmpty
                     ? _products.firstWhere((p) => p.isPopular) : null;
    final listProds = _filtered.where((p) => _query.isNotEmpty || !p.isPopular).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              color: AppColors.bgCard,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 14, color: AppColors.text1),
                      decoration: InputDecoration(
                        hintText: 'Cari produk eco enzim..',
                        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint, size: 20),
                        filled: true,
                        fillColor: AppColors.bgPage,
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
                    decoration: BoxDecoration(
                        color: AppColors.green50, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune_rounded, color: AppColors.green500, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Featured card
            if (popular != null && _query.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FeaturedCard(product: popular, onChanged: _refresh, fmt: _fmt),
              ),
              const SizedBox(height: 16),
            ],

            // Product list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: listProds
                    .map((p) => _ProductCard(product: p, fmtPrice: _fmt, onChanged: _refresh))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured card ─────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onChanged;
  final String Function(int) fmt;
  const _FeaturedCard({required this.product, required this.onChanged, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap card → detail produk
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.green900, AppColors.green700],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.heroShadow,
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
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('Populer',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 10),
                        Text(product.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20,
                                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text(product.description,
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12, height: 1.4)),
                        const SizedBox(height: 14),
                        // Tombol Beli → checkout langsung
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CheckoutPage(
                                items: {product.id: 1},
                                allProducts: const [
                                  Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
                                  Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
                                  Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
                                  Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
                                  Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
                                ],
                              ))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, foregroundColor: AppColors.green900,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Beli Sekarang',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
      ),
    );
  }
}

// ── Product card ──────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final String Function(int) fmtPrice;
  final VoidCallback onChanged;
  const _ProductCard({required this.product, required this.fmtPrice, required this.onChanged});

  static const _allProducts = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = CartState.instance;
    final qty  = cart.qty(product.id);

    return GestureDetector(
      // Tap card → detail produk
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
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
                child: Container(
                  width: 80, height: 80, color: AppColors.green50,
                  child: Icon(Icons.image_outlined, size: 28,
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
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.text1)),
                    const SizedBox(height: 4),
                    Text(product.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(fmtPrice(product.price),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.text1)),
                        Row(
                          children: [
                            // Tombol keranjang
                            _IconBtn(
                              icon: Icons.shopping_cart_outlined,
                              onTap: () { cart.add(product.id); onChanged(); },
                            ),
                            const SizedBox(width: 8),
                            // Tombol Beli → checkout langsung
                            _SmallBtn(
                              label: 'Beli',
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => CheckoutPage(
                                    items: {product.id: 1},
                                    allProducts: _allProducts,
                                  ))),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Badge qty di keranjang
                    if (qty > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined,
                              size: 11, color: AppColors.green500),
                          const SizedBox(width: 3),
                          Text('$qty item di keranjang',
                              style: const TextStyle(fontSize: 10,
                                  color: AppColors.green500, fontWeight: FontWeight.w500)),
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
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green200),
      ),
      child: const Icon(Icons.shopping_cart_outlined, size: 16, color: AppColors.green500),
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
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    ),
  );
}