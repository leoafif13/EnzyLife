import 'package:flutter/material.dart';

enum HeaderAction {
  logout,
  list,
  cart,
  notification,
  edit,
  search,
  none, // kalau tidak mau ada icon kanan
}

// ─────────────────────────────────────────────
//  Widget utama: AppHeader
//
//  Cara pakai di tiap halaman:
//
//    AppHeader(action: HeaderAction.logout, onActionTap: () { ... })
//    AppHeader(action: HeaderAction.list,   onActionTap: () { ... })
//    AppHeader(action: HeaderAction.cart,   onActionTap: () { ... })
//    AppHeader(action: HeaderAction.none)   // tanpa tombol kanan
// ─────────────────────────────────────────────
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final HeaderAction action;
  final VoidCallback? onActionTap;

  const AppHeader({
    super.key,
    this.action = HeaderAction.none,
    this.onActionTap,
  });

  // ── Mapping enum → IconData ──────────────────
  static IconData _iconFor(HeaderAction action) {
    switch (action) {
      case HeaderAction.logout:       return Icons.logout_rounded;
      case HeaderAction.list:         return Icons.format_list_bulleted_rounded;
      case HeaderAction.cart:         return Icons.shopping_cart_outlined;
      case HeaderAction.notification: return Icons.notifications_outlined;
      case HeaderAction.edit:         return Icons.edit_outlined;
      case HeaderAction.search:       return Icons.search_rounded;
      case HeaderAction.none:         return Icons.close; // tidak ditampilkan
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,

      // ── Kiri: logo + nama aplikasi ─────────────
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 32, height: 32),
          const SizedBox(width: 8),
          const Text(
            'EnzyLife',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4CAF50),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),

      // ── Kanan: action icon dinamis ──────────────
      actions: [
        if (action != HeaderAction.none)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: onActionTap,
              icon: Icon(
                _iconFor(action),
                color: const Color(0xFF1A1A1A),
                size: 24,
              ),
              splashRadius: 22,
              tooltip: action.name,
            ),
          ),
      ],
    );
  }
}