import 'package:flutter/material.dart';
import '../app_color.dart';
import '../services/api_service.dart';

class RoutineSetupSheet extends StatefulWidget {
  final int? pemesananId;
  final int? produkId;
  final int? trackerId;
  final List<String>? productKategoriList;
  final List<String>? existingKategoriList;
  final VoidCallback? onSuccess;

  const RoutineSetupSheet({
    super.key,
    this.pemesananId,
    this.produkId,
    this.trackerId,
    this.productKategoriList,
    this.existingKategoriList,
    this.onSuccess,
  });

  @override
  State<RoutineSetupSheet> createState() => _RoutineSetupSheetState();
}

class _RoutineSetupSheetState extends State<RoutineSetupSheet> {
  late List<Map<String, dynamic>> _kategoriOptions;

  @override
  void initState() {
    super.initState();
    _initKategoriOptions();
  }

  void _initKategoriOptions() {
    final supported = widget.productKategoriList?.map((e) => e.trim().toLowerCase()).toList() ?? [];
    final existing = widget.existingKategoriList?.map((e) => e.trim().toLowerCase()).toList() ?? [];

    _kategoriOptions = [
      {
        'nama': 'Kompor & Area Dapur',
        'tipe': 'Harian (5-7x)',
        'takaran': '±45 ml • 1:10 (Semprot 500 ml)',
        'icon': Icons.kitchen_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Pel Lantai',
        'tipe': 'Mingguan (2-3x)',
        'takaran': '±50 ml • 1:50 (Ember 5 Liter)',
        'icon': Icons.cleaning_services_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Cuci Piring',
        'tipe': 'Harian (5-7x)',
        'takaran': '±100 ml • 1:1 (Botol Sabun)',
        'icon': Icons.local_dining_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Cuci Pakaian',
        'tipe': 'Fleksibel',
        'takaran': '±50 ml • 1:10 (Mesin Cuci)',
        'icon': Icons.local_laundry_service_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Kamar Mandi',
        'tipe': 'Mingguan (1-2x)',
        'takaran': '±100 ml • 1:10 (Sikat Toilet)',
        'icon': Icons.bathtub_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Saluran Air',
        'tipe': 'Fleksibel',
        'takaran': '±250 ml • 1:1 (Gayung 1 Liter)',
        'icon': Icons.plumbing_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Penghilang Bau',
        'tipe': 'Fleksibel',
        'takaran': '±1 ml • 1:500 (Botol Semprot)',
        'icon': Icons.air_rounded,
        'selected': false,
        'kelompok': 'Rumah Tangga',
      },
      {
        'nama': 'Pupuk Organik',
        'tipe': 'Mingguan (1-2x)',
        'takaran': '±1 ml • 1:1000 (Semprotan 1 Liter)',
        'icon': Icons.yard_rounded,
        'selected': false,
        'kelompok': 'Pertanian',
      },
      {
        'nama': 'Pestisida Sayuran',
        'tipe': 'Mingguan (1-2x)',
        'takaran': '±2 ml • 1:500 (Semprotan 1 Liter)',
        'icon': Icons.eco_rounded,
        'selected': false,
        'kelompok': 'Pertanian',
      },
      {
        'nama': 'Kompos',
        'tipe': 'Mingguan (1x)',
        'takaran': '±10 ml • 1:100 (Siram 1 Liter)',
        'icon': Icons.compost_rounded,
        'selected': false,
        'kelompok': 'Pertanian',
      },
      {
        'nama': 'Air Purifier',
        'tipe': 'Fleksibel',
        'takaran': '±0.5 ml • 1:1000 (Diffuser 500 ml)',
        'icon': Icons.filter_drama_rounded,
        'selected': false,
        'kelompok': 'Lingkungan',
      },
    ];

    // Jika ada kategori spesifik produk atau kategori yang sudah ada, filter tampilannya
    if (supported.isNotEmpty || existing.isNotEmpty) {
      final filtered = _kategoriOptions.where((opt) {
        final nameLower = (opt['nama'] as String).toLowerCase();
        final isSupported = supported.any((s) => s == nameLower || nameLower.contains(s) || s.contains(nameLower));
        final isExisting = existing.any((e) => e == nameLower || nameLower.contains(e) || e.contains(nameLower));
        return isSupported || isExisting;
      }).toList();

      if (filtered.isNotEmpty) {
        _kategoriOptions = filtered;
      }
    }

    // Tentukan item mana yang sudah ada (terkunci) dan mana yang terseleksi
    for (var opt in _kategoriOptions) {
      final nameLower = (opt['nama'] as String).toLowerCase();
      final isExisting = existing.any((e) => e == nameLower || nameLower.contains(e) || e.contains(nameLower));
      final isSupported = supported.any((s) => s == nameLower || nameLower.contains(s) || s.contains(nameLower));

      if (isExisting) {
        opt['selected'] = true;
        opt['is_existing'] = true; // Kategori awal tidak bisa dihapus!
      } else if (existing.isEmpty && isSupported) {
        opt['selected'] = true;
        opt['is_from_product'] = true;
      }
    }

    // Jika belum ada yang aktif dan setup pertama kali, default pilih 2 teratas
    if (existing.isEmpty && !_kategoriOptions.any((opt) => opt['selected'] == true)) {
      if (_kategoriOptions.isNotEmpty) _kategoriOptions[0]['selected'] = true;
      if (_kategoriOptions.length > 1) _kategoriOptions[1]['selected'] = true;
    }
  }

