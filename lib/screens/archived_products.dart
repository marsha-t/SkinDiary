import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/services/storage_product.dart';
import 'package:skin_diary/utils/dialogs.dart';

class ArchivedProductsScreen extends StatefulWidget {
  const ArchivedProductsScreen({super.key});

  @override
  State<ArchivedProductsScreen> createState() => _ArchivedProductsScreenState();
}

class _ArchivedProductsScreenState extends State<ArchivedProductsScreen> {
  // State
  List<Product> _archivedProducts = [];

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _loadArchivedProducts();
  }

  // Data loading
  Future<void> _loadArchivedProducts() async {
    final products = await StorageProduct.getArchivedProducts();

    if (!mounted) return;

    setState(() {
      _archivedProducts = products;
    });
  }

  // Product actions
  Future<void> _restoreProduct(Product product) async {
    await StorageProduct.restoreProduct(product.id);

    if (!mounted) return;

    await _loadArchivedProducts();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Restored "${product.name}"')));
  }

  Future<void> _deleteProductPermanently(Product product) async {
    final confirm = await showDeleteProductPermanentlyConfirmationDialog(
      context,
      product.name,
    );

    if (!confirm) return;

    await StorageProduct.deleteProductPermanently(product.id);

    if (!mounted) return;

    await _loadArchivedProducts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted "${product.name}" permanently')),
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived Products')),
      body:
          _archivedProducts.isEmpty
              ? const Center(child: Text('No archived products.'))
              : ListView.builder(
                itemCount: _archivedProducts.length,
                itemBuilder: (context, index) {
                  final product = _archivedProducts[index];

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.brand ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'restore') {
                          _restoreProduct(product);
                        } else if (value == 'delete') {
                          _deleteProductPermanently(product);
                        }
                      },
                      itemBuilder:
                          (context) => const [
                            PopupMenuItem(
                              value: 'restore',
                              child: Text('Restore'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete permanently'),
                            ),
                          ],
                    ),
                  );
                },
              ),
    );
  }
}
