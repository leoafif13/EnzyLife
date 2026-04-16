import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  static const _green500 = Color(0xFF4CAF50);
  static const _green700 = Color(0xFF388E3C);
  static const _green900 = Color(0xFF1B5E20);
  static const _green50  = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          _ProfileHeader(),
          const SizedBox(height: 16),
          _StatsRow(),
          const SizedBox(height: 16),
          _MenuSection(title: 'Akun Saya', items: [
            _MenuItem(icon: Icons.person_outline_rounded,   label: 'Edit Profil',         onTap: () {}),
            _MenuItem(icon: Icons.lock_outline_rounded,     label: 'Ubah Password',       onTap: () {}),
            _MenuItem(icon: Icons.notifications_outlined,   label: 'Notifikasi',          onTap: () {}),
          ]),
          const SizedBox(height: 12),
          _MenuSection(title: 'Aktivitas', items: [
            _MenuItem(icon: Icons.shopping_bag_outlined,    label: 'Riwayat Pembelian',   onTap: () {}),
            _MenuItem(icon: Icons.bookmark_outline_rounded, label: 'Artikel Tersimpan',   onTap: () {}),
            _MenuItem(icon: Icons.calculate_outlined,       label: 'Riwayat Kalkulator',  onTap: () {}),
          ]),
          const SizedBox(height: 12),
          _MenuSection(title: 'Lainnya', items: [
            _MenuItem(icon: Icons.help_outline_rounded,     label: 'Bantuan',             onTap: () {}),
            _MenuItem(icon: Icons.info_outline_rounded,     label: 'Tentang Aplikasi', trailing: 'v1.0.0', onTap: () {}),
            _MenuItem(icon: Icons.privacy_tip_outlined,     label: 'Kebijakan Privasi',   onTap: () {}),
          ]),
          const SizedBox(height: 12),
          // Tombol logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Keluar dari akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: const Text('Kamu akan diarahkan ke halaman login.', style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                        },
                        child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                label: const Text('Keluar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  static const _green500 = Color(0xFF4CAF50);
  static const _green700 = Color(0xFF388E3C);
  static const _green50  = Color(0xFFE8F5E9);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          Stack(children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [_green500, _green700], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: const Center(
                child: Text('RA', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                // TODO: ganti dengan foto profil user: Image.network/asset dalam ClipOval
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: _green500, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.edit, size: 12, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rafi Akhbar', // TODO: dari session/auth
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                const SizedBox(height: 3),
                Text('rafi@email.com', // TODO: dari session/auth
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 13, color: _green500),
                      SizedBox(width: 4),
                      Text('Member Aktif', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _green500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  static const _green500 = Color(0xFF4CAF50);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        _Stat(value: '12', label: 'Artikel\nDibaca'),    // TODO: dari data user
        Container(width: 1, height: 36, color: const Color(0xFFF0F0F0)),
        _Stat(value: '5',  label: 'Produk\nDibeli'),     // TODO: dari data user
        Container(width: 1, height: 36, color: const Color(0xFFF0F0F0)),
        _Stat(value: '3',  label: 'Kalkulator\nDisimpan'), // TODO: dari data user
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  static const _green500 = Color(0xFF4CAF50);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _green500)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3)),
    ]),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.trailing, required this.onTap});
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({super.key, required this.title, required this.items});
  static const _green500 = Color(0xFF4CAF50);
  static const _green50  = Color(0xFFE8F5E9);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.3)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.vertical(
                        top: i == 0 ? const Radius.circular(16) : Radius.zero,
                        bottom: isLast ? const Radius.circular(16) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: _green50, borderRadius: BorderRadius.circular(10)),
                              child: Icon(item.icon, size: 18, color: _green500),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)))),
                            if (item.trailing != null) ...[
                              Text(item.trailing!, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                              const SizedBox(width: 4),
                            ],
                            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) Container(margin: const EdgeInsets.only(left: 66), height: 1, color: const Color(0xFFF5F5F5)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}