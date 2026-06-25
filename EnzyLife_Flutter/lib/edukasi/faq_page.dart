import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../widgets/page_header_card.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/chatbot_widget.dart';

// ══════════════════════════════════════════════
//  FAQ Screen
// ══════════════════════════════════════════════
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _query = '';
  String _selectedCategory = 'semua';
  final _search = TextEditingController();

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
          'Proses fermentasi Eco Enzim umumnya memerlukan waktu sekitar 3 bulan atau 90 hari. Selama proses tersebut, wadah harus disimpan di tempat yang teduh dan sesekali dibuka pada bulan pertama untuk mengeluarkan gas hasil fermentasi.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah aman digunakan untuk kulit?',
      answer:
          'Eco Enzim yang telah matang umumnya aman digunakan setelah diencerkan dengan air. Namun, karena tingkat keasaman setiap hasil fermentasi bisa berbeda, disarankan untuk melakukan uji coba pada area kecil kulit terlebih dahulu dan menghindari penggunaan pada kulit yang sensitif atau luka terbuka.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Berapa lama eco enzim dapat disimpan?',
      answer:
          'Eco Enzim dapat disimpan dalam jangka waktu yang sangat lama selama disimpan dalam wadah tertutup dengan baik dan tidak terkontaminasi. Bahkan kualitasnya cenderung semakin baik seiring waktu karena proses fermentasi alami masih terus berlangsung.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Apa manfaat eco enzim bagi lingkungan?',
      answer:
          'Eco Enzim membantu mengurangi jumlah sampah organik yang berakhir di tempat pembuangan akhir. Selain itu, penggunaan Eco Enzim juga dapat mengurangi ketergantungan pada bahan kimia pembersih yang berpotensi mencemari lingkungan.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Mengapa wadah fermentasi tidak boleh diisi penuh?',
      answer:
          'Selama proses fermentasi akan terbentuk gas alami. Jika wadah diisi terlalu penuh, tekanan gas dapat meningkat dan menyebabkan wadah menggelembung atau bahkan rusak. Sisakan sekitar 20% ruang kosong di dalam wadah.',
    ),
    _FaqItem(
      category: 'masalah',
      question: 'Apa yang harus dilakukan jika muncul lapisan putih di permukaan?',
      answer:
          'Lapisan putih tipis biasanya merupakan mikroorganisme alami yang tidak berbahaya dan masih tergolong normal dalam proses fermentasi. Lapisan tersebut dapat diaduk atau disaring saat panen Eco Enzim.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bisakah eco enzim digunakan sebagai pupuk tanaman?',
      answer:
          'Ya. Eco Enzim dapat digunakan sebagai pupuk cair organik setelah diencerkan dengan air. Kandungan hasil fermentasinya dapat membantu menyuburkan tanah dan mendukung pertumbuhan tanaman.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bagaimana cara menggunakan eco enzim sebagai pembersih?',
      answer:
          'Eco Enzim dapat dicampur dengan air sesuai kebutuhan lalu digunakan untuk membersihkan lantai, kamar mandi, dapur, kaca, maupun permukaan rumah lainnya. Pengenceran dapat disesuaikan tergantung tingkat kotoran yang akan dibersihkan.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Apakah semua jenis kulit buah bisa digunakan?',
      answer:
          'Sebagian besar kulit buah dan sayuran dapat digunakan untuk membuat Eco Enzim. Namun, sebaiknya hindari bahan yang berminyak, mengandung banyak garam, atau sudah membusuk karena dapat mengganggu proses fermentasi.',
    ),
    _FaqItem(
      category: 'masalah',
      question: 'Apakah eco enzim memiliki bau yang menyengat?',
      answer:
          'Eco Enzim yang berhasil difermentasi biasanya memiliki aroma asam manis khas fermentasi. Jika muncul bau busuk yang sangat menyengat, kemungkinan terjadi kesalahan dalam proses pembuatan atau kontaminasi.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Mengapa botol fermentasi menghasilkan gas?',
      answer:
          'Gas terbentuk karena aktivitas mikroorganisme yang menguraikan bahan organik selama proses fermentasi. Hal ini merupakan proses yang normal terutama pada bulan pertama fermentasi.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah eco enzim bisa diminum?',
      answer:
          'Tidak. Eco Enzim tidak dirancang untuk dikonsumsi sebagai makanan atau minuman. Penggunaannya ditujukan untuk kebutuhan rumah tangga, kebersihan, pertanian, dan lingkungan.',
    ),
    _FaqItem(
      category: 'pembuatan',
      question: 'Bagaimana cara mengetahui eco enzim sudah matang?',
      answer:
          'Eco Enzim yang matang biasanya berwarna cokelat gelap, memiliki aroma asam segar khas fermentasi, dan tidak menghasilkan gas berlebih seperti pada awal proses fermentasi.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apa yang dilakukan dengan ampas setelah panen eco enzim?',
      answer:
          'Ampas hasil fermentasi dapat dimanfaatkan sebagai kompos organik atau dicampurkan ke tanah sebagai bahan penyubur tanaman.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Bisakah eco enzim digunakan untuk menghilangkan bau?',
      answer:
          'Ya. Eco Enzim sering digunakan sebagai penghilang bau alami pada tempat sampah, saluran air, kandang hewan, maupun area lain yang memiliki aroma tidak sedap.',
    ),
    _FaqItem(
      category: 'penggunaan',
      question: 'Apakah eco enzim dapat digunakan untuk membersihkan saluran air?',
      answer:
          'Ya. Eco Enzim dapat dituangkan ke saluran air secara berkala untuk membantu mengurangi bau dan membantu menguraikan sisa bahan organik yang menumpuk.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Apakah warna eco enzim selalu sama?',
      answer:
          'Tidak. Warna Eco Enzim dapat berbeda tergantung bahan yang digunakan. Umumnya berwarna cokelat muda hingga cokelat tua setelah proses fermentasi selesai.',
    ),
    _FaqItem(
      category: 'umum',
      question: 'Mengapa eco enzim disebut ramah lingkungan?',
      answer:
          'Karena Eco Enzim dibuat dari limbah organik yang didaur ulang dan dapat menggantikan sebagian penggunaan bahan kimia rumah tangga sehingga membantu mengurangi pencemaran lingkungan.',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _faqItems.where((item) {
      final matchesCategory = _selectedCategory == 'semua' || item.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          item.question.toLowerCase().contains(_query.toLowerCase()) ||
          item.answer.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'FAQ'),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
        children: [
          // ── Sticky Header Card ──────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: const PageHeaderCard(
              badge: '❓  FAQ',
              title: 'FAQ',
              subtitle: 'Daftar tanya jawab seputar Eco Enzim',
              icon: Icons.help_outline_rounded,
            ),
          ),

          // ── Sticky Search Bar ───────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SearchBarField(
              controller: _search,
              hintText: 'Cari pertanyaan atau jawaban...',
              onChanged: (v) => setState(() => _query = v),
              showClearButton: _query.isNotEmpty,
              onClear: () {
                setState(() => _query = '');
                _search.clear();
              },
            ),
          ),

          // ── Sticky Category Chips ────────────────
          Container(
            color: AppColors.bgPage,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FaqCategoryChip(
                    label: 'Semua',
                    icon: Icons.all_inclusive,
                    active: _selectedCategory == 'semua',
                    onTap: () => setState(() => _selectedCategory = 'semua'),
                  ),
                  const SizedBox(width: 8),
                  _FaqCategoryChip(
                    label: 'Umum',
                    icon: Icons.info_outline_rounded,
                    active: _selectedCategory == 'umum',
                    onTap: () => setState(() => _selectedCategory = 'umum'),
                  ),
                  const SizedBox(width: 8),
                  _FaqCategoryChip(
                    label: 'Pembuatan',
                    icon: Icons.build_circle_outlined,
                    active: _selectedCategory == 'pembuatan',
                    onTap: () => setState(() => _selectedCategory = 'pembuatan'),
                  ),
                  const SizedBox(width: 8),
                  _FaqCategoryChip(
                    label: 'Penggunaan',
                    icon: Icons.settings_suggest_outlined,
                    active: _selectedCategory == 'penggunaan',
                    onTap: () => setState(() => _selectedCategory = 'penggunaan'),
                  ),
                  const SizedBox(width: 8),
                  _FaqCategoryChip(
                    label: 'Masalah',
                    icon: Icons.report_problem_outlined,
                    active: _selectedCategory == 'masalah',
                    onTap: () => setState(() => _selectedCategory = 'masalah'),
                  ),
                ],
              ),
            ),
          ),

          // ── List FAQ ─────────────────────────────
          Expanded(
            child: filteredFaq.isEmpty
                ? _EmptyState(query: _query, category: _selectedCategory)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredFaq.length,
                    itemBuilder: (context, index) {
                      return _FaqTile(
                        key: ValueKey(filteredFaq[index].question),
                        item: filteredFaq[index],
                      );
                    },
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

// ── FAQ Item Model ────────────────────────────
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

// ── Category Chip Widget ───────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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

// ── Accordion Tile Widget ──────────────────────
class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({super.key, required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: _expanded ? AppColors.green200 : AppColors.border.withAlpha(80),
          width: _expanded ? 1.2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _expanded ? AppColors.green500 : Colors.transparent,
                width: 4.5,
              ),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Row(
                    children: [
                      // Question indicator bubble
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _expanded ? AppColors.green500 : AppColors.green50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'Q',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _expanded ? Colors.white : AppColors.green700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.item.question,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _expanded ? FontWeight.w700 : FontWeight.w600,
                            color: _expanded ? AppColors.green700 : AppColors.text1,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _expanded ? AppColors.green500 : Colors.grey[400],
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _anim,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(52, 4, 16, 16),
                  color: AppColors.green50.withAlpha(100),
                  child: widget.item.answer.isNotEmpty
                      ? Text(
                          widget.item.answer,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.text2,
                            height: 1.6,
                          ),
                        )
                      : Text(
                          '📝 TODO: isi jawaban untuk pertanyaan ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State Widget ─────────────────────────
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