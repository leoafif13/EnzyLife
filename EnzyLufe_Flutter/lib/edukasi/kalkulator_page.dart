import 'package:flutter/material.dart';

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

  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Kalkulator Eco Enzim',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Subjudul
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Hitung kebutuhan untuk membuat dan menggunakan eco enzim',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: _green500,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              indicatorColor: _green500,
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
//  Tab Pembuatan
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

  static const _green500 = Color(0xFF4CAF50);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);

  // Rasio eco enzim: Gula : Bahan Organik : Air = 1 : 3 : 10
  // Total parts = 14
  void _hitung() {
    final jumlah = double.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // Konversi ke liter jika satuan mL
    final jumlahLiter = _satuan == 'Mililiter' ? jumlah / 1000 : jumlah;

    // Rumus 1:3:10 → total 14 bagian
    final air          = jumlahLiter;
    final bahanOrganik = (air / 10) * 3;
    final gula         = air / 10;
    final wadah        = air * 1.2; // +20% ruang fermentasi

    setState(() {
      _hasil = {
        'Wadah Minimal':       '${wadah.toStringAsFixed(2)} Liter\n(+20% ruang fermentasi)',
        'Gula Merah':          '${(gula * 1.3).toStringAsFixed(2)} Kilogram', // konversi approx
        'Bahan Organik (Sampah)': '${(bahanOrganik * 1.3).toStringAsFixed(2)} Kilogram',
        'Air':                 '${air.toStringAsFixed(2)} Liter',
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
          // Rumus banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: _green500,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Rumus Eco Enzim', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('1 : 3 : 10', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                SizedBox(height: 4),
                Text('Gula : Bahan Organik : Air', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Input kategori
          const Text('Pilih Kategori Input', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          _DropdownField(
            value: _kategori,
            items: const ['Wadah', 'Air', 'Bahan Organik', 'Gula'],
            onChanged: (v) => setState(() => _kategori = v ?? _kategori),
          ),

          const SizedBox(height: 16),

          // Input jumlah
          const Text('Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          TextField(
            controller: _jumlahController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah',
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green500, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: const ['Liter', 'Mililiter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          // Tombol hitung
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _hitung,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Hitung Kebutuhan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),

          // Hasil
          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
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

  static const _green500 = Color(0xFF4CAF50);

  // Rasio penggunaan per jenis (eco enzim : air)
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
        const SnackBar(content: Text('Masukkan jumlah yang valid'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final jumlahMl = _satuan == 'Liter' ? jumlah * 1000 : jumlah;
    final rasio = _rasio[_jenisGunaan]!;
    final totalParts = (rasio['enzim'] as int) + (rasio['air'] as int);
    final enzimMl = (jumlahMl / totalParts) * (rasio['enzim'] as int);
    final airMl   = jumlahMl - enzimMl;

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
              color: _green500,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Text('Dosis Penggunaan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Hitung kebutuhan Eco Enzim', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('untuk berbagai keperluan',  style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Jenis penggunaan
          const Text('Jenis Penggunaan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
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
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _rasio[_jenisGunaan]!['label'] as String,
              style: const TextStyle(fontSize: 12, color: Color(0xFF388E3C), fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 16),

          // Jumlah larutan
          const Text('Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          TextField(
            controller: _jumlahController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah',
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green500, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: const ['Mililiter', 'Liter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          // Tombol hitung
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _hitung,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Hitung Dosis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),

          // Hasil
          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),
            ..._hasil!.entries.map((e) => _HasilCard(label: e.key, value: e.value)),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Reusable: Dropdown field
// ══════════════════════════════════════════════
class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const _green500 = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF555555)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          items: items.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  Reusable: Kartu hasil perhitungan
// ══════════════════════════════════════════════
class _HasilCard extends StatelessWidget {
  final String label;
  final String value;
  const _HasilCard({required this.label, required this.value});

  static const _colors = [
    Color(0xFFE3F2FD), // biru muda
    Color(0xFFFFF8E1), // kuning muda
    Color(0xFFE8F5E9), // hijau muda
    Color(0xFFFCE4EC), // pink muda
  ];

  static int _counter = 0;

  @override
  Widget build(BuildContext context) {
    // Warna bergantian
    final color = _colors[label.hashCode % _colors.length];
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
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
          const SizedBox(height: 4),
          Text(lines[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
          if (lines.length > 1)
            Text(lines[1], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}