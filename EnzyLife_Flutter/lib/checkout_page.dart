import 'package:flutter/material.dart';
import 'app_color.dart';
import 'widgets/sub_page_appbar.dart';
import 'belanja_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, int> items;
  final List<Product> allProducts;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.allProducts,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  _DeliveryMethod _method = _DeliveryMethod.ambilSendiri;
  String _paymentMethod   = 'Transfer Bank';
  bool _isLoading         = false;

  final _namaController    = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController  = TextEditingController();
  final _kotaController    = TextEditingController();
  final _kodeposController = TextEditingController();

  static const _ongkir    = 15000;
  static const _biayaAdmin = 2000;
  static const _labInfo   = 'Lab EnzyLife\nJl. Batam Center No. 10\nBatam, Kepulauan Riau\nSenin–Sabtu, 08.00–17.00 WIB'; // TODO

  static const _paymentOptions = [
    'Transfer Bank',
    'QRIS',
    'COD (Bayar di Tempat)',
    'Dompet Digital',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _kodeposController.dispose();
    super.dispose();
  }

  int get _subtotal {
    int total = 0;
    for (final e in widget.items.entries) {
      try {
        final p = widget.allProducts.firstWhere((p) => p.id == e.key);
        total += p.price * e.value;
      } catch (_) {}
    }
    return total;
  }

  int get _ongkirTotal => _method == _DeliveryMethod.diantar ? _ongkir : 0;
  int get _grandTotal  => _subtotal + _ongkirTotal + _biayaAdmin;

  static String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  Future<void> _bayar() async {
    if (_method == _DeliveryMethod.diantar) {
      if (_namaController.text.isEmpty || _alamatController.text.isEmpty ||
          _kotaController.text.isEmpty || _teleponController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Lengkapi alamat pengiriman terlebih dahulu'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        return;
      }
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // TODO: request API order
    setState(() => _isLoading = false);
    if (!mounted) return;
    CartState.instance.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.green50, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.green500),
            ),
            const SizedBox(height: 16),
            const Text('Pesanan Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text1)),
            const SizedBox(height: 8),
            Text(
              _method == _DeliveryMethod.ambilSendiri
                  ? 'Silakan ambil pesanan di lab sesuai jadwal.'
                  : 'Pesanan akan segera dikirim ke alamat kamu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500, foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _paymentIcon(String m) {
    switch (m) {
      case 'Transfer Bank':         return Icons.account_balance_outlined;
      case 'QRIS':                  return Icons.qr_code_scanner_outlined;
      case 'COD (Bayar di Tempat)': return Icons.payments_outlined;
      case 'Dompet Digital':        return Icons.wallet_outlined;
      default:                       return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Checkout'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Ringkasan produk ──
                  _SectionCard(
                    title: 'Produk Dipesan',
                    child: Column(
                      children: widget.items.entries.map((e) {
                        Product? p;
                        try { p = widget.allProducts.firstWhere((x) => x.id == e.key); } catch (_) {}
                        if (p == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 52, height: 52, color: AppColors.green50,
                                  child: Icon(Icons.image_outlined, size: 20,
                                      color: AppColors.green500.withOpacity(0.3)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w600, color: AppColors.text1)),
                                    Text('${e.value}x · ${_fmt(p.price)}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                  ],
                                ),
                              ),
                              Text(_fmt(p.price * e.value),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AppColors.text1)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Metode pengambilan ──
                  _SectionCard(
                    title: 'Metode Pengambilan',
                    child: Column(
                      children: [
                        _MethodTile(
                          icon: Icons.store_outlined,
                          label: 'Ambil Sendiri di Lab',
                          desc: 'Gratis, ambil langsung di laboratorium',
                          selected: _method == _DeliveryMethod.ambilSendiri,
                          onTap: () => setState(() => _method = _DeliveryMethod.ambilSendiri),
                        ),
                        const SizedBox(height: 10),
                        _MethodTile(
                          icon: Icons.local_shipping_outlined,
                          label: 'Diantar ke Rumah',
                          desc: 'Ongkos kirim ${_fmt(_ongkir)}',
                          selected: _method == _DeliveryMethod.diantar,
                          onTap: () => setState(() => _method = _DeliveryMethod.diantar),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Konten dinamis ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _method == _DeliveryMethod.ambilSendiri
                        ? _SectionCard(
                            key: const ValueKey('lab'),
                            title: 'Informasi Lab',
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.green50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: AppColors.green500, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(_labInfo,
                                        style: const TextStyle(fontSize: 13,
                                            color: AppColors.text2, height: 1.6)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _SectionCard(
                            key: const ValueKey('alamat'),
                            title: 'Alamat Pengiriman',
                            child: Column(
                              children: [
                                _CField(controller: _namaController, label: 'Nama Penerima',
                                    hint: 'Masukkan nama penerima', icon: Icons.person_outline_rounded),
                                const SizedBox(height: 12),
                                _CField(controller: _teleponController, label: 'Nomor Telepon',
                                    hint: 'Masukkan nomor telepon', icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone),
                                const SizedBox(height: 12),
                                _CField(controller: _alamatController, label: 'Alamat Lengkap',
                                    hint: 'Nama jalan, nomor, RT/RW', icon: Icons.home_outlined,
                                    maxLines: 2),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(flex: 2,
                                      child: _CField(controller: _kotaController, label: 'Kota',
                                          hint: 'Kota/Kabupaten', icon: Icons.location_city_outlined)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _CField(controller: _kodeposController, label: 'Kode Pos',
                                          hint: '00000', icon: Icons.markunread_mailbox_outlined,
                                          keyboardType: TextInputType.number)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // ── Metode pembayaran ──
                  _SectionCard(
                    title: 'Metode Pembayaran',
                    child: Column(
                      children: _paymentOptions.map((opt) {
                        final sel = _paymentMethod == opt;
                        return GestureDetector(
                          onTap: () => setState(() => _paymentMethod = opt),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.green50 : AppColors.bgPage,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: sel ? AppColors.green500 : AppColors.border,
                                  width: sel ? 1.5 : 1),
                            ),
                            child: Row(
                              children: [
                                Icon(_paymentIcon(opt), size: 18,
                                    color: sel ? AppColors.green500 : Colors.grey[400]),
                                const SizedBox(width: 12),
                                Expanded(child: Text(opt,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                        color: sel ? AppColors.green900 : AppColors.text1))),
                                if (sel)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.green500, size: 18),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Rincian pembayaran ──
                  _SectionCard(
                    title: 'Rincian Pembayaran',
                    child: Column(
                      children: [
                        _PriceRow(label: 'Subtotal', value: _fmt(_subtotal)),
                        _PriceRow(
                          label: 'Ongkos Kirim',
                          value: _method == _DeliveryMethod.diantar ? _fmt(_ongkir) : 'Gratis',
                          valueColor: _method == _DeliveryMethod.ambilSendiri ? AppColors.green500 : null,
                        ),
                        _PriceRow(label: 'Biaya Admin', value: _fmt(_biayaAdmin)),
                        const Divider(height: 20, color: AppColors.divider),
                        _PriceRow(label: 'Total', value: _fmt(_grandTotal), isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom bayar ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                  blurRadius: 12, offset: const Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    Text(_fmt(_grandTotal),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                            color: AppColors.green500)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _bayar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green500, foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.green500.withOpacity(0.6),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Bayar Sekarang',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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

enum _DeliveryMethod { ambilSendiri, diantar }

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16), boxShadow: AppColors.cardShadow),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label, desc;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.icon, required this.label, required this.desc,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.green50 : AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.green500 : AppColors.border,
            width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: selected ? AppColors.green500 : Colors.grey[200], shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: selected ? Colors.white : Colors.grey[500]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: selected ? AppColors.green900 : AppColors.text1)),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ])),
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.green500 : Colors.grey[400], size: 20),
        ],
      ),
    ),
  );
}

class _CField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  const _CField({required this.controller, required this.label, required this.hint,
      required this.icon, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.green900)),
      const SizedBox(height: 6),
      TextField(
        controller: controller, keyboardType: keyboardType, maxLines: maxLines,
        style: const TextStyle(fontSize: 13, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
          prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.green500, size: 18) : null,
          filled: true, fillColor: AppColors.green50,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: maxLines > 1 ? 14 : 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.green500, width: 1.5)),
        ),
      ),
    ],
  );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _PriceRow({required this.label, required this.value, this.isBold = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.text1 : Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ?? (isBold ? AppColors.green500 : AppColors.text1))),
      ],
    ),
  );
}