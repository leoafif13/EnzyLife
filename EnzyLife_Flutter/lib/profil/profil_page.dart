import 'package:flutter/material.dart';
import '../app_color.dart';
import '../auth/login_page.dart';
import 'edit_profil_page.dart';
import 'ubah_password_page.dart';
// import 'notifikasi_page.dart';
import 'riwayat_belanja_page.dart';
// import 'artikel_tersimpan_page.dart';
// import 'riwayat_kalkulator_page.dart';
import 'bantuan_page.dart';
import 'tentang_aplikasi_page.dart';
import 'kebijakan_privasi_page.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../belanja/belanja_page.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {

  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {

    final result = await ApiService.getProfile();

    if (!mounted) return;

    setState(() {
      user = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          _ProfileHeader(
            user: user,
          ),
          const SizedBox(height: 16),
          _MenuSection(title: 'Akun Saya', items: [
            _MenuItem(icon: Icons.person_outline_rounded,   label: 'Edit Profil',        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfilScreen()))),
            _MenuItem(icon: Icons.lock_outline_rounded,     label: 'Ubah Password',      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UbahPasswordScreen()))),
            _MenuItem(icon: Icons.shopping_bag_outlined,    label: 'Riwayat Pembelian',  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RiwayatBelanjaScreen()))),
          ]),
          const SizedBox(height: 12),
          _MenuSection(title: 'Lainnya', items: [
            _MenuItem(icon: Icons.help_outline_rounded,     label: 'Bantuan',            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BantuanScreen()))),
            _MenuItem(icon: Icons.info_outline_rounded,     label: 'Tentang Aplikasi',   trailing: 'v1.0.0', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TentangAplikasiScreen()))),
            _MenuItem(icon: Icons.privacy_tip_outlined,     label: 'Kebijakan Privasi',  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KebijakanPrivasiScreen()))),
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
                    title: const Text('Keluar dari akun?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: const Text('Kamu akan diarahkan ke halaman login.',
                        style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal')),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();

                          await AuthService.logout();
                          CartState.instance.clearMemoryOnly();

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Berhasil logout'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (r) => false,
                          );
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                label: const Text('Keluar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red)),
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

// ── Profile header ────────────────────────────
class _ProfileHeader extends StatelessWidget {

  final UserModel? user;

  const _ProfileHeader({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.green500, AppColors.green700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(getInitials(user?.name ?? ''),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? '-',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text1),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '-',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String getInitials(String name) {

  if (name.trim().isEmpty) {
    return '?';
  }

  final words = name.trim().split(' ');

  if (words.length >= 2) {
    return words[0][0].toUpperCase() +
        words[1][0].toUpperCase();
  }

  return words[0][0].toUpperCase();
}

// ── Stats row (Disabled) ──────────────────────
// class _StatsRow extends StatelessWidget {
//   const _StatsRow();
// 
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       decoration: BoxDecoration(
//         color: AppColors.bgCard,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: AppColors.cardShadow,
//       ),
//       child: Row(
//         children: [
//           _Stat(value: '12', label: 'Artikel\nDibaca'),
//           Container(width: 1, height: 36, color: AppColors.divider),
//           _Stat(value: '5',  label: 'Produk\nDibeli'),
//           Container(width: 1, height: 36, color: AppColors.divider),
//           _Stat(value: '3',  label: 'Kalkulator\nDisimpan'),
//         ],
//       ),
//     );
//   }
// }
// 
// class _Stat extends StatelessWidget {
//   final String value, label;
//   const _Stat({required this.value, required this.label});
// 
//   @override
//   Widget build(BuildContext context) => Expanded(
//     child: Column(
//       children: [
//         Text(value,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.green500)),
//         const SizedBox(height: 4),
//         Text(label,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.3)),
//       ],
//     ),
//   );
// }

// ── Menu section ──────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4),
            child: Text(title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: Colors.grey[500], letterSpacing: 0.3)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final item   = items[i];
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.vertical(
                        top:    i == 0   ? const Radius.circular(16) : Radius.zero,
                        bottom: isLast   ? const Radius.circular(16) : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                  color: AppColors.green50, borderRadius: BorderRadius.circular(10)),
                              child: Icon(item.icon, size: 18, color: AppColors.green500),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(item.label,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                                    color: AppColors.text1))),
                            if (item.trailing != null) ...[
                              Text(item.trailing!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                              const SizedBox(width: 4),
                            ],
                            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                          margin: const EdgeInsets.only(left: 66),
                          height: 1,
                          color: const Color(0xFFF5F5F5)),
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