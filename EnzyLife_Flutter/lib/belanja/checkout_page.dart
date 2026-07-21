import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import 'belanja_page.dart';
import '../services/api_service.dart';
import '../profil/riwayat_belanja_page.dart';
import '../models/user.dart';
import '../services/midtrans_helper.dart';
import '../services/format_helper.dart';
import '../widgets/custom_text_field.dart';
import 'widgets/method_tile.dart';
import '../profil/edit_profil_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<int, int> items;
  final List<Product> allProducts;
  /// true  → checkout dari keranjang belanja (hapus semua item checkout dari cart)
  /// false → checkout langsung / "Beli Sekarang" (cart tidak disentuh)
  final bool fromCart;

  const CheckoutPage({
    super.key,
    required this.items,
    required this.allProducts,
    this.fromCart = false,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  _DeliveryMethod _method = _DeliveryMethod.ambilSendiri;
  String _paymentMethod = 'Pembayaran Online';
  bool _isLoading = false;

  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kodeposController = TextEditingController();

  static const _ongkir = 15000;
  static const _biayaAdmin = 2000;
  static const _labInfo =
      'Lab EnzyLife\nJl. Batam Center No. 10\nBatam, Kepulauan Riau\nSenin–Sabtu, 08.00–17.00 WIB'; // TODO

  static const _paymentOptions = ['Pembayaran Online', 'COD (Bayar di Tempat)'];

  @override
  void initState() {
    super.initState();
    _kotaController.text = 'Batam';
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    UserModel? user = ApiService.cachedUser;
    user ??= await ApiService.getProfile();

    if (user != null) {
      setState(() {
        _namaController.text = user!.name;
        _teleponController.text = user.phone ?? '';

        final addr = user.address ?? '';
        if (addr.contains(',')) {
          final parts = addr.split(',');
          _alamatController.text = parts[0].trim();
          _kotaController.text = parts[1].trim();
        } else {
          _alamatController.text = addr;
          _kotaController.text = 'Batam';
        }

        _kodeposController.text = user.postalCode ?? '';
      });
    }
  }

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
  int get _grandTotal => _subtotal + _ongkirTotal + _biayaAdmin;

  static String _fmt(int price) => formatPrice(price);

  Future<void> _bayar() async {
    if (_method == _DeliveryMethod.diantar) {
      if (_namaController.text.trim().isEmpty ||
          _alamatController.text.trim().isEmpty ||
          _kotaController.text.trim().isEmpty ||
          _teleponController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lengkapi alamat pengiriman terlebih dahulu'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (_namaController.text.trim() == 'Pengguna Baru') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nama penerima tidak boleh "Pengguna Baru"'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (_alamatController.text.trim().length < 30) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Alamat minimal 30 karakter'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (_kotaController.text.trim().length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kota minimal 3 karakter'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      final cleanPhone = _teleponController.text.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length < 10 || cleanPhone.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Nomor telepon tidak valid (minimal 10 digit, maksimal 15 digit)',
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      if (_kodeposController.text.trim().isNotEmpty) {
        final cleanZip = _kodeposController.text.trim();
        if (cleanZip.length != 5 || int.tryParse(cleanZip) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Kode pos harus terdiri dari 5 digit angka'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }
    }

    // Tampilkan dialog konfirmasi sebelum memproses pesanan
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.shopping_bag_outlined, color: AppColors.green500),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Konfirmasi Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.text1,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah semua data pengiriman dan belanjaan Anda sudah benar?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text2,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _fmt(_grandTotal),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text(
                'Batal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Buat Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // Jika diantar, update data profil user terlebih dahulu agar tersimpan di backend
      if (_method == _DeliveryMethod.diantar) {
        final addressFull =
            '${_alamatController.text}, ${_kotaController.text}';
        final updateSuccess = await ApiService.updateProfile(
          name: _namaController.text,
          phone: _teleponController.text,
          address: addressFull,
          postalCode: _kodeposController.text,
        );
        if (!updateSuccess) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Gagal memperbarui profil alamat di server. Silakan coba lagi.',
              ),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
      }

      // Map item pesanan untuk request body
      final requestItems = widget.items.entries.map((e) {
        return {'produk_id': e.key, 'qty': e.value};
      }).toList();

      // Map metode pembayaran
      final String apiMetodePembayaran =
          _paymentMethod == 'COD (Bayar di Tempat)' ? 'COD' : 'ONLINE';

      // Map jenis pengambilan/pengiriman (AMBIL_TEMPAT atau BAYAR_DI_RUMAH)
      final String apiJenisCod = _method == _DeliveryMethod.ambilSendiri
          ? 'AMBIL_TEMPAT'
          : 'BAYAR_DI_RUMAH';

      final res = await ApiService.checkout(
        items: requestItems,
        metodePembayaran: apiMetodePembayaran,
        jenisCod: apiJenisCod,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (res != null && res['success'] == true) {
        // Hapus hanya item yang di-checkout dari keranjang.
        // Kalau fromCart=true, hapus item yang dicentang.
        // Kalau fromCart=false (Beli Sekarang), cart tidak disentuh sama sekali.
        if (widget.fromCart) {
          for (final id in widget.items.keys) {
            CartState.instance.removeAll(id);
          }
        }

        void showSuccess() {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.green50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: AppColors.green500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pesanan Berhasil!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _method == _DeliveryMethod.ambilSendiri
                        ? 'Silakan ambil pesanan di lab sesuai jadwal.'
                        : 'Pesanan akan segera dikirim ke alamat kamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RiwayatBelanjaScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lihat Riwayat Belanja',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (apiMetodePembayaran == 'ONLINE' && res['snap_token'] != null) {
          final orderId = res['pemesanan_id'] as int;
          final snapToken = res['snap_token'] as String;

          setState(() => _isLoading = true);

          // Open Midtrans Snap (WebView di mobile, JS popup di web)
          await MidtransPayHelper.pay(snapToken, context: context);

          // After Snap closes, check status from backend
          final verifyRes = await ApiService.payOrder(orderId, simulate: false);

          setState(() => _isLoading = false);
          if (!mounted) return;

          if (verifyRes != null && verifyRes['success'] == true) {
            showSuccess();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  verifyRes?['message'] ??
                      'Pembayaran belum diselesaikan. Anda dapat membayar nanti di Riwayat Belanja.',
                ),
                backgroundColor: Colors.orange[850],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.of(context).popUntil((r) => r.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RiwayatBelanjaScreen()),
            );
          }
          return;
        }

        showSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res?['message'] ?? 'Gagal memproses pesanan. Silakan coba lagi.',
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  IconData _paymentIcon(String m) {
    switch (m) {
      case 'Pembayaran Online':
        return Icons.account_balance_outlined;
      case 'COD (Bayar di Tempat)':
        return Icons.payments_outlined;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.bgPage,
            appBar: const SubPageAppBar(title: 'Pemesanan'),
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
                              try {
                                p = widget.allProducts.firstWhere(
                                  (x) => x.id == e.key,
                                );
                              } catch (_) {}
                              if (p == null) return const SizedBox.shrink();
                              final imageUrl = p.image.isNotEmpty
                                  ? '${AppConfig.webBaseUrl}/gambar/produk/${p.image.split('/').last}'
                                  : null;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        color: AppColors.green50,
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                      Icons.image_outlined,
                                                      size: 20,
                                                      color: AppColors.green500,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.image_outlined,
                                                size: 20,
                                                color: AppColors.green500
                                                    .withAlpha(76),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.text1,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${e.value}x · ${_fmt(p.price)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _fmt(p.price * e.value),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text1,
                                      ),
                                    ),
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
                              MethodTile(
                                icon: Icons.store_outlined,
                                label: 'Ambil Sendiri di Lab',
                                desc: 'Gratis, ambil langsung di laboratorium',
                                selected:
                                    _method == _DeliveryMethod.ambilSendiri,
                                onTap: () => setState(
                                  () => _method = _DeliveryMethod.ambilSendiri,
                                ),
                              ),
                              const SizedBox(height: 10),
                              MethodTile(
                                icon: Icons.local_shipping_outlined,
                                label: 'Diantar ke Rumah',
                                desc: 'Ongkos kirim ${_fmt(_ongkir)}',
                                selected: _method == _DeliveryMethod.diantar,
                                onTap: () async {
                                  final hasName =
                                      _namaController.text.trim().isNotEmpty &&
                                      _namaController.text.trim() !=
                                          'Pengguna Baru';
                                  final hasPhone = _teleponController.text
                                      .trim()
                                      .isNotEmpty;
                                  final hasAddress = _alamatController.text
                                      .trim()
                                      .isNotEmpty;

                                  if (!hasName || !hasPhone || !hasAddress) {
                                    final navigator = Navigator.of(context);
                                    final toEdit = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: AppColors.green500,
                                            ),
                                            SizedBox(width: 10),
                                            Flexible(
                                              child: Text(
                                                'Profil Belum Lengkap',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColors.text1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          'Data alamat dan nomor telepon Anda masih kosong! Silakan lengkapi data profil Anda terlebih dahulu untuk menggunakan layanan pengantaran.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.text2,
                                            height: 1.5,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.grey[600],
                                            ),
                                            child: const Text(
                                              'Batal',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.green500,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'Lengkapi Profil',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (toEdit == true) {
                                      if (!mounted) return;
                                      await navigator.push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EditProfilScreen(),
                                        ),
                                      );
                                      await _loadUserProfile();

                                      final updatedName = _namaController.text
                                          .trim();
                                      final updatedPhone = _teleponController
                                          .text
                                          .trim();
                                      final updatedAddress = _alamatController
                                          .text
                                          .trim();
                                      if (updatedName.isNotEmpty &&
                                          updatedName != 'Pengguna Baru' &&
                                          updatedPhone.isNotEmpty &&
                                          updatedAddress.isNotEmpty) {
                                        setState(
                                          () =>
                                              _method = _DeliveryMethod.diantar,
                                        );
                                      }
                                    }
                                  } else {
                                    setState(
                                      () => _method = _DeliveryMethod.diantar,
                                    );
                                  }
                                },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: AppColors.green500,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _labInfo,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.text2,
                                              height: 1.6,
                                            ),
                                          ),
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
                                      CustomTextField(
                                        controller: _namaController,
                                        label: 'Nama Penerima',
                                        hint: 'Masukkan nama penerima',
                                        icon: Icons.person_outline_rounded,
                                        readOnly: true,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 12),
                                      CustomTextField(
                                        controller: _teleponController,
                                        label: 'Nomor Telepon',
                                        hint: 'Masukkan nomor telepon',
                                        icon: Icons.phone_outlined,
                                        readOnly: true,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 12),
                                      CustomTextField(
                                        controller: _alamatController,
                                        label: 'Alamat Lengkap',
                                        hint: 'Nama jalan, nomor, RT/RW',
                                        icon: Icons.home_outlined,
                                        readOnly: true,
                                        maxLines: 2,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: CustomTextField(
                                              controller: _kotaController,
                                              label: 'Kota',
                                              hint: 'Kota/Kabupaten',
                                              icon:
                                                  Icons.location_city_outlined,
                                              readOnly: true,
                                              textInputAction:
                                                  TextInputAction.next,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: CustomTextField(
                                              controller: _kodeposController,
                                              label: 'Kode Pos',
                                              hint: '00000',
                                              icon: Icons
                                                  .markunread_mailbox_outlined,
                                              keyboardType:
                                                  TextInputType.number,
                                              readOnly: true,
                                              textInputAction:
                                                  TextInputAction.done,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () async {
                                            final navigator = Navigator.of(
                                              context,
                                            );
                                            await navigator.push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const EditProfilScreen(),
                                              ),
                                            );
                                            if (mounted)
                                              await _loadUserProfile();
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.green500,
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Data tidak sesuai? ubah disini.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
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
                                onTap: () =>
                                    setState(() => _paymentMethod = opt),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppColors.green50
                                        : AppColors.bgPage,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: sel
                                          ? AppColors.green500
                                          : AppColors.border,
                                      width: sel ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _paymentIcon(opt),
                                        size: 18,
                                        color: sel
                                            ? AppColors.green500
                                            : Colors.grey[400],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: sel
                                                ? AppColors.green900
                                                : AppColors.text1,
                                          ),
                                        ),
                                      ),
                                      if (sel)
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.green500,
                                          size: 18,
                                        ),
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
                              _PriceRow(
                                label: 'Subtotal',
                                value: _fmt(_subtotal),
                              ),
                              _PriceRow(
                                label: 'Ongkos Kirim',
                                value: _method == _DeliveryMethod.diantar
                                    ? _fmt(_ongkir)
                                    : 'Gratis',
                                valueColor:
                                    _method == _DeliveryMethod.ambilSendiri
                                    ? AppColors.green500
                                    : null,
                              ),
                              _PriceRow(
                                label: 'Biaya Admin',
                                value: _fmt(_biayaAdmin),
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.divider,
                              ),
                              _PriceRow(
                                label: 'Total',
                                value: _fmt(_grandTotal),
                                isBold: true,
                              ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            _fmt(_grandTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _bayar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green500,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.green500
                                .withAlpha(153),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _paymentMethod == 'COD (Bayar di Tempat)'
                                      ? 'Buat Pesanan'
                                      : 'Bayar Sekarang',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    child: Material(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: AppColors.green500,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Memproses Pesanan...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mohon tunggu sebentar, jangan menutup atau kembali dari halaman ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColors.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text1,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isBold;
  final Color? valueColor;
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? AppColors.text1 : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color:
                  valueColor ?? (isBold ? AppColors.green500 : AppColors.text1),
            ),
          ),
        ),
      ],
    ),
  );
}
