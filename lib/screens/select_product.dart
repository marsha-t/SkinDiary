import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/services/storage_product.dart';
import 'package:skin_diary/screens/add_edit_product.dart';
import 'package:skin_diary/screens/order_products.dart';
import 'package:skin_diary/navigation/product_navigation_result.dart';
import 'package:skin_diary/app/app_routes.dart';

class SelectProductScreen extends StatefulWidget {
  final List<Product>? initialSelection;

  const SelectProductScreen({super.key, this.initialSelection});

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  // State
  List<Product> _allProducts = [];
  List<Product> _selectedProducts = [];
  String _searchQuery = '';

  // Lifecycle
  @override
  void initState() {
    super.initState();
    _selectedProducts = List<Product>.from(widget.initialSelection ?? []);
    _loadProducts();
  }

  // Data loading
  Future<void> _loadProducts() async {
    final products = await StorageProduct.getActiveProducts();

    if (!mounted) return;

    setState(() {
      _allProducts = products;
    });
  }

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _allProducts;

    return _allProducts.where((product) {
      final searchableText =
          [
            product.name,
            product.brand,
            product.productType,
            ...product.categories,
            ...?product.keyIngredients,
          ].where((value) => value != null).join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // Navigation
  Future<void> _navigateToAddProduct() async {
    final result = await Navigator.push<ProductNavigationResult>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );

    if (!mounted || result == null) return;

    await _loadProducts();

    if (!mounted) return;

    if (result.action == ProductNavigationAction.saved) {
      setState(() {
        final alreadySelected = _selectedProducts.any(
          (product) => product.id == result.product.id,
        );

        if (!alreadySelected) {
          _selectedProducts.add(result.product);
        }
      });
    }
  }

  Future<void> _navigateToArchivedProducts() async {
    await Navigator.pushNamed(context, AppRoutes.archivedProducts);

    if (!mounted) return;

    await _loadProducts();
  }

  Future<void> _saveSelection() async {
    if (_selectedProducts.length <= 1) {
      Navigator.pop(context, _selectedProducts);
      return;
    }

    final orderedProducts = await Navigator.push<List<Product>>(
      context,
      MaterialPageRoute(
        builder: (_) => OrderProductsScreen(products: _selectedProducts),
      ),
    );

    if (!mounted || orderedProducts == null) return;

    Navigator.pop(context, orderedProducts);
  }

  // Build
  @override
  Widget build(BuildContext context) {
    final visibleProducts = _filteredProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Product(s)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _allProducts.isEmpty
                  ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text('No active products found.'),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a new product or restore one from archived products.',
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _navigateToAddProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add new product'),
                          ),
                          TextButton.icon(
                            onPressed: _navigateToArchivedProducts,
                            icon: const Icon(Icons.archive),
                            label: const Text('View archived products'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search products',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            visibleProducts.isEmpty
                                ? const Center(
                                  child: Text('No matching products.'),
                                )
                                : ListView.builder(
                                  itemCount: visibleProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = visibleProducts[index];
                                    final subtitle = _buildProductSubtitle(
                                      product,
                                    );
                                    return CheckboxListTile(
                                      title: Text(product.name),
                                      subtitle:
                                          subtitle.isEmpty
                                              ? null
                                              : Text(subtitle),
                                      value: _selectedProducts.any(
                                        (p) => p.id == product.id,
                                      ),
                                      onChanged: (bool? isChecked) {
                                        setState(() {
                                          if (isChecked == true &&
                                              (!_selectedProducts.any(
                                                (p) => p.id == product.id,
                                              ))) {
                                            _selectedProducts.add(product);
                                          } else {
                                            _selectedProducts.removeWhere(
                                              (p) => p.id == product.id,
                                            );
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                      ),
                      TextButton.icon(
                        onPressed: _navigateToAddProduct,
                        icon: const Icon(Icons.add),
                        label: const Text('Add new product'),
                      ),
                      TextButton.icon(
                        onPressed: _navigateToArchivedProducts,
                        icon: const Icon(Icons.archive),
                        label: const Text('View archived products'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveSelection,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  // UI builder
  String _buildProductSubtitle(Product product) {
    final parts =
        [product.brand, product.productType]
            .where((value) => value != null && value.trim().isNotEmpty)
            .map((value) => value!.trim())
            .toList();

    return parts.join(' • ');
  }
}
