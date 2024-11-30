import 'package:flutter/foundation.dart';
import 'package:machinetext_ecommersproduct_catalog/provider_service/product_modal.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  bool isInWishlist(Product product) {
    return _wishlist.any((item) => item.id == product.id);
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      _wishlist.removeWhere((item) => item.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }
}