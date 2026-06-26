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
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((p) => Product.fromMap(p)).toList();
  }

  static Future<void> deleteProduct(String id) async {
    final all = await getAllProducts();
    all.removeWhere((p) => p.id == id);
    final productMap = all.map((p) => p.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(productMap));
  }

  static Future<void> clearAllProducts() async {
    await DatabaseService.removePreference(_key);
  }
}