  String _selectedJam = '19:00';
  bool _isLoading = false;

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );
    if (time != null) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      setState(() => _selectedJam = '$h:$m');
    }
  }

  Future<void> _submitSetup() async {
    final selectedCategories = _kategoriOptions
        .where((k) => k['selected'] == true)
        .map((k) => k['nama'] as String)
        .toList();

    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 kategori rutinitas pemakaian'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await ApiService.setupRoutines(
      kategori: selectedCategories,
      jamPengingat: _selectedJam,
      pemesananId: widget.pemesananId,
      produkId: widget.produkId,
      trackerId: widget.trackerId,
    );

    setState(() => _isLoading = false);

    if (res != null && res['success'] == true) {
      if (mounted) {
        Navigator.pop(context, true);
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Rutinitas Eco Enzyme berhasil diperbarui!'),
            backgroundColor: AppColors.green700,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['message'] ?? 'Gagal menyiapkan rutinitas'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAddingMode = widget.existingKategoriList != null && widget.existingKategoriList!.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.green500, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAddingMode ? 'Tambah Kategori Rutinitas' : 'Setup Rutinitas Eco Enzyme',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1,
                        ),
                      ),
                      Text(
                        isAddingMode
                            ? 'Kategori yang sudah dipilih tersimpan permanen'
                            : 'Pilih area pemakaian yang sesuai kebutuhan Anda',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.text3),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isAddingMode ? 'Daftar Kategori Produk:' : 'Pilih Kategori Rutinitas:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1),
            ),
            const SizedBox(height: 10),
            ..._kategoriOptions.map((item) {
              final isSelected = item['selected'] == true;
              final isExisting = item['is_existing'] == true;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    if (isExisting) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kategori yang sudah dipilih tidak dapat dihapus, hanya dapat menambah kategori baru.'),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppColors.green700,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      item['selected'] = !isSelected;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.green50 : AppColors.bgPage,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.green500 : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected ? AppColors.green700 : AppColors.text3,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item['nama'] as String,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? AppColors.green700 : AppColors.text1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isExisting) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFA5D6A7)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.lock_rounded, size: 10, color: Color(0xFF2E7D32)),
                                          SizedBox(width: 3),
                                          Text(
                                            'Sudah Aktif',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (item['is_from_product'] == true) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.green50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.green200),
                                      ),
                                      child: const Text(
                                        'Sesuai Produk',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.green700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['tipe']} • ${item['takaran']}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.text3),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          activeColor: isExisting ? const Color(0xFF2E7D32) : AppColors.green500,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: isExisting
                              ? null // Terkunci, tidak bisa di-uncheck!
                              : (val) {
                                  setState(() {
                                    item['selected'] = val ?? false;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam Pengingat Pintar',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text1),
                    ),
                    Text(
                      'Notifikasi gabungan hanya jika diperlukan',
                      style: TextStyle(fontSize: 11.5, color: AppColors.text3),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time_rounded, size: 16),
                  label: Text(_selectedJam),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green700,
                    side: const BorderSide(color: AppColors.green500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isAddingMode ? 'Simpan & Tambah Kategori' : 'Mulai Siklus 1 (7 Hari)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
