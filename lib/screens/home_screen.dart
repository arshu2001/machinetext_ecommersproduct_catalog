import 'package:flutter/material.dart';
import 'package:machinetext_ecommersproduct_catalog/api_service/api_services.dart';
import 'package:machinetext_ecommersproduct_catalog/provider_service/product_modal.dart';
import 'package:machinetext_ecommersproduct_catalog/provider_service/wishlist_provider.dart';
import 'package:machinetext_ecommersproduct_catalog/screens/cart_screen.dart';
import 'package:machinetext_ecommersproduct_catalog/screens/product_details.dart';
import 'package:machinetext_ecommersproduct_catalog/screens/wishlist_screen.dart';
import 'package:provider/provider.dart';


// import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await _apiService.fetchProducts();
      final categories = await _apiService.fetchCategories();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load products');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == null || 
            product.category == _selectedCategory;
        final matchesSearch = product.title
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('E-Commerce App'),
  actions: [
    IconButton(
      icon: const Icon(Icons.favorite),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WishlistScreen()),
        );
      },
    ),
    IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
    ),
  ],
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Products',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterProducts();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select Category'),
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _filterProducts();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2/3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, i) => ProductCard(
                      product: _filteredProducts[i],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: _filteredProducts[i],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final isInWishlist = wishlistProvider.isInWishlist(product);
                  return IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      wishlistProvider.toggleWishlist(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isInWishlist 
                              ? 'Removed from wishlist' 
                              : 'Added to wishlist'
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
