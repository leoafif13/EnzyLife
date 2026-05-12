import 'package:flutter/material.dart';
import '/app_color.dart';

// ══════════════════════════════════════════════
//  SubPageAppBar — AppBar standar untuk halaman
//  yang dibuka via Navigator.push (bukan tab utama)
//
//  Cara pakai:
//    appBar: SubPageAppBar(title: 'Judul Halaman')
//    appBar: SubPageAppBar(title: 'Detail', actions: [...])
// ══════════════════════════════════════════════
class SubPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SubPageAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgCard,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.text1,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.text1,
        ),
      ),
      actions: actions,
    );
  }
}