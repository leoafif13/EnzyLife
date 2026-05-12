import 'package:flutter/material.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
 
// ─────────────────────────────────────────────
//  Widget utama: AppBottomNavBar
//  Cara pakai:
//    AppBottomNavBar(
//      currentIndex: _selectedIndex,
//      onTap: (i) => setState(() => _selectedIndex = i),
//    )
// ─────────────────────────────────────────────
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
 
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
 
  static const _items = [
    _NavItem(icon: Icons.home_outlined,       label: 'Beranda'),
    _NavItem(icon: Icons.menu_book_outlined,  label: 'Edukasi'),
    _NavItem(icon: Icons.shopping_cart_outlined, label: 'Belanja'),
    _NavItem(icon: Icons.person_outline,      label: 'Akun'),
  ];
 
  static const _green      = Color(0xFF4CAF50);
  static const _navBg      = Color(0xFFF0F0F0);
  static const _iconColor  = Color(0xFF1A1A1A);
  static const _pillHeight = 44.0;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: _navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemWidth  = totalWidth / _items.length;
 
          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Sliding green pill ──────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: currentIndex * itemWidth + 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: itemWidth - 16,
                  height: _pillHeight,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(_pillHeight / 2),
                  ),
                ),
              ),
 
              // ── Nav items ───────────────────────────
              Row(
                children: List.generate(_items.length, (i) {
                  final selected = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: SizedBox(
                        height: double.infinity,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: selected
                              ? _SelectedItem(item: _items[i], key: ValueKey('sel_$i'))
                              : _UnselectedItem(item: _items[i], key: ValueKey('uns_$i')),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

//  Item aktif
class _SelectedItem extends StatelessWidget {
  final _NavItem item;
  const _SelectedItem({super.key, required this.item});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, size: 22, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

//  Item tidak aktif
class _UnselectedItem extends StatelessWidget {
  final _NavItem item;
  const _UnselectedItem({super.key, required this.item});
 
  static const _iconColor = Color(0xFF1A1A1A);
 
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(item.icon, size: 24, color: _iconColor),
    );
  }
}