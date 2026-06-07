import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPaymentPage extends StatefulWidget {
  final String snapToken;

  const MidtransPaymentPage({
    super.key,
    required this.snapToken,
  });

  @override
  State<MidtransPaymentPage> createState() =>
      _MidtransPaymentPageState();
}

class _MidtransPaymentPageState
    extends State<MidtransPaymentPage> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://app.sandbox.midtrans.com/snap/v4/redirection/${widget.snapToken}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}