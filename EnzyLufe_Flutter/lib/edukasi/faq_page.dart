import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqItems = [
    _FaqItem(
      question: 'Apa itu Eco Enzim?',
      answer: '', // TODO: isi jawaban
    ),
    _FaqItem(
      question: 'Apa saja bahan untuk membuat eco enzim?',
      answer: '', // TODO: isi jawaban
    ),
    _FaqItem(
      question: 'Berapa lama waktu fermentasi eco enzim?',
      answer: '', // TODO: isi jawaban
    ),
    _FaqItem(
      question: 'Apakah aman digunakan untuk kulit?',
      answer: '', // TODO: isi jawaban
    ),
    _FaqItem(
      question: 'Berapa lama eco enzim dapat disimpan?',
      answer: '', // TODO: isi jawaban
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