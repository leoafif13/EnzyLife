import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../app_color.dart';
// import 'shopping_cart.dart';
import 'detail_produk_page.dart';
import '../services/api_service.dart';
import 'checkout_page.dart';
import '../models/product.dart';
import '../widgets/purchase_bottom_sheet.dart';
import '../services/format_helper.dart';

// ══════════════════════════════════════════════
//  CartState — singleton ChangeNotifier
// ══════════════════════════════════════════════
class CartState extends ChangeNotifier {
  static final CartState instance = CartState._();
  CartState._();

  final Map<int, int> _items = {};
  Map<int, int> get items     => Map.unmodifiable(_items);
  int get totalItems             => _items.values.fold(0, (a, b) => a + b);

  // Load cart items for a specific logged-in user
  Future<void> loadCartForUser() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final userId = user['id']?.toString() ?? user['email'];
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        final cartString = prefs.getString('cart_items_$userId');
        _items.clear();
        if (cartString != null) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(cartString);
            decoded.forEach((key, value) {
              final id = int.tryParse(key);
              final qty = value as int?;
              if (id != null && qty != null) {
                _items[id] = qty;
              }
            });
          } catch (e) {
            debugPrint('Error loading cart for user: $e');
          }
        }
        notifyListeners();
      }
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  // Save cart items for the currently logged-in user
  Future<void> _saveCartToPrefs() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final userId = user['id']?.toString() ?? user['email'];
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        final stringMap = _items.map((key, value) => MapEntry(key.toString(), value));
        await prefs.setString('cart_items_$userId', jsonEncode(stringMap));
      }
    }
  }

  void add(int id) {
    _items[id] = (_items[id] ?? 0) + 1;
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeOne(int id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]! - 1;
      if (_items[id]! <= 0) _items.remove(id);
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  // Hapus seluruh produk dari keranjang (untuk swipe delete)
  void removeAll(int id) {
    _items.remove(id);
    _saveCartToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }

  void clearMemoryOnly() {
    _items.clear();
    notifyListeners();
  }

  int qty(int id) => _items[id] ?? 0;

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

  List<Product> _products = [];
  bool _isLoading = true;
  String _sortBy = 'sales'; // 'sales' or 'price'
  String _sortOrder = 'desc'; // 'asc' or 'desc'

  int _page = 1;
  final int _perPage = 6;
  bool _hasMore = true;
  bool _isLoadMoreRunning = false;
  final ScrollController _scrollController = ScrollController();

  late final PageController _pageController;
  Timer? _carouselTimer;
  int _currentCarouselIndex = 0;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    'Filter & Urutkan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Urutkan Berdasarkan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFilterChip(
                        label: 'Jumlah Dibeli',
                        selected: _sortBy == 'sales',
                        onTap: () {
                          setStateSheet(() => _sortBy = 'sales');
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Harga',
                        selected: _sortBy == 'price',
                        onTap: () {
                          setStateSheet(() => _sortBy = 'price');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Arah Urutan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFilterChip(
                        label: 'Terendah',
                        selected: _sortOrder == 'asc',
                        onTap: () {
                          setStateSheet(() => _sortOrder = 'asc');
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                        label: 'Tertinggi',
                        selected: _sortOrder == 'desc',
                        onTap: () {
                          setStateSheet(() => _sortOrder = 'desc');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        fetchProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green50 : AppColors.bgPage,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green500 : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.green900 : AppColors.text2,
          ),
        ),
      ),
    );
  }

  static String _fmt(int price) => formatPrice(price);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93, keepPage: true);
    CartState.instance.addListener(_refresh);
    _scrollController.addListener(_loadMore);

    fetchProducts();
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final popularList = _getPopularProducts();
      if (popularList.isEmpty) return;

      int nextPage = _currentCarouselIndex + 1;
      if (nextPage >= popularList.length) {
        nextPage = 0;
      }
      
      _currentCarouselIndex = nextPage;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Product> _getPopularProducts() {
    final popular = _products.where((p) => p.isPopular).take(3).toList();
    if (popular.isEmpty && _products.isNotEmpty) {
      return _products.take(3).toList();
    }
    return popular;
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
    });

    try {
      final res = await ApiService.getProductsPaginated(
        page: _page,
        perPage: _perPage,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        search: _query,
      );

      final products = res['products'] as List<Product>;
      final lastPage = res['last_page'] as int;

      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
        if (_page >= lastPage) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadMoreRunning || !_hasMore) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      setState(() => _isLoadMoreRunning = true);
      _page++;

      try {
        final res = await ApiService.getProductsPaginated(
          page: _page,
          perPage: _perPage,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          search: _query,
        );

        final newProducts = res['products'] as List<Product>;
        final lastPage = res['last_page'] as int;

        if (!mounted) return;
        setState(() {
          if (newProducts.isNotEmpty) {
            _products.addAll(newProducts);
          } else {
            _hasMore = false;
          }
          if (_page >= lastPage) {
            _hasMore = false;
          }
          _isLoadMoreRunning = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoadMoreRunning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    CartState.instance.removeListener(_refresh);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final cart = CartState.instance;

    // ambil produk pertama jadi featured
    final popular = _products.isNotEmpty
        ? _products.first
        : null;

    final listProds = _products.where(
      (p) => _query.isNotEmpty || !p.isPopular,
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card (Hero Banner)
            Container(
              color: AppColors.bgPage,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.green900, AppColors.green700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.heroShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '🛍️  Eco Shop',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Belanja Eco Enzim',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Temukan produk eco enzyme ramah lingkungan terbaik untuk kebutuhan pembersih alami, pupuk, dan kesehatan Anda.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            Container(
              color: AppColors.bgPage,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() {
                          _query = v;
                          _page = 1;
                          _hasMore = true;
                        });
                        fetchProducts();
                      },
                      style: const TextStyle(fontSize: 14, color: AppColors.text1),
                      decoration: InputDecoration(
                        hintText: 'Cari produk eco enzim..',
                        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.hint, size: 20),
                        filled: true,
                        fillColor: AppColors.bgCard,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.green50, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.tune_rounded, color: AppColors.green500, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Popular carousel
            if (_getPopularProducts().isNotEmpty && _query.isEmpty) ...[
              SizedBox(
                height: 135,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _getPopularProducts().length,
                  onPageChanged: (index) {
                    _currentCarouselIndex = index;
                    _startCarouselTimer();
                  },
                  itemBuilder: (context, index) {
                    final product = _getPopularProducts()[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _FeaturedCard(product: product, onChanged: _refresh, fmt: _fmt),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : listProds.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: AppColors.green50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 34,
                                  color: AppColors.green500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _query.isNotEmpty
                                    ? 'Produk "$_query" tidak ditemukan'
                                    : 'Belum ada produk tersedia',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _query.isNotEmpty
                                    ? 'Coba gunakan kata kunci lain'
                                    : 'Produk akan muncul di sini ketika tersedia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Column(
                          children: [
                            ...listProds
                                .map(
                                  (p) => _ProductCard(
                                    product: p,
                                    fmtPrice: _fmt,
                                    onChanged: _refresh,
                                  ),
                                )
                                .toList(),
                            if (_isLoadMoreRunning)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(color: AppColors.green500),
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

// ── Featured card ─────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onChanged;
  final String Function(int) fmt;
  const _FeaturedCard({required this.product, required this.onChanged, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        height: 135,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.green700, AppColors.green500],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
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
                      color: Colors.white.withOpacity(0.15),
                      child: Image.network(
                        'http://127.0.0.1:8000/gambar/produk/${product.image.split('/').last}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.image_not_supported, color: Colors.white);
                        },
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🔥 Terlaris',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
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
                              product.stock > 0 ? 'Stok: ${product.stock}' : 'Habis',
                              style: TextStyle(
                                color: product.stock > 0 ? Colors.white.withOpacity(0.9) : Colors.red[100],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '|  ${product.salesCount} terjual',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
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
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.network(
                    'http://127.0.0.1:8000/gambar/produk/${product.image.split('/').last}',
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.stock > 0 ? AppColors.green500 : Colors.red,
                          ),
                        ),
                        if (product.salesCount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '|  ${product.salesCount} terjual',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(fmtPrice(product.price),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.text1)),
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
                                        content: Text('Batas stok maksimum tercapai (${product.stock} item)'),
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
                                  builder: (_) => PurchaseBottomSheet(product: product),
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Habis',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red[700]),
                                ),
                              )
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