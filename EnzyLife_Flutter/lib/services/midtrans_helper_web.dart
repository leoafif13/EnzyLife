// ignore_for_file: uri_does_not_exist, undefined_function, undefined_method, avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/material.dart';

class MidtransPayHelper {
  static Future<bool> pay(String snapToken, {BuildContext? context}) {
    final completer = Completer<bool>();

    try {
      js.context.callMethod('snapPay', [
        snapToken,
        js.allowInterop((success) {
          if (!completer.isCompleted) {
            completer.complete(success == true);
          }
        })
      ]);
    } catch (e) {
      // ignore: avoid_print
      print('Error calling snapPay in JS: $e');
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }
}
