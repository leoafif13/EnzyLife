import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const _faqItems = [
    _Item(q: 'Bagaimana cara memesan produk?',
        a: 'Pilih produk di halaman Belanja, klik tombol Beli, lalu selesaikan pembayaran melalui halaman Checkout.'), // TODO: sesuaikan
    _Item(q: 'Bagaimana cara melacak pesanan saya?',
        a: 'Buka menu Profil → Riwayat Belanja, lalu pilih pesanan dengan status "Dikirim" dan klik "Lihat proses pengantaran".'),
    _Item(q: 'Apakah produk bisa dikembalikan?',
        a: ''), // TODO: isi kebijakan pengembalian
    _Item(q: 'Bagaimana cara menghubungi customer service?',
        a: ''), // TODO: isi info kontak CS
    _Item(q: 'Metode pembayaran apa saja yang tersedia?',
        a: ''), // TODO: isi metode pembayaran
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Bantuan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontak langsung
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green900, AppColors.green700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Butuh bantuan lebih?',
                      style: TextStyle(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Tim kami siap membantu kamu',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ContactButton(
                        icon: Icons.chat_outlined,
                        label: 'Live Chat',
                        onTap: () {}, // TODO: buka live chat
                      ),
                      const SizedBox(width: 10),
                      _ContactButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () {}, // TODO: buka email
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Pertanyaan Umum',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text1)),
            const SizedBox(height: 14),

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

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Item {
  final String q, a;
  const _Item({required this.q, required this.a});
}

class _FaqTile extends StatefulWidget {
  final _Item item;
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
                  child: Text(widget.item.q,
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
              child: widget.item.a.isNotEmpty
                  ? Text(widget.item.a,
                      style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6))
                  : Text('📝 TODO: isi jawaban untuk pertanyaan ini',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700],
                          fontStyle: FontStyle.italic)),
            ),
          ),
        ),
      ],
    );
  }
}