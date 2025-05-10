import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/screens/add_edit_product.dart';
import 'package:skin_diary/services/storage_product.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  List <Product> _products = [];
  
  @override 
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await StorageProduct.getAllProducts();
    products.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _products = products;
    });
  }

  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (result != null) {
      _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${result.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await StorageProduct.saveProduct(result);
              _loadProducts();
            },
          ),
        ),
      );
    } else {
      _loadProducts();
    }  
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(product: product),
      ),
    );

    if (result != null) {
      _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${result.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              await StorageProduct.saveProduct(result);
              _loadProducts();
            },
          ),
        ),
      );
    } else {
      _loadProducts();
    }
  }

  Future<void> _deleteProduct(String id) async {
    final deletedProduct = _products.firstWhere((p) => p.id == id);
    await StorageProduct.deleteProduct(id);
    setState(() {
      _products.removeWhere((p) => p.id == id);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${deletedProduct.name}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await StorageProduct.saveProduct(deletedProduct);
            setState(() {
              _products.add(deletedProduct);
              _products.sort((a, b) => a.name.compareTo(b.name));
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Shelf')),
      body: _products.isEmpty
          ? const Center(child: Text('No products added yet.'))
          : ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return Dismissible(
                key: ValueKey(product.id),
                direction: DismissDirection.endToStart,
                background: _buildDismissibleBackground(),
                confirmDismiss: (_) => _confirmDelete(product),
                onDismissed: (_) => _deleteProduct(product.id),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.brand ?? ''),
                  onTap: () => _navigateToEditProduct(product),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDismissibleBackground() => Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
  
  Future<bool?> _confirmDelete(Product product) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
