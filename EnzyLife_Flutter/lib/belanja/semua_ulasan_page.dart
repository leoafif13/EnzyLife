import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import 'widgets/review_tile.dart';

class SemuaUlasanScreen extends StatefulWidget {
  final List<Review> reviews;
  const SemuaUlasanScreen({super.key, required this.reviews});

  @override
  State<SemuaUlasanScreen> createState() => _SemuaUlasanScreenState();
}

class _SemuaUlasanScreenState extends State<SemuaUlasanScreen> {
  // ── Filter state ────────────────────────────────────────────
  // null = tidak ada filter aktif (tampil semua)
  String? _selectedSentiment;
  int? _selectedRating;
  bool _sortByNewest = true;

  // ── Paginasi ─────────────────────────────────────────────────
  static const int _pageSize = 10;
  int _visibleCount = _pageSize;
  final ScrollController _scrollController = ScrollController();

  // Mapping sentimen → label tampilan
  static const Map<String, String> _sentimentLabels = {
    'positif': 'Aroma Disukai',
    'netral': 'Aroma Biasa',
    'negatif': 'Kurang Disukai',
  };

  static const Map<String, IconData> _sentimentIcons = {
    'positif': Icons.local_florist_rounded,
    'netral': Icons.spa_rounded,
    'negatif': Icons.sentiment_dissatisfied_rounded,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more saat mendekati ujung bawah list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final total = _allFilteredReviews.length;
      if (_visibleCount < total) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(0, total);
        });
      }
    }
  }

  // ── Parse tanggal ─────────────────────────────────────────────
  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return DateTime(1970);
  }

  // ── Semua ulasan setelah filter & sort ───────────────────────
  List<Review> get _allFilteredReviews {
    final list = widget.reviews.where((r) {
      // Filter sentimen — jika null, tidak difilter
      if (_selectedSentiment != null && r.sentiment != _selectedSentiment) {
        return false;
      }
      // Filter rating — jika null, tidak difilter
      if (_selectedRating != null && r.rating != _selectedRating) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      final aDate = _parseDate(a.date);
      final bDate = _parseDate(b.date);
      return _sortByNewest ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });

    return list;
  }

  // ── Halaman yang ditampilkan (paginasi) ──────────────────────
  List<Review> get _visibleReviews {
    final all = _allFilteredReviews;
    return all.take(_visibleCount).toList();
  }

  // ── Reset paginasi saat filter berubah ───────────────────────
  void _resetPagination() {
    setState(() => _visibleCount = _pageSize);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  int _getSentimentCount(String sentiment) =>
      widget.reviews.where((r) => r.sentiment == sentiment).length;

  int _getRatingCount(int rating) =>
      widget.reviews.where((r) => r.rating == rating).length;

  // ── Widget chip sentimen ─────────────────────────────────────
  Widget _buildSentimentChip(String sentiment) {
    final isSelected = _selectedSentiment == sentiment;
    final count = _getSentimentCount(sentiment);
    final label = _sentimentLabels[sentiment] ?? sentiment;
    final icon = _sentimentIcons[sentiment] ?? Icons.sentiment_neutral_rounded;

    return GestureDetector(
      onTap: () {
        _resetPagination();
        setState(() {
          // Toggle: klik lagi = hapus filter
          _selectedSentiment = isSelected ? null : sentiment;
          _selectedRating = null; // reset rating saat pilih sentimen
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green500 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green500 : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.green500.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.text2),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.text1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget chip rating ────────────────────────────────────────
  Widget _buildRatingChip(int star) {
    final isSelected = _selectedRating == star;
    final count = _getRatingCount(star);

    return GestureDetector(
      onTap: () {
        _resetPagination();
        setState(() {
          // Toggle: klik lagi = hapus filter
          _selectedRating = isSelected ? null : star;
          _selectedSentiment = null; // reset sentimen saat pilih rating
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green500 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green500 : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$star',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.text1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFFFC107)),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleReviews;
    final total = _allFilteredReviews.length;
    final hasMore = _visibleCount < total;
    final isFiltered = _selectedSentiment != null || _selectedRating != null;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Semua Ulasan'),
      body: Column(
        children: [
          // ── Panel filter ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris judul + tombol sort + tombol reset
                Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Filter Ulasan',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Tombol reset filter (hanya muncul saat ada filter aktif)
                    if (isFiltered)
                      GestureDetector(
                        onTap: () {
                          _resetPagination();
                          setState(() {
                            _selectedSentiment = null;
                            _selectedRating = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.green50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.green200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.close_rounded,
                                  size: 12, color: AppColors.green500),
                              SizedBox(width: 4),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.green500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Tombol urutan
                    GestureDetector(
                      onTap: () {
                        _resetPagination();
                        setState(() => _sortByNewest = !_sortByNewest);
                      },
                      child: Container(
                        height: 34,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bgPage,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sort_rounded,
                                size: 14, color: AppColors.green500),
                            const SizedBox(width: 5),
                            Text(
                              _sortByNewest ? 'Terbaru' : 'Terlama',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Chip aroma (sentimen) ─────────────────────
                const Text(
                  'Berdasarkan Aroma',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSentimentChip('positif'),
                      const SizedBox(width: 6),
                      _buildSentimentChip('netral'),
                      const SizedBox(width: 6),
                      _buildSentimentChip('negatif'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── Chip rating bintang ───────────────────────
                const Text(
                  'Berdasarkan Bintang',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.text2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildRatingChip(star),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // ── Info jumlah hasil ────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.bgPage,
            child: Text(
              isFiltered
                  ? 'Menampilkan $total dari ${widget.reviews.length} ulasan'
                  : 'Semua ulasan (${widget.reviews.length})',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Daftar ulasan ─────────────────────────────────────
          Expanded(
            child: visible.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: visible.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == visible.length) {
                        // Loading indicator di paling bawah
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.green500,
                              ),
                            ),
                          ),
                        );
                      }
                      return ReviewTile(review: visible[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 40,
              color: AppColors.green500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Ulasan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada ulasan yang sesuai dengan kriteria filter.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
