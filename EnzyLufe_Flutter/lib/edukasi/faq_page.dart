import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqItems = [
    _FaqItem(
      question: 'Apa itu Eco Enzim?',
      // TODO: ganti dengan jawaban lengkap
      answer: '',
    ),
    _FaqItem(
      question: 'Apa saja bahan untuk membuat eco enzim?',
      // TODO: ganti dengan jawaban lengkap
      answer: '',
    ),
    _FaqItem(
      question: 'Berapa lama waktu fermentasi eco enzim?',
      // TODO: ganti dengan jawaban lengkap
      answer: '',
    ),
    _FaqItem(
      question: 'Apakah aman digunakan untuk kulit?',
      // TODO: ganti dengan jawaban lengkap
      answer: '',
    ),
    _FaqItem(
      question: 'Berapa lama eco enzim dapat disimpan?',
      // TODO: ganti dengan jawaban lengkap
      answer: '',
    ),
    _FaqItem(
      question: 'Berapa lama eco enzim dapat disimpan?',
      // TODO: ganti dengan jawaban lengkap (item duplikat sesuai referensi)
      answer: '',
    ),
  ];

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
          'FAQ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'FAQ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daftar tanya jawab seputar Eco Enzim',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FAQ list
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                children: List.generate(_faqItems.length, (i) {
                  final isLast = i == _faqItems.length - 1;
                  return Column(
                    children: [
                      _FaqTile(item: _faqItems[i], index: i),
                      if (!isLast)
                        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0), indent: 16, endIndent: 16),
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
  final int index;
  const _FaqTile({super.key, required this.item, required this.index});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnim;

  static const _green500 = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animController.forward() : _animController.reverse();
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
                      color: _expanded ? _green500 : const Color(0xFF1A1A1A),
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
                    color: _expanded ? _green500 : Colors.grey[400],
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: widget.item.answer.isNotEmpty
                  ? Text(
                      widget.item.answer,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6),
                    )
                  : Text(
                      '📝 TODO: isi jawaban untuk pertanyaan ini',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700], fontStyle: FontStyle.italic),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}