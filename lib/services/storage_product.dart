import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, encoded);
  }
  
  static Future<List<Product>> getAllProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((p) => Product.fromMap(p)).toList();
  }

  static Future<void> deleteProduct(String id) async {
    final all = await getAllProducts();
    all.removeWhere((p) => p.id == id);
    final productMap = all.map((p) => p.toMap()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(productMap));
  }

  static Future<void> clearAllProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}