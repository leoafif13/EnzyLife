import 'package:flutter/material.dart';
import 'belanja_page.dart';
import 'shopping_cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _carouselIndex = 0;
  final _pageController = PageController();
  int _qty = 1;

  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);
  static const _grey600  = Color(0xFF757575);

  // Dummy gambar carousel (placeholder)
  static const _imageCount = 3;

  // Dummy ulasan
  static const _reviews = [
    _Review(name: 'Siti Rahma',    rating: 5, comment: 'Produknya bagus sekali, aroma segar dan terasa manfaatnya untuk tanaman saya!', date: '2 hari lalu'),
    _Review(name: 'Budi Santoso',  rating: 4, comment: 'Kualitas oke, pengiriman cepat. Akan beli lagi.', date: '1 minggu lalu'),
    _Review(name: 'Dewi Lestari',  rating: 5, comment: 'Sudah pakai beberapa kali, hasilnya luar biasa untuk pupuk organik.', date: '2 minggu lalu'),
  ];

  static String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  double get _avgRating => _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

  void _addToCart() {
    for (int i = 0; i < _qty; i++) {
      CartState.instance.add(widget.product.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_qty ${widget.product.name} ditambahkan ke keranjang'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _green500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartQty = CartState.instance.qty(p.id);

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
        title: Text(p.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        centerTitle: true,
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
                    decoration: const BoxDecoration(color: _green500, shape: BoxShape.circle),
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
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _imageCount,
                            onPageChanged: (i) => setState(() => _carouselIndex = i),
                            itemBuilder: (_, i) => Container(
                              margin: const EdgeInsets.all(0),
                              color: _green50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // TODO: ganti dengan Image.network/asset per indeks
                                  Icon(Icons.image_outlined, size: 64, color: _green500.withOpacity(0.2)),
                                  Positioned(
                                    top: 12, right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${i + 1}/$_imageCount',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
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
                                color: _carouselIndex == i ? _green500 : const Color(0xFFDDDDDD),
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
                                  color: _green50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _carouselIndex == i ? _green500 : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(Icons.image_outlined, size: 20, color: _green500.withOpacity(0.3)),
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
                                  color: _green50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Populer',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green500)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(_fmt(p.price),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _green500)),
                        const SizedBox(height: 12),
                        // Rating ringkasan
                        Row(
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 18, color: const Color(0xFFFFC107),
                            )),
                            const SizedBox(width: 6),
                            Text('${_avgRating.toStringAsFixed(1)} (${_reviews.length} ulasan)',
                                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 16),
                        const Text('Deskripsi Produk',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        Text(
                          // TODO: ganti dengan deskripsi lengkap produk
                          '${p.description}. Produk eco enzim berkualitas tinggi yang ramah lingkungan dan bermanfaat untuk berbagai keperluan rumah tangga maupun pertanian.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        // Spesifikasi
                        const Text('Spesifikasi',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 10),
                        _SpecRow(label: 'Volume',    value: '1 Liter'),    // TODO
                        _SpecRow(label: 'Kemasan',   value: 'Botol HDPE'), // TODO
                        _SpecRow(label: 'Expired',   value: '2 Tahun'),    // TODO
                        _SpecRow(label: 'Sertifikat',value: 'Organik'),    // TODO
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Qty selector ──────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        const Text('Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _green500),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () { if (_qty > 1) setState(() => _qty--); },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Icon(Icons.remove, size: 16,
                                      color: _qty > 1 ? _green500 : Colors.grey[300]),
                                ),
                              ),
                              Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _green500)),
                              GestureDetector(
                                onTap: () => setState(() => _qty++),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Icon(Icons.add, size: 16, color: _green500),
                                ),
                              ),
                            ],
                          ),
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
                              onPressed: () {},
                              style: TextButton.styleFrom(foregroundColor: _green500, padding: EdgeInsets.zero,
                                  minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text('Lihat semua', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Ringkasan rating
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(_avgRating.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: _green500)),
                                Row(
                                  children: List.generate(5, (i) => Icon(
                                    i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 14, color: const Color(0xFFFFC107),
                                  )),
                                ),
                                const SizedBox(height: 4),
                                Text('${_reviews.length} ulasan',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: List.generate(5, (i) {
                                  final star = 5 - i;
                                  final count = _reviews.where((r) => r.rating == star).length;
                                  final pct = _reviews.isEmpty ? 0.0 : count / _reviews.length;
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
                                              valueColor: const AlwaysStoppedAnimation(_green500),
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
                        ..._reviews.map((r) => _ReviewTile(review: r)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addToCart,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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

// ── Spesifikasi row ──────────────────────────
class _SpecRow extends StatelessWidget {
  final String label, value;
  const _SpecRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
        const Text(': ', style: TextStyle(color: Color(0xFFDDDDDD))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
      ],
    ),
  );
}

// ── Model review ─────────────────────────────
class _Review {
  final String name, comment, date;
  final int rating;
  const _Review({required this.name, required this.rating, required this.comment, required this.date});
}

// ── Review tile ──────────────────────────────
class _ReviewTile extends StatelessWidget {
  final _Review review;
  const _ReviewTile({super.key, required this.review});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(review.name[0], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 12, color: const Color(0xFFFFC107),
                    )),
                    const SizedBox(width: 6),
                    Text(review.date, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5)),
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
      ],
    ),
  );
}