import 'package:flutter/material.dart';
import '../app_color.dart';
import '../models/product.dart';
import '../widgets/sub_page_appbar.dart';
import 'belanja_page.dart';
import 'checkout_page.dart';
import '../services/api_service.dart';
import '../services/format_helper.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> get _products => ApiService.cachedProducts;
  final Set<int> _checked = {};
  bool _isLoading = false;

  static String _fmt(int price) => formatPrice(price);

  @override
  void initState() {
    super.initState();
    CartState.instance.addListener(_onCartChanged);
    _checked.addAll(CartState.instance.items.keys);
    if (ApiService.cachedProducts.isEmpty) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await ApiService.getProducts();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _checked.addAll(CartState.instance.items.keys);
      });
    }
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
      final p = _products.firstWhere(
        (x) => x.id == id,
      );

      final qty = CartState.instance.qty(id);

      total += p.price * qty;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green500))
          : items.isEmpty
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
                      Expanded(
                        child: Text('Pilih Semua (${items.length} produk)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                color: AppColors.text1)),
                      ),
                      const SizedBox(width: 8),
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
                      final p = _products.firstWhere(
                        (x) => x.id == e.key,
                      );

                      return CartItemTile(
                        key: ValueKey(e.key),
                        product: p,
                        qty: e.value,
                        checked: _checked.contains(e.key),
                        fmtPrice: _fmt,
                        onToggleCheck: (val) => setState(() {
                          if (val == true) {
                            _checked.add(e.key);
                          } else {
                            _checked.remove(e.key);
                          }
                        }),
                        onAdd: () {
                          if (cart.qty(p.id) < p.stock) {
                            cart.add(p.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Batas stok maksimum tercapai (${p.stock} item)'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.orange[800],
                              ),
                            );
                          }
                        },
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
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(20),
                        blurRadius: 12, offset: const Offset(0, -2))],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  child: Column(
                    children: [
                      // Info item dipilih
                      Row(
                        children: [
                          Flexible(
                            child: Text('${_checked.length} produk dipilih',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ),
                          const Spacer(),
                          const Text('Total: ',
                              style: TextStyle(fontSize: 13, color: AppColors.text2)),
                          Flexible(
                            child: Text(_fmt(_checkedTotal),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                    color: AppColors.green500)),
                          ),
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
                            disabledBackgroundColor: AppColors.green500.withAlpha(102),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _checked.isEmpty
                                ? 'Pilih produk dulu'
                                : 'Lanjutkan Pembayaran (${_checked.length})',
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