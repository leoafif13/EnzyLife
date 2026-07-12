import 'package:flutter/material.dart';
import '../models/product.dart';
import '../app_color.dart';
import 'belanja_page.dart';
import 'shopping_cart.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/purchase_bottom_sheet.dart';
import '../services/format_helper.dart';
import '../widgets/zoomable_image_dialog.dart';
import 'widgets/review_tile.dart';
import 'widgets/sentimen_ai_card.dart';
import 'widgets/spec_card.dart';
import '../services/api_service.dart';
import 'semua_ulasan_page.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String? heroTag;
  const ProductDetailScreen({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _carouselIndex = 0;
  final _pageController = PageController();
  int _qty = 1;

  bool _reviewsLoading = true;
  double _avgRating = 0.0;
  int _totalReviews = 0;
  double _positif = 0.0;
  double _netral = 0.0;
  double _negatif = 0.0;
  List<Review> _fetchedReviews = [];

  @override
  void initState() {
    super.initState();
    CartState.instance.addListener(_refreshBadge);
    if (widget.product.stock <= 0) {
      _qty = 0;
    }
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _reviewsLoading = true);
    final summary = await ApiService.getProductReviewSummary(widget.product.id);
    if (!mounted) return;
    if (summary != null) {
      final rawComments = summary['comments'] as Map<String, dynamic>? ?? {};
      final List<Review> allReviews = [];
      
      if (rawComments.containsKey('positif')) {
        final list = rawComments['positif'] as List? ?? [];
        allReviews.addAll(list.map((x) => Review.fromJson(Map<String, dynamic>.from(x), sentiment: 'positif')));
      }
      if (rawComments.containsKey('netral')) {
        final list = rawComments['netral'] as List? ?? [];
        allReviews.addAll(list.map((x) => Review.fromJson(Map<String, dynamic>.from(x), sentiment: 'netral')));
      }
      if (rawComments.containsKey('negatif')) {
        final list = rawComments['negatif'] as List? ?? [];
        allReviews.addAll(list.map((x) => Review.fromJson(Map<String, dynamic>.from(x), sentiment: 'negatif')));
      }

      setState(() {
        _avgRating = (summary['average_rating'] as num?)?.toDouble() ?? 0.0;
        _totalReviews = (summary['total_review'] as num?)?.toInt() ?? 0;
        _positif = ((summary['positif'] as num?)?.toDouble() ?? 0.0) / 100.0;
        _netral = ((summary['netral'] as num?)?.toDouble() ?? 0.0) / 100.0;
        _negatif = ((summary['negatif'] as num?)?.toDouble() ?? 0.0) / 100.0;
        _fetchedReviews = allReviews;
        _reviewsLoading = false;
      });
    } else {
      setState(() => _reviewsLoading = false);
    }
  }

  void _refreshBadge() => setState(() {});

  IconData _getSpecIcon(String key) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('vol') || lowerKey.contains('isi') || lowerKey.contains('ukuran')) {
      return Icons.opacity_rounded;
    } else if (lowerKey.contains('kemas') || lowerKey.contains('wadah')) {
      return Icons.inventory_2_rounded;
    } else if (lowerKey.contains('kadal') || lowerKey.contains('expired') || lowerKey.contains('exp') || lowerKey.contains('waktu') || lowerKey.contains('simpan')) {
      return Icons.calendar_today_rounded;
    } else if (lowerKey.contains('arom') || lowerKey.contains('bau') || lowerKey.contains('wangi')) {
      return Icons.local_florist_rounded;
    } else if (lowerKey.contains('bahan') || lowerKey.contains('komposisi')) {
      return Icons.science_rounded;
    } else if (lowerKey.contains('fermentasi') || lowerKey.contains('lama')) {
      return Icons.hourglass_empty_rounded;
    }
    return Icons.info_outline_rounded;
  }

  // Dummy gambar carousel (placeholder)
  static const _imageCount = 1;

  static String _fmt(int price) => formatPrice(price);

  void _addToCart() {
    final currentQty = CartState.instance.qty(widget.product.id);
    if (currentQty + _qty > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan. Total di keranjang melebihi stok (${widget.product.stock} item)'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    for (int i = 0; i < _qty; i++) {
      CartState.instance.add(widget.product.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_qty ${widget.product.name} ditambahkan ke keranjang'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    CartState.instance.removeListener(_refreshBadge);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartQty = CartState.instance.uniqueItems;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: p.name,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A1A1A), size: 22),
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cartQty > 0)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 15, height: 15,
                    decoration: const BoxDecoration(color: AppColors.green500, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$cartQty',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Carousel gambar produk ────────────────
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _imageCount,
                            onPageChanged: (i) => setState(() => _carouselIndex = i),
                            itemBuilder: (_, i) => Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: AppColors.green50,
                                  child: Hero(
                                    tag: widget.heroTag ?? 'http://127.0.0.1:8000/gambar/produk/${p.image.split('/').last}',
                                    child: Image.network(
                                      'http://127.0.0.1:8000/gambar/produk/${p.image.split('/').last}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                  )
                                ),

                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(217),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${i + 1}/$_imageCount',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      final imgUrl = 'http://127.0.0.1:8000/gambar/produk/${p.image.split('/').last}';
                                      openFullscreenImage(context, imgUrl, isNetwork: true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(140),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ),
                        ),
                        // Dot indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_imageCount, (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _carouselIndex == i ? 20 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _carouselIndex == i ? AppColors.green500 : const Color(0xFFDDDDDD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                          ),
                        ),
                        // Thumbnail strip
                        SizedBox(
                          height: 64,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageCount,
                            itemBuilder: (_, i) => GestureDetector(
                              onTap: () { _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); },
                              child: Container(
                                width: 48, height: 48,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.green50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _carouselIndex == i ? AppColors.green500 : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'http://127.0.0.1:8000/gambar/produk/${p.image.split('/').last}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(Icons.image_not_supported);
                                    },
                                  )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Info produk ───────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(p.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A), height: 1.2)),
                            ),
                            if (p.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.green50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Populer',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green500)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(_fmt(p.price),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.green500),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.stock > 0 ? AppColors.green50 : Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: p.stock > 0 ? AppColors.green200 : Colors.red[200]!),
                              ),
                              child: Text(
                                p.stock > 0 ? 'Stok: ${p.stock}' : 'Stok Habis',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: p.stock > 0 ? AppColors.green700 : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Rating ringkasan
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18, color: const Color(0xFFFFC107),
                            )),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text('${_avgRating.toStringAsFixed(1)} ($_totalReviews ulasan)',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),
                        const Text('Deskripsi Produk',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        Text(
                          p.description,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6),
                        ),
                        Builder(
                          builder: (context) {
                            final Map<String, dynamic> activeSpecs = {};
                            if (p.spesifikasi != null) {
                              p.spesifikasi!.forEach((key, val) {
                                if (val != null &&
                                    val.toString().trim().isNotEmpty &&
                                    val.toString().trim().toLowerCase() != 'null') {
                                  activeSpecs[key] = val;
                                }
                              });
                            }

                            if (activeSpecs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                                const SizedBox(height: 16),
                                const Text('Spesifikasi Produk',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                                const SizedBox(height: 12),
                                Column(
                                  children: List.generate(
                                    (activeSpecs.length / 2).ceil(),
                                    (index) {
                                      final i = index * 2;
                                      final key1 = activeSpecs.keys.elementAt(i);
                                      final val1 = activeSpecs[key1]?.toString() ?? '';

                                      final hasSecond = i + 1 < activeSpecs.length;
                                      final key2 = hasSecond ? activeSpecs.keys.elementAt(i + 1) : null;
                                      final val2 = hasSecond ? activeSpecs[key2]?.toString() ?? '' : '';

                                      return Padding(
                                        padding: EdgeInsets.only(bottom: index == (activeSpecs.length / 2).ceil() - 1 ? 0 : 10),
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: hasSecond
                                                ? [
                                                    Expanded(
                                                      child: SpecCard(
                                                        label: key1,
                                                        value: val1,
                                                        icon: _getSpecIcon(key1),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: SpecCard(
                                                        label: key2!,
                                                        value: val2,
                                                        icon: _getSpecIcon(key2),
                                                      ),
                                                    ),
                                                  ]
                                                : [
                                                    const Spacer(flex: 1),
                                                    Expanded(
                                                      flex: 2,
                                                      child: SpecCard(
                                                        label: key1,
                                                        value: val1,
                                                        icon: _getSpecIcon(key1),
                                                      ),
                                                    ),
                                                    const Spacer(flex: 1),
                                                  ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),



                  // ── Ulasan ────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ulasan Pembeli',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SemuaUlasanScreen(reviews: _fetchedReviews),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(foregroundColor: AppColors.green500, padding: EdgeInsets.zero,
                                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Lihat semua', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (_reviewsLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: CircularProgressIndicator(color: AppColors.green500),
                            ),
                          )
                        else ...[
                          // ── Sentimen AI ─────────────────
                          SentimenAI(
                            positif: _positif,
                            netral: _netral,
                            negatif: _negatif,
                            totalReviews: _totalReviews,
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 14),

                          // Ringkasan rating
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(_avgRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.green500)),
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 14, color: const Color(0xFFFFC107),
                                    )),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$_totalReviews ulasan',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: List.generate(5, (i) {
                                    final star = 5 - i;
                                    final count = _fetchedReviews.where((r) => r.rating == star).length;
                                    final pct = _fetchedReviews.isEmpty ? 0.0 : count / _fetchedReviews.length;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Text('$star', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFC107)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: pct,
                                                backgroundColor: const Color(0xFFF0F0F0),
                                                valueColor: const AlwaysStoppedAnimation(AppColors.green500),
                                                minHeight: 6,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text('$count', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                          if (_fetchedReviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Belum ada ulasan untuk produk ini',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ..._fetchedReviews.take(5).map((r) => ReviewTile(review: r)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Bottom bar: total + add to cart ───────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 12, offset: const Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    Text(_fmt(p.price * _qty),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                  ],
                ),
                const SizedBox(width: 16),
                // Tombol keranjang
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: p.stock > 0 ? _addToCart : null,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: const Text('Keranjang', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: p.stock > 0 ? AppColors.green500 : Colors.grey[300]!, width: 1.5),
                      foregroundColor: p.stock > 0 ? AppColors.green500 : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Tombol beli sekarang → modal bottom sheet
                Expanded(
                  child: ElevatedButton(
                    onPressed: p.stock > 0
                        ? () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PurchaseBottomSheet(
                                product: p,
                                initialQty: _qty,
                              ),
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: p.stock > 0 ? AppColors.green500 : Colors.grey[300],
                      foregroundColor: p.stock > 0 ? Colors.white : Colors.grey[500],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(p.stock > 0 ? 'Beli Sekarang' : 'Stok Habis', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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

