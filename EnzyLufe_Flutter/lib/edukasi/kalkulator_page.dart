import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Kalkulator Eco Enzim'),
      body: Column(
        children: [
          // Header card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'Kalkulator Eco Enzim',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hitung kebutuhan untuk membuat dan menggunakan eco enzim',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tab bar
          Container(
            color: AppColors.bgCard,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.green500,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              indicatorColor: AppColors.green500,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'Pembuatan'),
                Tab(text: 'Penggunaan'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _TabPembuatan(),
                _TabPenggunaan(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Tab Pembuatan — Rumus 1:3:10
// ══════════════════════════════════════════════
class _TabPembuatan extends StatefulWidget {
  const _TabPembuatan();

  @override
  State<_TabPembuatan> createState() => _TabPembuatanState();
}

class _TabPembuatanState extends State<_TabPembuatan> {
  final _jumlahController = TextEditingController();
  String _kategori = 'Wadah';
  String _satuan   = 'Liter';
  Map<String, String>? _hasil;

  void _hitung() {
    final jumlah = double.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final jumlahLiter = _satuan == 'Mililiter' ? jumlah / 1000 : jumlah;
    final air          = jumlahLiter;
    final bahanOrganik = (air / 10) * 3;
    final gula         = air / 10;
    final wadah        = air * 1.2;

    setState(() {
      _hasil = {
        'Wadah Minimal':          '${wadah.toStringAsFixed(2)} Liter\n(+20% ruang fermentasi)',
        'Gula Merah':             '${(gula * 1.3).toStringAsFixed(2)} Kilogram',
        'Bahan Organik (Sampah)': '${(bahanOrganik * 1.3).toStringAsFixed(2)} Kilogram',
        'Air':                    '${air.toStringAsFixed(2)} Liter',
      };
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner rumus
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.green500,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Rumus Eco Enzim',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('1 : 3 : 10',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                SizedBox(height: 4),
                Text('Gula : Bahan Organik : Air',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Pilih Kategori Input',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 8),
          _DropdownField(
            value: _kategori,
            items: const ['Wadah', 'Air', 'Bahan Organik', 'Gula'],
            onChanged: (v) => setState(() => _kategori = v ?? _kategori),
          ),

          const SizedBox(height: 16),

          const Text('Jumlah',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 8),
          _NumberInput(controller: _jumlahController, hint: 'Masukkan jumlah'),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: const ['Liter', 'Mililiter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          _HitungButton(label: 'Hitung Kebutuhan', onPressed: _hitung),

          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text1)),
            const SizedBox(height: 12),
            ..._hasil!.entries.map((e) => _HasilCard(label: e.key, value: e.value)),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Tab Penggunaan
// ══════════════════════════════════════════════
class _TabPenggunaan extends StatefulWidget {
  const _TabPenggunaan();

  @override
  State<_TabPenggunaan> createState() => _TabPenggunaanState();
}

class _TabPenggunaanState extends State<_TabPenggunaan> {
  final _jumlahController = TextEditingController();
  String _jenisGunaan = 'Pupuk Organik';
  String _satuan      = 'Mililiter';
  Map<String, String>? _hasil;

  static const _rasio = {
    'Pupuk Organik':    {'enzim': 1, 'air': 500,  'label': 'Eco Enzim : Air = 1 : 500'},
    'Pembersih Lantai': {'enzim': 1, 'air': 1000, 'label': 'Eco Enzim : Air = 1 : 1000'},
    'Pestisida':        {'enzim': 1, 'air': 1000, 'label': 'Eco Enzim : Air = 1 : 1000'},
    'Pengharum':        {'enzim': 1, 'air': 200,  'label': 'Eco Enzim : Air = 1 : 200'},
  };

  void _hitung() {
    final jumlah = double.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final jumlahMl   = _satuan == 'Liter' ? jumlah * 1000 : jumlah;
    final rasio      = _rasio[_jenisGunaan]!;
    final totalParts = (rasio['enzim'] as int) + (rasio['air'] as int);
    final enzimMl    = (jumlahMl / totalParts) * (rasio['enzim'] as int);
    final airMl      = jumlahMl - enzimMl;

    setState(() {
      _hasil = {
        'Eco Enzim':     '${enzimMl.toStringAsFixed(1)} mL',
        'Air':           '${airMl.toStringAsFixed(1)} mL',
        'Total Larutan': '${jumlahMl.toStringAsFixed(1)} mL',
      };
    });
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner dosis
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.green500,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Dosis Penggunaan',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Hitung kebutuhan Eco Enzim untuk berbagai keperluan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Jenis Penggunaan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 8),
          _DropdownField(
            value: _jenisGunaan,
            items: _rasio.keys.toList(),
            onChanged: (v) => setState(() => _jenisGunaan = v ?? _jenisGunaan),
          ),

          const SizedBox(height: 8),
          // Info rasio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _rasio[_jenisGunaan]!['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.green700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text('Jumlah',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text1)),
          const SizedBox(height: 8),
          _NumberInput(controller: _jumlahController, hint: 'Masukkan jumlah'),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: const ['Mililiter', 'Liter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          _HitungButton(label: 'Hitung Dosis', onPressed: _hitung),

          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text1)),
            const SizedBox(height: 12),
            ..._hasil!.entries.map((e) => _HasilCard(label: e.key, value: e.value)),
          ],
        ],
      ),
    );
  }
}

// ── Reusable: Dropdown ────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.text2),
          style: const TextStyle(fontSize: 14, color: AppColors.text1),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Reusable: Number input ────────────────────
class _NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _NumberInput({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 14, color: AppColors.text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green500, width: 1.5),
        ),
      ),
    );
  }
}

// ── Reusable: Tombol hitung ───────────────────
class _HitungButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HitungButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green500,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Reusable: Kartu hasil perhitungan ─────────
class _HasilCard extends StatelessWidget {
  final String label;
  final String value;

  const _HasilCard({required this.label, required this.value});

  static const _colors = [
    Color(0xFFE3F2FD),
    Color(0xFFFFF8E1),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[label.hashCode.abs() % _colors.length];
    final lines = value.split('\n');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 4),
          Text(lines[0],
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text1)),
          if (lines.length > 1)
            Text(lines[1], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}