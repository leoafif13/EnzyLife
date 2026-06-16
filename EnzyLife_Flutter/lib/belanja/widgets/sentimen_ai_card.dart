import 'package:flutter/material.dart';
import '../../app_color.dart';

class SentimenAI extends StatelessWidget {
  final double positif;
  final double netral;
  final double negatif;

  const SentimenAI({
    super.key,
    required this.positif,
    required this.netral,
    required this.negatif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.green500,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 11),
                    SizedBox(width: 4),
                    Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Analisis Sentimen Ulasan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mayoritas pembeli memberikan ulasan ${positif >= 0.6 ? "positif" : "beragam"} terhadap produk ini.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 12),
          // Bar sentimen
          SentimenBar(
            label: 'Positif',
            value: positif,
            color: AppColors.green500,
            icon: Icons.sentiment_satisfied_alt_rounded,
          ),
          const SizedBox(height: 8),
          SentimenBar(
            label: 'Netral',
            value: netral,
            color: const Color(0xFFFFB300),
            icon: Icons.sentiment_neutral_rounded,
          ),
          const SizedBox(height: 8),
          SentimenBar(
            label: 'Negatif',
            value: negatif,
            color: Colors.red[400]!,
            icon: Icons.sentiment_dissatisfied_rounded,
          ),
        ],
      ),
    );
  }
}

class SentimenBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const SentimenBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 55,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text1, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withAlpha(180)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(50),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 36,
          child: Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
