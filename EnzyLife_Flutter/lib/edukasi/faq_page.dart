import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqItems = [
    _FaqItem(
      question: 'Apa itu Eco Enzim?',
      answer:
          'Eco Enzim adalah cairan hasil fermentasi limbah organik seperti kulit buah dan sayuran yang dicampur dengan gula dan air. Cairan ini dapat dimanfaatkan untuk berbagai keperluan rumah tangga seperti pembersih alami, pupuk cair, hingga penghilang bau.',
    ),

    _FaqItem(
      question: 'Apa saja bahan untuk membuat eco enzim?',
      answer:
          'Eco Enzim dibuat dari tiga bahan utama yaitu air, gula merah atau molase, dan limbah organik berupa kulit buah atau sayuran. Perbandingan yang umum digunakan adalah 10 bagian air, 1 bagian gula, dan 3 bagian limbah organik.',
    ),

    _FaqItem(
      question: 'Berapa lama waktu fermentasi eco enzim?',
      answer:
          'Proses fermentasi Eco Enzim umumnya memerlukan waktu sekitar 3 bulan atau 90 hari. Selama proses tersebut, wadah harus disimpan di tempat yang teduh dan sesekali dibuka pada bulan pertama untuk mengeluarkan gas hasil fermentasi.',
    ),

    _FaqItem(
      question: 'Apakah aman digunakan untuk kulit?',
      answer:
          'Eco Enzim yang telah matang umumnya aman digunakan setelah diencerkan dengan air. Namun, karena tingkat keasaman setiap hasil fermentasi bisa berbeda, disarankan untuk melakukan uji coba pada area kecil kulit terlebih dahulu dan menghindari penggunaan pada kulit yang sensitif atau luka terbuka.',
    ),

    _FaqItem(
      question: 'Berapa lama eco enzim dapat disimpan?',
      answer:
          'Eco Enzim dapat disimpan dalam jangka waktu yang sangat lama selama disimpan dalam wadah tertutup dengan baik dan tidak terkontaminasi. Bahkan kualitasnya cenderung semakin baik seiring waktu karena proses fermentasi alami masih terus berlangsung.',
    ),

    _FaqItem(
      question: 'Apa manfaat eco enzim bagi lingkungan?',
      answer:
          'Eco Enzim membantu mengurangi jumlah sampah organik yang berakhir di tempat pembuangan akhir. Selain itu, penggunaan Eco Enzim juga dapat mengurangi ketergantungan pada bahan kimia pembersih yang berpotensi mencemari lingkungan.',
    ),

    _FaqItem(
      question: 'Mengapa wadah fermentasi tidak boleh diisi penuh?',
      answer:
          'Selama proses fermentasi akan terbentuk gas alami. Jika wadah diisi terlalu penuh, tekanan gas dapat meningkat dan menyebabkan wadah menggelembung atau bahkan rusak. Sisakan sekitar 20% ruang kosong di dalam wadah.',
    ),

    _FaqItem(
      question: 'Apa yang harus dilakukan jika muncul lapisan putih di permukaan?',
      answer:
          'Lapisan putih tipis biasanya merupakan mikroorganisme alami yang tidak berbahaya dan masih tergolong normal dalam proses fermentasi. Lapisan tersebut dapat diaduk atau disaring saat panen Eco Enzim.',
    ),

    _FaqItem(
      question: 'Bisakah eco enzim digunakan sebagai pupuk tanaman?',
      answer:
          'Ya. Eco Enzim dapat digunakan sebagai pupuk cair organik setelah diencerkan dengan air. Kandungan hasil fermentasinya dapat membantu menyuburkan tanah dan mendukung pertumbuhan tanaman.',
    ),

    _FaqItem(
      question: 'Bagaimana cara menggunakan eco enzim sebagai pembersih?',
      answer:
          'Eco Enzim dapat dicampur dengan air sesuai kebutuhan lalu digunakan untuk membersihkan lantai, kamar mandi, dapur, kaca, maupun permukaan rumah lainnya. Pengenceran dapat disesuaikan tergantung tingkat kotoran yang akan dibersihkan.',
    ),
    _FaqItem(
      question: 'Apakah semua jenis kulit buah bisa digunakan?',
      answer:
          'Sebagian besar kulit buah dan sayuran dapat digunakan untuk membuat Eco Enzim. Namun, sebaiknya hindari bahan yang berminyak, mengandung banyak garam, atau sudah membusuk karena dapat mengganggu proses fermentasi.',
    ),

    _FaqItem(
      question: 'Apakah eco enzim memiliki bau yang menyengat?',
      answer:
          'Eco Enzim yang berhasil difermentasi biasanya memiliki aroma asam manis khas fermentasi. Jika muncul bau busuk yang sangat menyengat, kemungkinan terjadi kesalahan dalam proses pembuatan atau kontaminasi.',
    ),

    _FaqItem(
      question: 'Mengapa botol fermentasi menghasilkan gas?',
      answer:
          'Gas terbentuk karena aktivitas mikroorganisme yang menguraikan bahan organik selama proses fermentasi. Hal ini merupakan proses yang normal terutama pada bulan pertama fermentasi.',
    ),

    _FaqItem(
      question: 'Apakah eco enzim bisa diminum?',
      answer:
          'Tidak. Eco Enzim tidak dirancang untuk dikonsumsi sebagai makanan atau minuman. Penggunaannya ditujukan untuk kebutuhan rumah tangga, kebersihan, pertanian, dan lingkungan.',
    ),

    _FaqItem(
      question: 'Bagaimana cara mengetahui eco enzim sudah matang?',
      answer:
          'Eco Enzim yang matang biasanya berwarna cokelat gelap, memiliki aroma asam segar khas fermentasi, dan tidak menghasilkan gas berlebih seperti pada awal proses fermentasi.',
    ),

    _FaqItem(
      question: 'Apa yang dilakukan dengan ampas setelah panen eco enzim?',
      answer:
          'Ampas hasil fermentasi dapat dimanfaatkan sebagai kompos organik atau dicampurkan ke tanah sebagai bahan penyubur tanaman.',
    ),

    _FaqItem(
      question: 'Bisakah eco enzim digunakan untuk menghilangkan bau?',
      answer:
          'Ya. Eco Enzim sering digunakan sebagai penghilang bau alami pada tempat sampah, saluran air, kandang hewan, maupun area lain yang memiliki aroma tidak sedap.',
    ),

    _FaqItem(
      question: 'Apakah eco enzim dapat digunakan untuk membersihkan saluran air?',
      answer:
          'Ya. Eco Enzim dapat dituangkan ke saluran air secara berkala untuk membantu mengurangi bau dan membantu menguraikan sisa bahan organik yang menumpuk.',
    ),

    _FaqItem(
      question: 'Apakah warna eco enzim selalu sama?',
      answer:
          'Tidak. Warna Eco Enzim dapat berbeda tergantung bahan yang digunakan. Umumnya berwarna cokelat muda hingga cokelat tua setelah proses fermentasi selesai.',
    ),

    _FaqItem(
      question: 'Mengapa eco enzim disebut ramah lingkungan?',
      answer:
          'Karena Eco Enzim dibuat dari limbah organik yang didaur ulang dan dapat menggantikan sebagian penggunaan bahan kimia rumah tangga sehingga membantu mengurangi pencemaran lingkungan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'FAQ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
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
                    'FAQ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daftar tanya jawab seputar Eco Enzim',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FAQ accordion
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: List.generate(_faqItems.length, (i) {
                  final isLast = i == _faqItems.length - 1;
                  return Column(
                    children: [
                      _FaqTile(item: _faqItems[i]),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.divider,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

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
    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Q : ${widget.item.question}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _expanded ? FontWeight.w600 : FontWeight.w500,
                      color: _expanded ? AppColors.green500 : AppColors.text1,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
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
        ),
      ],
    );
  }
}