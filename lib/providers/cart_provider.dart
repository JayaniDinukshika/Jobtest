import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cart = [];

  CartProvider() {
    _loadCart();
  }

  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);

  double get total => _cart.fold(
    0.0,
        (sum, item) => sum + (item['product'].price * (item['quantity'] as int)),
  );

  void addToCart(Product product, int quantity) {
    if (quantity <= 0 || quantity > product.stock) {
      throw ArgumentError('Quantity must be positive and within stock (${product.stock})');
    }
    final existingIndex = _cart.indexWhere((item) => item['id'] == product.id);
    if (existingIndex != -1) {
      _cart[existingIndex]['quantity'] += quantity;
      if (_cart[existingIndex]['quantity'] > product.stock) {
        _cart[existingIndex]['quantity'] = product.stock;
      }
    } else {
      _cart.add({
        'id': product.id,
        'product': product,
        'quantity': quantity,
      });
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(int id) {
    _cart.removeWhere((item) => item['id'] == id);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int id, int quantity) {
    final index = _cart.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final product = _cart[index]['product'] as Product;
      if (quantity <= 0) {
        throw ArgumentError('Quantity must be positive');
      }
      if (quantity > product.stock) {
        throw ArgumentError('Quantity cannot exceed stock (${product.stock})');
      }
      _cart[index]['quantity'] = quantity;
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _saveCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cart.map((item) {
        final product = item['product'] as Product;
        return {
          'id': product.id,
          'title': product.title,
          'description': product.description,
          'category': product.category,
          'price': product.price,
          'discountPercentage': product.discountPercentage,
          'rating': product.rating,
          'stock': product.stock,
          'tags': product.tags,
          'brand': product.brand,
          'sku': product.sku,
          'weight': product.weight,
          'dimensions': product.dimensions,
          'warrantyInformation': product.warrantyInformation,
          'shippingInformation': product.shippingInformation,
          'availabilityStatus': product.availabilityStatus,
          'reviews': product.reviews,
          'returnPolicy': product.returnPolicy,
          'minimumOrderQuantity': product.minimumOrderQuantity,
          'meta': product.meta,
          'images': product.images,
          'thumbnail': product.thumbnail,
          'quantity': item['quantity'],
        };
      }).toList();
      await prefs.setString('cart', json.encode(cartJson));
    } catch (e) {
      debugPrint('Error saving cart: $e');
      // Optionally, notify user of failure
    }
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartString = prefs.getString('cart');
      if (cartString != null && cartString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(cartString) as List<dynamic>;
        _cart = decoded.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'] as int? ?? 0,
            'product': Product(
              id: item['id'] as int? ?? 0,
              title: item['title'] as String? ?? '',
              description: item['description'] as String? ?? '',
              category: item['category'] as String? ?? '',
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              discountPercentage: (item['discountPercentage'] as num?)?.toDouble() ?? 0.0,
              rating: (item['rating'] as num?)?.toDouble() ?? 0.0,
              stock: item['stock'] as int? ?? 0,
              tags: item['tags'] != null ? List<String>.from(item['tags'] as List) : [],
              brand: item['brand'] as String? ?? '',
              sku: item['sku'] as String? ?? '',
              weight: item['weight'] as int? ?? 0,
              dimensions: Map<String, double>.from({
                'width': (item['dimensions']?['width'] as num?)?.toDouble() ?? 0.0,
                'height': (item['dimensions']?['height'] as num?)?.toDouble() ?? 0.0,
                'depth': (item['dimensions']?['depth'] as num?)?.toDouble() ?? 0.0,
              }),
              warrantyInformation: item['warrantyInformation'] as String? ?? '',
              shippingInformation: item['shippingInformation'] as String? ?? '',
              availabilityStatus: item['availabilityStatus'] as String? ?? '',
              reviews: item['reviews'] != null
                  ? List<Map<String, dynamic>>.from(item['reviews'] as List)
                  : [],
              returnPolicy: item['returnPolicy'] as String? ?? '',
              minimumOrderQuantity: item['minimumOrderQuantity'] as int? ?? 0,
              meta: item['meta'] != null
                  ? Map<String, dynamic>.from(item['meta'] as Map)
                  : {},
              images: item['images'] != null ? List<String>.from(item['images'] as List) : [],
              thumbnail: item['thumbnail'] as String? ?? '',
            ),
            'quantity': item['quantity'] as int? ?? 1,
          };
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      // Optionally, reset cart or notify user
      _cart = [];
    }
  }
}