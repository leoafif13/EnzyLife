
import 'package:flutter/material.dart';

import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import '../widgets/search_bar_field.dart';
import '../services/auth_service.dart';
import '../widgets/expandable_tile.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _query = '';
  String _selectedCategory = 'semua';
  int _currentPage = 0;

  final TextEditingController _search = TextEditingController();
  final PageController _pageController = PageController();

  static const List<_FaqItem> _faqItems = [
    _FaqItem(
      category: 'umum',
      question: 'Apa itu Eco Enzim?',
      answer:
          'Eco Enzim adalah cairan hasil fermentasi limbah organik seperti kulit buah dan sayuran yang dicampur dengan gula dan air. Cairan ini dapat dimanfaatkan untuk berbagai keperluan rumah tangga seperti pembersih alami, pupuk cair, hingga penghilang bau.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Apa saja bahan untuk membuat eco enzim?',
      answer:
          'Eco Enzim dibuat dari tiga bahan utama yaitu air, gula merah atau molase, dan limbah organik berupa kulit buah atau sayuran. Perbandingan yang umum digunakan adalah 10 bagian air, 1 bagian gula, dan 3 bagian limbah organik.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Berapa lama waktu fermentasi eco enzim?',
      answer:
          'Proses fermentasi Eco Enzim umumnya memerlukan waktu sekitar 3 bulan atau 90 hari. Wadah perlu disimpan di tempat teduh dan tekanan gas perlu ditangani dengan aman sesuai prosedur fermentasi.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah aman digunakan untuk kulit?',
      answer:
          'Tingkat keasaman setiap hasil fermentasi dapat berbeda. Hindari penggunaan pada kulit sensitif atau luka terbuka. Jangan menganggap Eco Enzim aman untuk kulit tanpa pengujian dan petunjuk penggunaan yang sesuai.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Berapa lama eco enzim dapat disimpan?',
      answer:
          'Masa simpan dipengaruhi oleh kondisi penyimpanan dan kualitas hasil fermentasi. Simpan dalam wadah yang sesuai dan periksa kondisi cairan sebelum digunakan. Lama penyimpanan saja tidak menjamin kualitas atau keamanannya.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Apa manfaat eco enzim bagi lingkungan?',
      answer:
          'Eco Enzim membantu memanfaatkan limbah organik sehingga sebagian sampah dapat diolah kembali. Pemanfaatannya dapat mendukung upaya pengurangan sampah rumah tangga.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Mengapa wadah fermentasi tidak boleh diisi penuh?',
      answer:
          'Gas dapat terbentuk selama fermentasi. Sisakan ruang kosong sesuai panduan pembuatan agar tekanan tidak berlebihan. Jangan menyimpan hasil fermentasi dalam wadah tertutup rapat tanpa prosedur penanganan gas yang sesuai.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bisakah eco enzim digunakan sebagai pupuk tanaman?',
      answer:
          'Eco Enzim terkadang dimanfaatkan sebagai larutan pendukung perawatan tanaman setelah diencerkan. Ikuti panduan pengenceran yang sesuai dan uji pada sebagian kecil tanaman terlebih dahulu.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bagaimana cara menggunakan eco enzim sebagai pembersih?',
      answer:
          'Penggunaan dan pengenceran bergantung pada tujuan serta permukaan yang akan dibersihkan. Ikuti panduan produk yang sesuai, uji pada area kecil, dan hindari mencampurnya dengan bahan pembersih lain.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Apakah semua jenis kulit buah bisa digunakan?',
      answer:
          'Kulit buah dan sebagian sisa sayuran dapat digunakan sebagai bahan organik. Pilih bahan sesuai panduan fermentasi dan hindari bahan yang tercampur minyak, bahan kimia, atau kontaminan lain.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Mengapa botol fermentasi menghasilkan gas?',
      answer:
          'Gas dapat terbentuk akibat aktivitas mikroorganisme selama fermentasi. Jumlah gas dipengaruhi oleh bahan dan kondisi proses. Tekanan wadah harus ditangani dengan hati-hati.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah eco enzim bisa diminum?',
      answer:
          'Tidak. Eco Enzim untuk keperluan rumah tangga bukan produk pangan dan tidak boleh diminum.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Bagaimana cara mengetahui eco enzim sudah matang?',
      answer:
          'Waktu fermentasi, aroma, warna, dan kondisi permukaan dapat menjadi bahan pemeriksaan, tetapi tidak satu pun tanda tersebut menjamin keamanan. Ikuti panduan pembuatan dan penilaian dari praktisi yang berpengalaman.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apa yang dilakukan dengan ampas setelah panen eco enzim?',
      answer:
          'Ampas yang tidak menunjukkan tanda kontaminasi dapat dipertimbangkan untuk pengomposan sesuai panduan pengolahan limbah organik.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bisakah eco enzim digunakan untuk menghilangkan bau?',
      answer:
          'Eco Enzim kadang digunakan untuk membantu mengurangi bau pada area tertentu. Hasilnya dapat berbeda dan tidak menggantikan pembersihan sumber bau.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah eco enzim dapat digunakan untuk membersihkan saluran air?',
      answer:
          'Eco Enzim tidak menjamin saluran air menjadi bersih atau bebas sumbatan. Untuk saluran tersumbat, gunakan metode pembersihan yang sesuai dan jangan mencampur Eco Enzim dengan bahan kimia pembersih.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Apakah warna eco enzim selalu sama?',
      answer:
          'Tidak. Warna dapat berbeda tergantung bahan yang digunakan dan proses fermentasi.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Mengapa eco enzim disebut ramah lingkungan?',
      answer:
          'Eco Enzim memanfaatkan limbah organik sebagai bahan baku sehingga dapat mendukung pengurangan sampah. Dampak lingkungannya tetap bergantung pada proses pembuatan dan penggunaannya.',
    ),
  ];

  static const List<_FaqItem> _troubleshootingItems = [
    _FaqItem(
      category: 'fermentasi',
      question: 'Fermentasi tidak menghasilkan gas',
      answer:
          'Produksi gas dapat berbeda bergantung pada bahan dan kondisi fermentasi. Periksa komposisi bahan, tanggal pembuatan, dan kondisi wadah. Tidak adanya gas saja belum cukup untuk menyimpulkan bahwa fermentasi gagal.',
    ),
    _FaqItem(
      category: 'fermentasi',
      question: 'Wadah fermentasi menggembung',
      answer:
          'Gas dapat terbentuk selama fermentasi. Wadah yang menggembung menandakan tekanan mungkin meningkat. Tangani dengan hati-hati, jangan arahkan tutup ke wajah, dan ikuti prosedur pelepasan gas yang aman.',
    ),
    _FaqItem(
      category: 'bau',
      question: 'Eco Enzyme berbau busuk',
      answer:
          'Bau busuk yang kuat dapat mengindikasikan masalah atau kontaminasi. Jangan mencicipi atau menggunakan cairan tersebut. Minta penilaian praktisi Eco Enzyme yang berpengalaman.',
    ),
    _FaqItem(
      category: 'jamur',
      question: 'Muncul lapisan putih di permukaan',
      answer:
          'Lapisan putih dapat memiliki penyebab berbeda. Warna saja tidak cukup untuk memastikan apakah lapisan tersebut aman. Jangan langsung mengaduknya ke dalam cairan. Minta penilaian praktisi berpengalaman.',
    ),
    _FaqItem(
      category: 'jamur',
      question: 'Muncul jamur berbulu atau berwarna',
      answer:
          'Pertumbuhan berbulu atau berwarna mencolok perlu diwaspadai sebagai dugaan kontaminasi. Hindari menyentuh atau menggunakan cairannya. Jangan mencoba menyelamatkan hasil hanya dengan menyaring permukaannya.',
    ),
    _FaqItem(
      category: 'panen',
      question: 'Warna Eco Enzyme berubah',
      answer:
          'Warna dapat berbeda bergantung pada bahan yang digunakan. Periksa juga aroma, kondisi permukaan, dan catatan fermentasi. Jika disertai bau busuk atau pertumbuhan mencurigakan, jangan gunakan sebelum diperiksa.',
    ),
    _FaqItem(
      category: 'panen',
      question: 'Cairan keruh atau memiliki endapan',
      answer:
          'Endapan dapat berasal dari sisa bahan organik, tetapi perlu dinilai bersama tanda lainnya. Periksa aroma dan kondisi permukaan. Jangan menyimpulkan hasil aman hanya karena waktu fermentasinya sudah cukup.',
    ),
    _FaqItem(
      category: 'panen',
      question: 'Bagaimana menangani ampas setelah panen?',
      answer:
          'Ampas yang tidak menunjukkan tanda kontaminasi dapat dipertimbangkan untuk pengomposan. Jika terdapat dugaan kontaminasi atau pembusukan, jangan langsung mencampurkannya ke kompos atau tanah sebelum mendapat saran penanganan yang tepat.',
    ),
  ];

  List<_FaqItem> get _currentItems {
    return _currentPage == 0 ? _faqItems : _troubleshootingItems;
  }

  List<_FaqItem> get _filteredItems {
    return _currentItems.where((item) {
      final matchesCategory =
          _selectedCategory == 'semua' ||
          item.category == _selectedCategory;

      final query = _query.toLowerCase().trim();
      final matchesQuery =
          query.isEmpty ||
          item.question.toLowerCase().contains(query) ||
          item.answer.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    AuthService.incrementMenuVisit('FAQ');
  }

  @override
  void dispose() {
    _search.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int index) {
    if (_currentPage == index) return;

    setState(() {
      _currentPage = index;
      _selectedCategory = 'semua';
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  List<Widget> _buildCategoryChips() {
    final categories = _currentPage == 0
        ? <(String, String, IconData)>[
            ('semua', 'Semua', Icons.all_inclusive),
            ('umum', 'Umum', Icons.info_outline_rounded),
            ('pembuatan', 'Pembuatan', Icons.build_circle_outlined),
            ('penggunaan', 'Penggunaan', Icons.settings_suggest_outlined),
          ]
        : <(String, String, IconData)>[
            ('semua', 'Semua', Icons.all_inclusive),
            ('fermentasi', 'Fermentasi', Icons.autorenew_rounded),
            ('bau', 'Bau', Icons.air_rounded),
            ('jamur', 'Jamur', Icons.grass_outlined),
            ('panen', 'Panen', Icons.water_drop_outlined),
          ];

    return categories.map((category) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _FaqCategoryChip(
          label: category.$2,
          icon: category.$3,
          active: _selectedCategory == category.$1,
          onTap: () {
            setState(() => _selectedCategory = category.$1);
          },
        ),
      );
    }).toList();
  }

  Widget _buildQuestionList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return _EmptyState(
        query: _query,
        category: _selectedCategory,
      );
    }

    return ListView.builder(
      key: PageStorageKey('help-$_currentPage-$_selectedCategory-$_query'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ExpandableTile(
          key: ValueKey('${_currentPage}-${items[index].question}'),
          title: items[index].question,
          content: items[index].answer,
          leading: const QBadge(),
        );
      },
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _currentPage == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgCard : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.green500
                  : AppColors.text2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Pusat Bantuan'),
      body: Column(
        children: [
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeaderCard(
              badge: _currentPage == 0
                  ? '❓ FAQ'
                  : '🛠️ TROUBLESHOOTING',
              title: _currentPage == 0 ? 'FAQ' : 'Troubleshooting',
              subtitle: _currentPage == 0
                  ? 'Daftar tanya jawab seputar Eco Enzim'
                  : 'Bantuan untuk masalah selama pembuatan dan penggunaan Eco Enzim',
              icon: _currentPage == 0
                  ? Icons.help_outline_rounded
                  : Icons.build_circle_outlined,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SearchBarField(
              controller: _search,
              hintText: 'Cari pertanyaan atau jawaban...',
              onChanged: (value) => setState(() => _query = value),
              showClearButton: _query.isNotEmpty,
              onClear: () {
                setState(() => _query = '');
                _search.clear();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTab('FAQ', 0),
                  _buildTab('Troubleshooting', 1),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(children: _buildCategoryChips()),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _selectedCategory = 'semua';
                });
              },
              children: [
                _buildQuestionListForPage(0),
                _buildQuestionListForPage(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionListForPage(int pageIndex) {
    final items = (pageIndex == 0 ? _faqItems : _troubleshootingItems)
        .where((item) {
          final matchesCategory =
              _selectedCategory == 'semua' ||
              item.category == _selectedCategory;

          final query = _query.toLowerCase().trim();
          final matchesQuery =
              query.isEmpty ||
              item.question.toLowerCase().contains(query) ||
              item.answer.toLowerCase().contains(query);

          return matchesCategory && matchesQuery;
        }).toList();

    if (items.isEmpty) {
      return _EmptyState(
        query: _query,
        category: _selectedCategory,
      );
    }

    return ListView.builder(
      key: PageStorageKey('help-page-$pageIndex'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ExpandableTile(
          key: ValueKey('${pageIndex}-${items[index].question}'),
          title: items[index].question,
          content: items[index].answer,
          leading: const QBadge(),
        );
      },
    );
  }
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class _FaqCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FaqCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.green500 : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.green500 : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : AppColors.text2,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? Colors.white : AppColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final String category;

  const _EmptyState({
    required this.query,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.green50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: AppColors.green500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              query.isNotEmpty
                  ? 'Tidak ada hasil untuk "$query"'
                  : 'Belum ada pertanyaan kategori "$category"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata kunci lain atau pilih kategori yang berbeda',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
