import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class RiwayatKalkulatorScreen extends StatelessWidget {
  const RiwayatKalkulatorScreen({super.key});

  // TODO: ganti dengan data dari API / SharedPreferences
  static const _history = [
    _KalkulatorHistory(
      id: 'k1', type: 'Pembuatan',
      input: 'Air: 10 Liter',
      results: {'Wadah Minimal': '12.00 Liter', 'Gula Merah': '1.30 Kg',
                'Bahan Organik': '3.90 Kg', 'Air': '10.00 Liter'},
      date: '09 Apr 2026',
    ),
    _KalkulatorHistory(
      id: 'k2', type: 'Penggunaan',
      input: 'Pupuk Organik: 500 mL',
      results: {'Eco Enzim': '1.0 mL', 'Air': '499.0 mL', 'Total': '500.0 mL'},
      date: '05 Apr 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Riwayat Kalkulator'),
      body: _history.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _history.length,
              itemBuilder: (_, i) => _HistoryCard(item: _history[i]),
            ),
    );
  }
}

class _KalkulatorHistory {
  final String id, type, input, date;
  final Map<String, String> results;
  const _KalkulatorHistory({
    required this.id, required this.type, required this.input,
    required this.results, required this.date,
  });
}

class _HistoryCard extends StatelessWidget {
  final _KalkulatorHistory item;
  const _HistoryCard({super.key, required this.item});

  Color get _typeColor =>
      item.type == 'Pembuatan' ? AppColors.green700 : const Color(0xFF1565C0);

  Color get _typeBgColor =>
      item.type == 'Pembuatan' ? AppColors.green50 : const Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: AppColors.green50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.calculate_outlined,
                      size: 18, color: AppColors.green500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kalkulator ${item.type}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: AppColors.text1)),
                      Text(item.input,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item.type,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: _typeColor)),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),

            // Hasil
            Wrap(
              spacing: 8, runSpacing: 8,
              children: item.results.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(e.value,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.text1)),
                  ],
                ),
              )).toList(),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(item.date,
                        style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                GestureDetector(
                  onTap: () {}, // TODO: hitung ulang dengan input yang sama
                  child: const Text('Hitung ulang →',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: AppColors.green500)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.calculate_outlined, size: 36, color: AppColors.green500),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada riwayat kalkulator',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 6),
          Text('Gunakan kalkulator untuk menyimpan riwayat perhitungan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}