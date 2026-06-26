import 'dart:convert';
import 'package:skin_diary/services/database_service.dart';
import 'package:skin_diary/models/product.dart';

class StorageProduct {
  static const _key = 'products';
  
  static Future<void> saveProduct(Product product) async {
    final all = await getAllProducts();
    final existingIndex = all.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      all[existingIndex] = product;
    } 
    else {
      all.add(product);
    }
    
    final encoded = jsonEncode(all.map((p) => p.toMap()).toList());
    await DatabaseService.setPreference(_key, encoded);
  }

  static Future<List<Product>> getAllProducts() async {
    final raw = await DatabaseService.getPreference(_key);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) return [];

      final products = decoded
          .whereType<Map>()
          .map((p) => Product.fromMap(Map<String, dynamic>.from(p)))
          .toList();

      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteProduct(String id) async {
    final all = await getAllProducts();
    all.removeWhere((p) => p.id == id);
    final productMap = all.map((p) => p.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(productMap));
  }
}