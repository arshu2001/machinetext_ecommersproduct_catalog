import 'package:flutter/material.dart';
import 'package:machinetext_ecommersproduct_catalog/screens/home_screen.dart';
import 'package:machinetext_ecommersproduct_catalog/screens/product_details.dart';
import 'package:provider/provider.dart';
import '../provider_service/wishlist_provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.wishlist.isEmpty) {
            return const Center(
              child: Text('Your wishlist is empty'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2/3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: wishlistProvider.wishlist.length,
            itemBuilder: (ctx, i) => ProductCard(
              product: wishlistProvider.wishlist[i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: wishlistProvider.wishlist[i],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}