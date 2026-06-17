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
  String _selectedSentiment = 'positif';
  int _selectedRating = 5;
  bool _sortByNewest = true;

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime(1970);
  }

  List<Review> get _filteredReviews {
    final list = widget.reviews.where((r) {
      final matchesSentiment = r.sentiment == _selectedSentiment;
      final matchesRating = r.rating == _selectedRating;
      return matchesSentiment && matchesRating;
    }).toList();

    list.sort((a, b) {
      final aDate = _parseDate(a.date);
      final bDate = _parseDate(b.date);
      return _sortByNewest ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });

    return list;
  }

  int _getSentimentCount(String sentiment) {
    return widget.reviews.where((r) => r.sentiment == sentiment).length;
  }

  int _getRatingCount(int rating) {
    return widget.reviews.where((r) => r.rating == rating).length;
  }

  Widget _buildSentimentChip(String sentiment, String label, IconData icon) {
    final isSelected = _selectedSentiment == sentiment;
    final count = _getSentimentCount(sentiment);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedSentiment = sentiment),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green500 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green500 : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.green500.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.text2),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.text1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingChip(int star) {
    final isSelected = _selectedRating == star;
    final count = _getRatingCount(star);

    return GestureDetector(
      onTap: () => setState(() => _selectedRating = star),
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.text1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 14, color: isSelected ? Colors.white : const Color(0xFFFFC107)),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReviews;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Semua Ulasan'),
      body: Column(
        children: [
          // Filter Panel Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                // 1. Sentimen Row
                const Text(
                  'Analisis Sentimen',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSentimentChip('positif', 'Positif', Icons.sentiment_satisfied_alt_rounded),
                      const SizedBox(width: 8),
                      _buildSentimentChip('netral', 'Netral', Icons.sentiment_neutral_rounded),
                      const SizedBox(width: 8),
                      _buildSentimentChip('negatif', 'Negatif', Icons.sentiment_very_dissatisfied_rounded),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Rating & Sorting Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rating Bintang',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1),
                          ),
                          const SizedBox(height: 8),
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
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Urutan',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => setState(() => _sortByNewest = !_sortByNewest),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgPage,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sort_rounded, size: 16, color: AppColors.green500),
                                const SizedBox(width: 6),
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
                  ],
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return ReviewTile(review: filtered[index]);
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
