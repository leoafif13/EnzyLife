import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import '../widgets/chatbot_widget.dart';

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
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
        children: [
          // Header card
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeaderCard(
              badge: '🧮  Kalkulator',
              title: 'Kalkulator Eco Enzim',
              subtitle: 'Hitung kebutuhan untuk membuat dan menggunakan eco enzim',
              icon: Icons.calculate_outlined,
            ),
          ),
          
          // Tab bar & views wrapped in a single card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    // Styled TabBar inside card with horizontal padding to prevent stretching edge-to-edge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.green500,
                        unselectedLabelColor: Colors.grey[500],
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        indicatorColor: AppColors.green500,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.build_circle_outlined, size: 20),
                            text: 'Pembuatan',
                          ),
                          Tab(
                            icon: Icon(Icons.opacity_rounded, size: 20),
                            text: 'Penggunaan',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    // Tab content inside card
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
              ),
            ),
          ),
        ],
      ),
      const ChatbotWidget(),
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

    double gula;
    double organik;
    double air;

    switch (_kategori) {
      case 'Gula':
        gula = jumlah;
        organik = gula * 3;
        air = gula * 10;
        break;

      case 'Bahan Organik':
        organik = jumlah;
        gula = organik / 3;
        air = gula * 10;
        break;

      case 'Air':
        air = _satuan == 'Mililiter'
            ? jumlah / 1000
            : jumlah;

        gula = air / 10;
        organik = gula * 3;
        break;

      case 'Wadah':
        final volumeWadah =
            _satuan == 'Mililiter'
                ? jumlah / 1000
                : jumlah;

        air = volumeWadah / 1.2;
        gula = air / 10;
        organik = gula * 3;
        break;

      default:
        return;
    }

    final wadah = air * 1.2;
    final pakaiMl = _satuan == 'Mililiter';

    setState(() {
      _hasil = {
        'Wadah Minimal': pakaiMl
            ? '${(wadah * 1000).toStringAsFixed(0)} mL\n(+20% ruang fermentasi)'
            : '${wadah.toStringAsFixed(2)} Liter\n(+20% ruang fermentasi)',

        'Gula Merah': pakaiMl
            ? '${(gula * 1000).toStringAsFixed(0)} gram'
            : '${gula.toStringAsFixed(2)} Kg',

        'Bahan Organik': pakaiMl
            ? '${(organik * 1000).toStringAsFixed(0)} gram'
            : '${organik.toStringAsFixed(2)} Kg',

        'Air': pakaiMl
            ? '${(air * 1000).toStringAsFixed(0)} mL'
            : '${air.toStringAsFixed(2)} Liter',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner rumus gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.green900, AppColors.green700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.heroShadow,
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.science_outlined, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Rumus Eco Enzim',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 6),
                Text('1 : 3 : 10',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2)),
                SizedBox(height: 4),
                Text('Gula : Bahan Organik : Air',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Hitung kebutuhan bahan untuk wadah dan pembuatan eco enzim secara presisi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Pilih Kategori Input',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 8),
          _DropdownField(
            value: _kategori,
            items: const ['Wadah', 'Air', 'Bahan Organik', 'Gula'],
            onChanged: (v) {
              setState(() {
                _kategori = v ?? _kategori;

                if (_kategori == 'Gula' ||
                    _kategori == 'Bahan Organik') {
                  _satuan = 'Kilogram';
                } else {
                  _satuan = 'Liter';
                }
              });
            },
          ),

          const SizedBox(height: 16),

          const Text('Jumlah & Satuan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 8),
          _NumberInput(
            controller: _jumlahController,
            hint: 'Masukkan jumlah',
            prefixIcon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: _kategori == 'Gula' ||
                    _kategori == 'Bahan Organik'
                ? const ['Kilogram']
                : const ['Liter', 'Mililiter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          _HitungButton(
            label: 'Hitung Kebutuhan',
            icon: Icons.calculate_outlined,
            onPressed: _hitung,
          ),

          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
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
    // Rumah Tangga
    'Kompor & Area Dapur': {
      'enzim': 1,
      'campuran': 10,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 10',
    },

    'Cuci Piring': {
      'enzim': 1,
      'campuran': 1,
      'bahan': 'Sabun Cuci Piring',
      'label': 'Eco Enzim : Sabun Cuci Piring = 1 : 1',
    },

    'Cuci Pakaian': {
      'enzim': 1,
      'campuran': 10,
      'bahan': 'Deterjen',
      'label': 'Eco Enzim : Deterjen = 1 : 10',
    },

    'Pel Lantai': {
      'enzim': 1,
      'campuran': 50,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 50',
    },

    'Kamar Mandi': {
      'enzim': 1,
      'campuran': 10,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 10',
    },

    'Saluran Air': {
      'enzim': 1,
      'campuran': 1,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 1',
    },

    'Penghilang Bau': {
      'enzim': 1,
      'campuran': 500,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 500',
    },

    // Pertanian
    'Pupuk Organik': {
      'enzim': 1,
      'campuran': 1000,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 1000',
    },

    'Pestisida Sayuran': {
      'enzim': 1,
      'campuran': 500,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 500',
    },

    'Kompos': {
      'enzim': 1,
      'campuran': 100,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 100',
    },

    // Lingkungan
    'Air Purifier': {
      'enzim': 1,
      'campuran': 1000,
      'bahan': 'Air',
      'label': 'Eco Enzim : Air = 1 : 1000',
    },
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
    final totalParts =
        (rasio['enzim'] as int) +
        (rasio['campuran'] as int);
    final enzimMl =
        (jumlahMl / totalParts) *
        (rasio['enzim'] as int);
    final campuranMl =
        jumlahMl - enzimMl;

    setState(() {
      _hasil = {
        'Eco Enzim':
            '${enzimMl.toStringAsFixed(1)} mL',

        rasio['bahan'] as String:
            '${campuranMl.toStringAsFixed(1)} mL',

        'Total Larutan':
            '${jumlahMl.toStringAsFixed(1)} mL',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner dosis gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.green900, AppColors.green700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.heroShadow,
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.opacity_rounded, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text('Dosis Penggunaan',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 6),
                Text('Kalkulator Dosis',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Hitung kebutuhan Eco Enzim untuk berbagai keperluan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Jenis Penggunaan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
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
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.green700),
                const SizedBox(width: 6),
                Text(
                  _rasio[_jenisGunaan]!['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.green700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text('Jumlah & Satuan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 8),
          _NumberInput(
            controller: _jumlahController,
            hint: 'Masukkan jumlah',
            prefixIcon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 8),
          _DropdownField(
            value: _satuan,
            items: const ['Mililiter', 'Liter'],
            onChanged: (v) => setState(() => _satuan = v ?? _satuan),
          ),

          const SizedBox(height: 20),

          _HitungButton(
            label: 'Hitung Dosis',
            icon: Icons.calculate_outlined,
            onPressed: _hitung,
          ),

          if (_hasil != null) ...[
            const SizedBox(height: 24),
            const Text('Hasil Perhitungan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
            const SizedBox(height: 12),
            ..._hasil!.entries.map((e) => _HasilCard(label: e.key, value: e.value)),
          ],
        ],
      ),
    );
  }
}

// Helper function to dynamically map dropdown labels to corresponding icons
IconData _getItemIcon(String item) {
  switch (item) {
    // Pembuatan input
    case 'Wadah':
      return Icons.inventory_2_outlined;
    case 'Air':
      return Icons.water_drop_outlined;
    case 'Bahan Organik':
      return Icons.spa_outlined;
    case 'Gula':
      return Icons.cookie_outlined;
    
    // Penggunaan input
    case 'Kompor & Area Dapur':
    case 'Cuci Piring':
      return Icons.kitchen_outlined;
    case 'Cuci Pakaian':
    case 'Pel Lantai':
    case 'Kamar Mandi':
    case 'Saluran Air':
    case 'Penghilang Bau':
      return Icons.clean_hands_outlined;
    case 'Pupuk Organik':
    case 'Pestisida Sayuran':
    case 'Kompos':
      return Icons.spa_outlined;
    case 'Air Purifier':
      return Icons.wb_sunny_outlined;

    // Satuan
    case 'Liter':
    case 'Mililiter':
      return Icons.opacity_rounded;
    case 'Kilogram':
      return Icons.scale_outlined;
    default:
      return Icons.category_outlined;
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
        color: AppColors.bgPage,
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
              .map((v) => DropdownMenuItem(
                    value: v,
                    child: Row(
                      children: [
                        Icon(_getItemIcon(v), size: 18, color: AppColors.green500),
                        const SizedBox(width: 10),
                        Text(v),
                      ],
                    ),
                  ))
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
  final IconData? prefixIcon;

  const _NumberInput({
    required this.controller,
    required this.hint,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 14, color: AppColors.text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.green500, size: 20) : null,
        filled: true,
        fillColor: AppColors.bgPage,
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
  final IconData icon;

  const _HitungButton({required this.label, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green500,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Reusable: Kartu hasil perhitungan ─────────
class _HasilCard extends StatelessWidget {
  final String label;
  final String value;

  const _HasilCard({required this.label, required this.value});

  IconData _getHasilIcon(String label) {
    if (label.contains('Wadah')) return Icons.inventory_2_outlined;
    if (label.contains('Gula')) return Icons.cookie_outlined;
    if (label.contains('Organik')) return Icons.spa_outlined;
    if (label.contains('Air')) return Icons.water_drop_outlined;
    if (label.contains('Eco Enzim')) return Icons.eco_rounded;
    if (label.contains('Total')) return Icons.opacity_rounded;
    return Icons.bubble_chart_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final lines = value.split('\n');
    final icon = _getHasilIcon(label);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.green50.withAlpha(128), // Premium soft green background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green200.withAlpha(128)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.green500,
                width: 4.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label, 
                      style: const TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600,
                        color: AppColors.text2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lines[0],
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w800, 
                        color: AppColors.text1,
                      ),
                    ),
                    if (lines.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        lines[1], 
                        style: const TextStyle(
                          fontSize: 11, 
                          color: AppColors.text3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.green700, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}