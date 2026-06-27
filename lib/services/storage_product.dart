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
    } else {
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

      final products =
          decoded
              .whereType<Map>()
              .map((p) => Product.fromMap(Map<String, dynamic>.from(p)))
              .toList();

      products.sort((a, b) => a.name.compareTo(b.name));

      return products;
    } catch (_) {
      return [];
    }
  }

  static Future<List<Product>> getActiveProducts() async {
    final all = await getAllProducts();
    return all.where((p) => p.status == ProductStatus.active).toList();
  }

  static Future<List<Product>> getArchivedProducts() async {
    final all = await getAllProducts();
    return all.where((p) => p.status == ProductStatus.archived).toList();
  }

  static Future<void> deleteProductPermanently(String id) async {
    final all = await getAllProducts();
    all.removeWhere((p) => p.id == id);
    final productMap = all.map((p) => p.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(productMap));
  }

  static Future<void> archiveProduct(String id) async {
    final all = await getAllProducts();
    final index = all.indexWhere((p) => p.id == id);

    if (index == -1) return;

    all[index] = all[index].copyWith(status: ProductStatus.archived);

    final productMap = all.map((p) => p.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(productMap));
  }

  static Future<void> restoreProduct(String id) async {
    final all = await getAllProducts();
    final index = all.indexWhere((p) => p.id == id);

    if (index == -1) return;

    all[index] = all[index].copyWith(status: ProductStatus.active);

    final productMap = all.map((p) => p.toMap()).toList();
    await DatabaseService.setPreference(_key, jsonEncode(productMap));
  }

  static String _normaliseText(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  static List<String> _normaliseList(List<String>? values) {
    final normalised =
        (values ?? [])
            .map((value) => value.trim().toLowerCase())
            .where((value) => value.isNotEmpty)
            .toList();

    normalised.sort();

    return normalised;
  }

  static bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  static bool _hasSameProductDetails(Product a, Product b) {
    return _normaliseText(a.name) == _normaliseText(b.name) &&
        _normaliseText(a.brand) == _normaliseText(b.brand) &&
        _normaliseText(a.productType) == _normaliseText(b.productType) &&
        _sameStringList(
          _normaliseList(a.categories),
          _normaliseList(b.categories),
        ) &&
        _sameStringList(
          _normaliseList(a.keyIngredients),
          _normaliseList(b.keyIngredients),
        ) &&
        a.dateOpened == b.dateOpened &&
        a.expirationDate == b.expirationDate &&
        _normaliseText(a.notes) == _normaliseText(b.notes);
  }

  static Future<Product?> findDuplicateProduct(Product product) async {
    final all = await getAllProducts();

    for (final existingProduct in all) {
      final isSameRecord = existingProduct.id == product.id;

      if (isSameRecord) continue;

      if (_hasSameProductDetails(existingProduct, product)) {
        return existingProduct;
      }
    }

    return null;
  }
}
