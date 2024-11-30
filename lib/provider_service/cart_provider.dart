import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:machinetext_ecommersproduct_catalog/provider_service/product_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'category': product.category,
      },
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product(
        id: map['product']['id'],
        title: map['product']['title'],
        price: map['product']['price'],
        image: map['product']['image'],
        category: map['product']['category'], description: '',
      ),
      quantity: map['quantity'],
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.total);
  }

  CartProvider() {
    _loadCartFromPrefs();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((key, item) => MapEntry(key.toString(), item.toMap()));
    await prefs.setString('cartData', jsonEncode(cartData));
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartDataString = prefs.getString('cartData');
    if (cartDataString != null) {
      final cartData = Map<String, dynamic>.from(jsonDecode(cartDataString));
      _items.clear();
      cartData.forEach((key, itemData) {
        final cartItem = CartItem.fromMap(Map<String, dynamic>.from(itemData));
        _items[int.parse(key)] = cartItem;
      });
      notifyListeners();
    }
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: newQuantity,
        ),
      );
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void removeItem(int productId) {
    _items.remove(productId);
    _saveCartToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }
}