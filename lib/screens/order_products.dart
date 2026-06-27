import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';

class OrderProductsScreen extends StatefulWidget {
  final List<Product> products;

  const OrderProductsScreen({
    super.key,
    required this.products,
  });

  @override
  State<OrderProductsScreen> createState() => _OrderProductsScreenState();
}

class _OrderProductsScreenState extends State<OrderProductsScreen> {
  
  // State
  late List<Product> _orderedProducts;
  
  // Lifecycle
  @override
  void initState() {
    super.initState();
    _orderedProducts = List<Product>.from(widget.products);
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Products'),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orderedProducts.length,
        itemBuilder: (context, index) {
          final product = _orderedProducts[index];

          return ListTile(
            key: ValueKey(product.id),
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(product.name),
            subtitle: _buildProductSubtitle(product),
            trailing: const Icon(Icons.drag_handle),
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }

            final product = _orderedProducts.removeAt(oldIndex);
            _orderedProducts.insert(newIndex, product);
          });
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, _orderedProducts),
            child: const Text('Save Order'),
          ),
        ),
      ),
    );
  }

  // UI builder
  Widget? _buildProductSubtitle(Product product) {
    final parts = [
      product.brand,
      product.productType,
    ]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .toList();

    if (parts.isEmpty) return null;

    return Text(parts.join(' - '));
  }
}