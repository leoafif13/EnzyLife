import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// ══════════════════════════════════════════════
//  CartState — singleton ChangeNotifier
// ══════════════════════════════════════════════
class CartState extends ChangeNotifier {
  static final CartState instance = CartState._();
  CartState._();

  final Map<int, int> _items = {};
  Map<int, int> get items     => Map.unmodifiable(_items);
  int get totalItems             => _items.values.fold(0, (a, b) => a + b);

  // Load cart items for a specific logged-in user
  Future<void> loadCartForUser() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final userId = user['id']?.toString() ?? user['email'];
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        final cartString = prefs.getString('cart_items_$userId');
        _items.clear();
        if (cartString != null) {
          try {
            final Map<String, dynamic> decoded = jsonDecode(cartString);
            decoded.forEach((key, value) {
              final id = int.tryParse(key);
              final qty = value as int?;
              if (id != null && qty != null) {
                _items[id] = qty;
              }
            });
          } catch (e) {
            debugPrint('Error loading cart for user: $e');
          }
        }
        notifyListeners();
      }
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  // Save cart items for the currently logged-in user
  Future<void> _saveCartToPrefs() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final userId = user['id']?.toString() ?? user['email'];
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        final stringMap = _items.map((key, value) => MapEntry(key.toString(), value));
        await prefs.setString('cart_items_$userId', jsonEncode(stringMap));
      }
    }
  }

  void add(int id) {
    _items[id] = (_items[id] ?? 0) + 1;
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeOne(int id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]! - 1;
      if (_items[id]! <= 0) _items.remove(id);
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  // Hapus seluruh produk dari keranjang (untuk swipe delete)
  void removeAll(int id) {
    _items.remove(id);
    _saveCartToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }

  void clearMemoryOnly() {
    _items.clear();
    notifyListeners();
  }

  int qty(int id) => _items[id] ?? 0;

  // Jumlah ID unik (untuk badge — kaya Shopee)
  int get uniqueItems => _items.length;
}
