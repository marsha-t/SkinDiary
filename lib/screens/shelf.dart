import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/screens/add_edit_product.dart';
import 'package:skin_diary/services/storage_product.dart';
import 'package:skin_diary/utils/snackbar.dart';
import 'package:skin_diary/utils/dialogs.dart';
import 'package:skin_diary/navigation/product_navigation_result.dart';
import 'package:skin_diary/app/app_routes.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  // State
  List<Product> _products = [];

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Data loading
  Future<void> _loadProducts() async {
    final products = await StorageProduct.getActiveProducts();

    if (!mounted) return;

    setState(() {
      _products = products;
    });
  }

  // Navigation
  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push<ProductNavigationResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );

    if (!mounted || result == null) return;

    await _loadProducts();
  }

  Future<void> _navigateToEditProduct(Product product) async {
    final result = await Navigator.push<ProductNavigationResult>(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
    );

    if (!mounted || result == null) return;

    await _loadProducts();

    if (!mounted) return;

    switch (result.action) {
      case ProductNavigationAction.saved:
        break;

      case ProductNavigationAction.archived:
        _showUndoArchiveProductSnackBar(result.product);
        break;

      case ProductNavigationAction.deletedPermanently:
        break;
    }
  }

  // Product actions
  Future<void> _archiveProduct(String id) async {
    final archivedProduct = _products.firstWhere((p) => p.id == id);

    await StorageProduct.archiveProduct(id);

    if (!mounted) return;

    await _loadProducts();

    _showUndoArchiveProductSnackBar(archivedProduct);
  }

  void _showUndoArchiveProductSnackBar(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      buildUndoSnackBar(
        message: 'Archived "${product.name}"',
        onUndo: () async {
          await StorageProduct.restoreProduct(product.id);
          if (mounted) await _loadProducts();
        },
      ),
    );
  }

  // Helpers
  Map<String, List<Product>> _groupedByCategory(List<Product> products) {
    final Map<String, List<Product>> grouped = {};

    for (final product in products) {
      final categories =
          product.categories.isEmpty ? ['Uncategorized'] : product.categories;

      for (final category in categories) {
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(product);
      }
    }

    return grouped;
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final categorizedProducts = _groupedByCategory(_products);
    final categoryOrder = categorizedProducts.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shelf'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'View archived products',
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.archivedProducts);
              if (mounted) await _loadProducts();
            },
          ),
        ],
      ),
      body:
          _products.isEmpty
              ? const Center(child: Text('No products added yet.'))
              : ListView.builder(
                itemCount: categoryOrder.length,
                itemBuilder: (context, index) {
                  final category = categoryOrder[index];
                  final products = categorizedProducts[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...products.map((product) {
                        return Dismissible(
                          key: ValueKey('${category}_${product.id}'),
                          direction: DismissDirection.endToStart,
                          background: _buildDismissibleBackground(),
                          confirmDismiss:
                              (_) => showArchiveProductConfirmationDialog(
                                context,
                                product.name,
                              ),
                          onDismissed: (_) => _archiveProduct(product.id),
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text(product.brand ?? ''),
                            onTap: () => _navigateToEditProduct(product),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  // UI builders
  Widget _buildDismissibleBackground() => Container(
    color: Colors.orange,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.archive, color: Colors.white),
  );
}
