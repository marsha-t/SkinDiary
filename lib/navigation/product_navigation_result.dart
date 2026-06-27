import 'package:skin_diary/models/product.dart';

enum ProductNavigationAction { saved, deleted }

class ProductNavigationResult {
  final ProductNavigationAction action;
  final Product product;

  const ProductNavigationResult({required this.action, required this.product});

  const ProductNavigationResult.saved(this.product)
    : action = ProductNavigationAction.saved;

  const ProductNavigationResult.deleted(this.product)
    : action = ProductNavigationAction.deleted;
}
