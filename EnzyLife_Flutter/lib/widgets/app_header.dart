import 'package:flutter/material.dart';
import '../belanja_page.dart';

// ─────────────────────────────────────────────
//  Callback yang diterima header
// ─────────────────────────────────────────────
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;   // titik 3 — selalu ada
  final VoidCallback? onCartTap;   // ikon keranjang — selalu ada

  const AppHeader({
    super.key,
    this.onMenuTap,
    this.onCartTap,
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
    CartState.instance.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    CartState.instance.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Badge = jumlah ID unik (bukan total qty)
    final cartCount = CartState.instance.uniqueItems;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      titleSpacing: 16,

      // ── Kiri: logo + nama ───────────────────
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

      // ── Kanan: keranjang + titik 3 ──────────
      actions: [
        // Ikon keranjang + badge
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: widget.onCartTap,
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Color(0xFF1A1A1A), size: 24),
                splashRadius: 22,
                tooltip: 'Keranjang',
              ),
              if (cartCount > 0)
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
                        cartCount > 9 ? '9+' : '$cartCount',
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

        // Titik 3
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            onPressed: widget.onMenuTap,
            icon: const Icon(Icons.more_vert_rounded,
                color: Color(0xFF1A1A1A), size: 24),
            splashRadius: 22,
            tooltip: 'Menu',
          ),
        ),
      ],
    );
  }
}