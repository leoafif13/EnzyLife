import 'package:flutter/material.dart';
import '../belanja_page.dart';

// ─────────────────────────────────────────────
//  Enum action untuk header
// ─────────────────────────────────────────────
enum HeaderAction {
  logout, list, cart, notification, edit, search, none,
}

// ─────────────────────────────────────────────
//  AppHeader — StatefulWidget supaya bisa
//  menampilkan badge keranjang secara realtime
// ─────────────────────────────────────────────
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final HeaderAction action;
  final VoidCallback? onActionTap;

  const AppHeader({
    super.key,
    this.action = HeaderAction.none,
    this.onActionTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan cart supaya badge update otomatis
    CartState.instance.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    CartState.instance.removeListener(_refresh);
    super.dispose();
  }

  static IconData _iconFor(HeaderAction action) {
    switch (action) {
      case HeaderAction.logout:       return Icons.logout_rounded;
      case HeaderAction.list:         return Icons.format_list_bulleted_rounded;
      case HeaderAction.cart:         return Icons.shopping_cart_outlined;
      case HeaderAction.notification: return Icons.notifications_outlined;
      case HeaderAction.edit:         return Icons.edit_outlined;
      case HeaderAction.search:       return Icons.search_rounded;
      case HeaderAction.none:         return Icons.close;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = CartState.instance.totalItems;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
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
      actions: [
        if (widget.action != HeaderAction.none)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: widget.onActionTap,
                  icon: Icon(
                    _iconFor(widget.action),
                    color: const Color(0xFF1A1A1A),
                    size: 24,
                  ),
                  splashRadius: 22,
                  tooltip: widget.action.name,
                ),
                // Badge jumlah item keranjang — hanya tampil di tab Belanja
                if (widget.action == HeaderAction.cart && cartTotal > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          cartTotal > 9 ? '9+' : '$cartTotal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}