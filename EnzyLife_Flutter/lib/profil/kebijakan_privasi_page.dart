import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  static const _sections = [
    _Section(
      title: '1. Informasi yang Kami Kumpulkan',
      content: '', // TODO: isi konten kebijakan privasi
    ),
    _Section(
      title: '2. Cara Kami Menggunakan Informasi',
      content: '', // TODO: isi konten
    ),
    _Section(
      title: '3. Keamanan Data',
      content: '', // TODO: isi konten
    ),
    _Section(
      title: '4. Hak Pengguna',
      content: '', // TODO: isi konten
    ),
    _Section(
      title: '5. Perubahan Kebijakan',
      content: '', // TODO: isi konten
    ),
    _Section(
      title: '6. Hubungi Kami',
      content: '', // TODO: isi konten
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Kebijakan Privasi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
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
                  const Text('Kebijakan Privasi',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppColors.text1)),
                  const SizedBox(height: 6),
                  Text('Terakhir diperbarui: April 2026', // TODO
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sections
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: List.generate(_sections.length, (i) {
                  final isLast = i == _sections.length - 1;
                  return Column(
                    children: [
                      _SectionTile(section: _sections[i]),
                      if (!isLast)
                        const Divider(height: 1, thickness: 1,
                            color: AppColors.divider, indent: 16, endIndent: 16),
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

class _Section {
  final String title, content;
  const _Section({required this.title, required this.content});
}

class _SectionTile extends StatefulWidget {
  final _Section section;
  const _SectionTile({super.key, required this.section});

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
                  child: Text(widget.section.title,
                      style: TextStyle(fontSize: 14,
                          fontWeight: _expanded ? FontWeight.w600 : FontWeight.w500,
                          color: _expanded ? AppColors.green500 : AppColors.text1,
                          height: 1.4)),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _expanded ? AppColors.green500 : Colors.grey[400], size: 22),
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
              child: widget.section.content.isNotEmpty
                  ? Text(widget.section.content,
                      style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6))
                  : Text('📝 TODO: isi konten kebijakan privasi bagian ini',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700],
                          fontStyle: FontStyle.italic)),
            ),
          ),
        ),
      ],
    );
  }
}