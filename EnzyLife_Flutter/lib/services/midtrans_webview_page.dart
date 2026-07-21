import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../app_color.dart';

/// Halaman WebView yang membuka Snap Midtrans.
/// Return true kalau pembayaran berhasil, false kalau gagal/dibatalkan.
class MidtransWebViewPage extends StatefulWidget {
  final String snapToken;

  const MidtransWebViewPage({super.key, required this.snapToken});

  @override
  State<MidtransWebViewPage> createState() => _MidtransWebViewPageState();
}

class _MidtransWebViewPageState extends State<MidtransWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // URL Snap Midtrans — ganti ke production kalau sudah live:
  // Production : https://app.midtrans.com/snap/v4/redirection/{token}
  // Sandbox    : https://app.sandbox.midtrans.com/snap/v4/redirection/{token}
  String get _snapUrl =>
      'https://app.sandbox.midtrans.com/snap/v4/redirection/${widget.snapToken}';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url.toLowerCase();

            // Midtrans redirect ke URL ini setelah transaksi selesai
            if (url.contains('gotofinish') ||
                url.contains('payment_status=settlement') ||
                url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              // Berhasil bayar
              if (mounted) Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }

            if (url.contains('payment_status=pending') ||
                url.contains('transaction_status=pending')) {
              // Pending — dianggap belum selesai, backend akan cek ulang
              if (mounted) Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }

            if (url.contains('payment_status=deny') ||
                url.contains('payment_status=cancel') ||
                url.contains('payment_status=expire') ||
                url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              // Gagal/dibatalkan/expired
              if (mounted) Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_snapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.text1),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.green500),
            ),
        ],
      ),
    );
  }
}
