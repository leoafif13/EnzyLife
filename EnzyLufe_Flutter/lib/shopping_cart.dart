import 'package:flutter/material.dart';
import 'app_color.dart';
import 'widgets/sub_page_appbar.dart';
import 'belanja_page.dart';
import 'checkout_page.dart';
import 'detail_produk.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Set id produk yang dicentang
  final Set<String> _checked = {};

  static const _products = [
    Product(id: 'p1', name: 'Eco Enzim Tipe A',      description: 'Penjelasan singkat produk eco enzim tipe A', price: 300000, isPopular: true),
    Product(id: 'p2', name: 'Eco Enzim Tipe B',      description: 'Penjelasan singkat produk eco enzim tipe B', price: 250000),
    Product(id: 'p3', name: 'Eco Enzim Tipe C',      description: 'Penjelasan singkat produk eco enzim tipe C', price: 350000),
    Product(id: 'p4', name: 'Eco Enzim Starter Kit', description: 'Paket lengkap untuk pemula membuat eco enzim', price: 450000),
    Product(id: 'p5', name: 'Eco Enzim Premium',     description: 'Produk unggulan kualitas terjamin premium',   price: 500000),
  ];

  static Product? _find(String id) {
    try { return _products.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  static String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  @override
  void initState() {
    super.initState();
    CartState.instance.addListener(_onCartChanged);
    // Centang semua item saat buka keranjang
    _checked.addAll(CartState.instance.items.keys);
  }

  void _onCartChanged() {
    setState(() {
      // Hapus checked item yang sudah tidak ada di cart
      _checked.retainAll(CartState.instance.items.keys);
      // Tambah item baru otomatis tercentang
      for (final id in CartState.instance.items.keys) {
        _checked.add(id);
      }
    });
  }

  @override
  void dispose() {
    CartState.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  // Apakah semua item tercentang?
  bool get _allChecked {
    final keys = CartState.instance.items.keys.toList();
    return keys.isNotEmpty && keys.every(_checked.contains);
  }

  // Total harga item yang dicentang saja
  int get _checkedTotal {
    int total = 0;
    for (final id in _checked) {
      final p = _find(id);
      final qty = CartState.instance.qty(id);
      if (p != null) total += p.price * qty;
    }
    return total;
  }

  void _toggleAll(bool? val) {
    setState(() {
      if (val == true) {
        _checked.addAll(CartState.instance.items.keys);
      } else {
        _checked.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart  = CartState.instance;
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: SubPageAppBar(
        title: 'Keranjang',
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Kosongkan keranjang?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  content: const Text('Semua produk di keranjang akan dihapus.',
                      style: TextStyle(fontSize: 13)),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Batal')),
                    TextButton(
                      onPressed: () { cart.clear(); Navigator.of(context).pop(); },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              child: const Text('Hapus semua',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            ),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                // ── Select all + hint swipe ──────────
                Container(
                  color: AppColors.bgCard,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Checkbox pilih semua
                      SizedBox(
                        width: 24, height: 24,
                        child: Checkbox(
                          value: _allChecked,
                          onChanged: _toggleAll,
                          activeColor: AppColors.green500,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Pilih Semua (${items.length} produk)',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                              color: AppColors.text1)),
                      const Spacer(),
                      Icon(Icons.swipe_left_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('Geser untuk hapus',
                          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),

                // ── List produk ─────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    children: items.entries.map((e) {
                      final p = _find(e.key);
                      if (p == null) return const SizedBox.shrink();
                      return _CartItem(
                        key: ValueKey(e.key),
                        product: p,
                        qty: e.value,
                        checked: _checked.contains(e.key),
                        fmtPrice: _fmt,
                        onToggleCheck: (val) => setState(() {
                          if (val == true) _checked.add(e.key);
                          else _checked.remove(e.key);
                        }),
                        onAdd:    () => cart.add(p.id),
                        onRemove: () => cart.removeOne(p.id),
                        onDelete: () {
                          cart.removeAll(p.id);
                          _checked.remove(p.id);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // ── Summary + tombol checkout ────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                        blurRadius: 12, offset: const Offset(0, -2))],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    children: [
                      // Info item dipilih
                      Row(
                        children: [
                          Text('${_checked.length} produk dipilih',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          const Spacer(),
                          const Text('Total: ',
                              style: TextStyle(fontSize: 13, color: AppColors.text2)),
                          Text(_fmt(_checkedTotal),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                  color: AppColors.green500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _checked.isEmpty ? null : () {
                            // Kirim hanya item yang dicentang ke checkout
                            final selectedItems = {
                              for (final id in _checked)
                                id: cart.qty(id),
                            };
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CheckoutPage(
                                items: selectedItems,
                                allProducts: _products,
                              )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green500,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.green500.withOpacity(0.4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _checked.isEmpty
                                ? 'Pilih produk dulu'
                                : 'Checkout (${_checked.length})',
                            style: const TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w700),
                          ),
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

// ── Cart item dengan checkbox + swipe ─────────
class _CartItem extends StatelessWidget {
  final Product product;
  final int qty;
  final bool checked;
  final String Function(int) fmtPrice;
  final ValueChanged<bool?> onToggleCheck;
  final VoidCallback onAdd, onRemove, onDelete;

  const _CartItem({
    super.key,
    required this.product, required this.qty, required this.checked,
    required this.fmtPrice, required this.onToggleCheck,
    required this.onAdd, required this.onRemove, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss_${product.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        ),
        child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
          border: checked
              ? Border.all(color: AppColors.green500.withOpacity(0.4), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: checked,
                  onChanged: onToggleCheck,
                  activeColor: AppColors.green500,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
              ),
              const SizedBox(width: 10),

              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64, height: 64, color: AppColors.green50,
                  child: Icon(Icons.image_outlined, size: 24,
                      color: AppColors.green500.withOpacity(0.3)),
                  // TODO: ganti dengan Image.network/asset
                ),
              ),
              const SizedBox(width: 12),

              // Info produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.text1)),
                    const SizedBox(height: 4),
                    Text(fmtPrice(product.price),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.green500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Subtotal
                        Text('Subtotal: ${fmtPrice(product.price * qty)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        // Qty control
                        _QtyControl(qty: qty, onAdd: onAdd, onRemove: onRemove),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ── Qty control ───────────────────────────────
class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _QtyControl({required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        border: Border.all(color: AppColors.green500),
        borderRadius: BorderRadius.circular(8)),
    child: Row(
      children: [
        GestureDetector(onTap: onRemove,
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Icon(Icons.remove, size: 14, color: AppColors.green500))),
        Text('$qty', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: AppColors.green500)),
        GestureDetector(onTap: onAdd,
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Icon(Icons.add, size: 14, color: AppColors.green500))),
      ],
    ),
  );
}

// ── Empty state ───────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96, height: 96,
            decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_cart_outlined, size: 44, color: AppColors.green500),
          ),
          const SizedBox(height: 20),
          const Text('Keranjang kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 8),
          Text('Tambahkan produk dari halaman belanja',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green500, foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}