import 'package:flutter/material.dart';
import 'midtrans_webview_page.dart';

class MidtransPayHelper {
  static Future<bool> pay(String snapToken, {BuildContext? context}) async {
    if (context == null) return false;

    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MidtransWebViewPage(snapToken: snapToken),
      ),
    );

    return result == true;
  }
}
