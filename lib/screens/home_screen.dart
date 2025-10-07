import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/app_header.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_drawer.dart';

import '../providers/cart_provider.dart';
import '../widgets/product_cart.dart';
import 'ProductDetailsScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> allProducts = [];
  List<Product> products = [];
  List<Product> filteredProducts = [];
  int skip = 0;
  bool isLoading = false;
  bool isSearching = false;
  bool hasMore = true;
  String searchQuery = '';
  static const int itemsPerPage = 30;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts(initialLoad: true);
  }

  Future _fetchProducts({bool initialLoad = false}) async {
    if (isLoading || (!hasMore && !initialLoad)) return;
    setState(() {
      isLoading = true;
    });
    try {
      final url = initialLoad || skip == 0
          ? 'https://dummyjson.com/products?limit=$itemsPerPage'
          : 'https://dummyjson.com/products?skip=$skip&limit=$itemsPerPage';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Product> newProducts = (data['products'] as List)
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
        print('Fetched products: ${newProducts.length}'); // Debug log
        setState(() {
          if (initialLoad) {
            allProducts.clear();
            products.clear();
            skip = 0;
          }
          allProducts.addAll(newProducts);
          products.addAll(newProducts);
          skip += newProducts.length;
          totalItems = data['total'] ?? totalItems;
          hasMore = skip < totalItems;
          _handleSearchAndPagination();
        });
      } else {
        _showErrorSnackBar('Failed to load products: ${response.statusCode}');
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      setState(() {
        hasMore = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future _handleSearchAndPagination() async {
    if (searchQuery.isNotEmpty) {
      setState(() {
        isSearching = true;
        isLoading = true;
      });
      try {
        final url = 'https://dummyjson.com/products/search?q=$searchQuery';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<Product> searchResults = (data['products'] as List)
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList();
          print('Search results for "$searchQuery": ${searchResults.length}'); // Debug log
          setState(() {
            filteredProducts = searchResults;
            isLoading = false;
            isSearching = false;
          });
        } else {
          _showErrorSnackBar('Failed to load search results: ${response.statusCode}');
          setState(() {
            filteredProducts = [];
            isLoading = false;
            isSearching = false;
          });
        }
      } catch (e) {
        _showErrorSnackBar('Error searching products: $e');
        setState(() {
          filteredProducts = [];
          isLoading = false;
          isSearching = false;
        });
      }
    } else {
      setState(() {
        filteredProducts = allProducts;
        isSearching = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              if (message.toLowerCase().contains('search')) {
                _handleSearchAndPagination();
              } else {
                _fetchProducts(initialLoad: skip == 0);
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(title: 'Pinky Petals', titleColor: Colors.amber),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _handleSearchAndPagination();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
          ),
          // Products Grid with Pagination Info
          Expanded(
            child: isLoading && allProducts.isEmpty && !isSearching
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                // Pagination Info
                if (totalItems > 0 && !isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${filteredProducts.length} of $totalItems products',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                      ],
                    ),
                  ),
                Expanded(
                  child: filteredProducts.isEmpty && !isLoading
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            'https://via.placeholder.com/128x128/cccccc/969696?text=No+Results',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off, color: Colors.grey, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'No products found for your search.'
                              : 'No products loaded yet. Tap Load More.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onAddToCart: () {
                          try {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(product, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.title} added to cart!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Load More Button (only shown when not searching)
                if (!isLoading && !isSearching)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: hasMore ? () => _fetchProducts() : null,
                        icon: const Icon(Icons.download),
                        label: Text(
                          hasMore ? 'Load More Products' : 'All ${totalItems} products loaded',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasMore ? Colors.amber : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(currentIndex: 0),
    );
  }
}