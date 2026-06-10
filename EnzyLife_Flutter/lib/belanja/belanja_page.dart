import 'package:flutter/material.dart';
import 'dart:async';
import '../app_color.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../services/format_helper.dart';
import '../state/cart_state.dart';
import 'widgets/featured_card.dart';
import 'widgets/product_card.dart';

export '../state/cart_state.dart';

// Note: CartState has been moved to lib/state/cart_state.dart

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
  String _sortBy = 'default'; // 'default', 'sales', or 'price'
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Default',
                          selected: _sortBy == 'default',
                          onTap: () {
                            setStateSheet(() => _sortBy = 'default');
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildFilterChip(
                          label: 'Terlaris',
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
    final listProds = _products.where(
      (p) => _query.isNotEmpty || !p.isPopular,
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header card (Hero Banner)
          SliverToBoxAdapter(
            child: Container(
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
                              color: Colors.white.withAlpha(38),
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
                              color: Colors.white.withAlpha(204),
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
                        color: Colors.white.withAlpha(38),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pinned Search bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchBarDelegate(
              child: Container(
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
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          child: FeaturedCard(product: product, onChanged: _refresh, fmt: _fmt),
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
                                ...listProds.map(
                                  (p) => ProductCard(
                                    product: p,
                                    fmtPrice: _fmt,
                                    onChanged: _refresh,
                                  ),
                                ),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}






// ── Sticky Search Bar Delegate ────────────────
class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickySearchBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bgPage,
      child: child,
    );
  }

  @override
  double get maxExtent => 76.0;

  @override
  double get minExtent => 76.0;

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}