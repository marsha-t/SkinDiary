import 'package:skin_diary/models/product.dart';

enum ProductNavigationAction { saved, archived, deletedPermanently }

class ProductNavigationResult {
  final ProductNavigationAction action;
  final Product product;

  const ProductNavigationResult({required this.action, required this.product});

  const ProductNavigationResult.saved(this.product)
    : action = ProductNavigationAction.saved;

  const ProductNavigationResult.archived(this.product)
    : action = ProductNavigationAction.archived;

  const ProductNavigationResult.deletedPermanently(this.product)
    : action = ProductNavigationAction.deletedPermanently;
}
