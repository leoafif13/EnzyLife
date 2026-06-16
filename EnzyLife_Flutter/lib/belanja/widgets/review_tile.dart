import 'package:flutter/material.dart';

class Review {
  final String name, comment, date;
  final String? shippingComment;
  final int rating;
  const Review({
    required this.name,
    required this.rating,
    required this.comment,
    this.shippingComment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['nama_user'] ?? 'Anonim',
      rating: json['rating'] ?? 5,
      comment: json['komentar'] ?? '',
      shippingComment: json['komentar_pengiriman'],
      date: json['tanggal'] ?? '',
    );
  }
}

class ReviewTile extends StatelessWidget {
  final Review review;
  const ReviewTile({super.key, required this.review});

  Color _getAvatarBgColor(String name) {
    if (name.isEmpty) return const Color(0xFFE3F2FD);
    final code = name.codeUnitAt(0);
    final colors = [
      const Color(0xFFE3F2FD), // Blue
      const Color(0xFFF3E5F5), // Purple
      const Color(0xFFFFF3E0), // Orange
      const Color(0xFFE8F5E9), // Green
      const Color(0xFFFFEBEE), // Red
      const Color(0xFFE0F7FA), // Cyan
    ];
    return colors[code % colors.length];
  }

  Color _getAvatarTextColor(String name) {
    if (name.isEmpty) return const Color(0xFF1E88E5);
    final code = name.codeUnitAt(0);
    final colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF8E24AA), // Purple
      const Color(0xFFF57C00), // Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFFE53935), // Red
      const Color(0xFF00ACC1), // Cyan
    ];
    return colors[code % colors.length];
  }

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
              backgroundColor: _getAvatarBgColor(review.name),
              child: Text(
                review.name.isNotEmpty ? review.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _getAvatarTextColor(review.name),
                ),
              ),
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
        if (review.shippingComment != null && review.shippingComment!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 14,
                  color: Color(0xFF777777),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.shippingComment!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFFF5F5F5)),
      ],
    ),
  );
}
