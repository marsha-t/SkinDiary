import 'package:flutter/material.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/services/storage_product.dart';

class SelectProductScreen extends StatefulWidget {
  final List<Product>? initialSelection;

  const SelectProductScreen({super.key, this.initialSelection});

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  List<Product> _allProducts = [];
  List<Product> _selectedProducts = [];
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  void _loadProducts() async {
    final products = await StorageProduct.getAllProducts();
    setState(() {
      _allProducts = products;
      _selectedProducts = widget.initialSelection ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Product(s)')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _allProducts.isEmpty 
            ? const Center (
                child: SingleChildScrollView (
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No products found. Add products to your shelf first', style: TextStyle(fontSize: 16)),
                    ],
                  ),
              )
            )
            : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _allProducts.length,
                    itemBuilder: (context, index) {
                      final product = _allProducts[index];
                      return CheckboxListTile(
                        title: Text(product.name),
                        value: _selectedProducts.any((p) => p.id == product.id),
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (isChecked == true && (!_selectedProducts.any((p) => p.id == product.id))) {
                              _selectedProducts.add(product);
                            } 
                            else {
                              _selectedProducts.removeWhere((p) => p.id == product.id);
                            }
                          });
                        }
                      );
                    }
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), 
                  child: const Text("Cancel")
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedProducts), 
                  child: const Text('Save'),
                ),
              ]
            )
        ),
      )
    );
  }
}