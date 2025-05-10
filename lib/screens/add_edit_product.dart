import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/services/storage_product.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _brand;
  late String _notes;
  List<String> _categories = [];
  DateTime? _dateOpened;
  DateTime? _expirationDate;
  List<String>? _keyIngredients = [];
  String? _productType;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _brand = widget.product?.brand ?? '';
    _notes = widget.product?.notes ?? '';
    _dateOpened = widget.product?.dateOpened;
    _expirationDate = widget.product?.expirationDate;
    _keyIngredients = widget.product?.keyIngredients ?? [];
    _categories = widget.product?.categories ?? [];
    _productType = widget.product?.productType ?? '';
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final now = DateTime.now();
    final newProduct = Product(
      id: widget.product?.id ?? now.toIso8601String(),
      name: _name,
      brand: _brand,
      notes: _notes,
      dateAdded: widget.product?.dateAdded ?? now,
      dateOpened: _dateOpened,
      expirationDate: _expirationDate,
      categories: _categories,
      keyIngredients: _keyIngredients,
      productType: _productType,
    );

    await StorageProduct.saveProduct(newProduct);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) {
      Navigator.pop(context); // Nothing to delete
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${widget.product!.name}"?'),
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

    if (confirm == true) {
      await StorageProduct.deleteProduct(widget.product!.id);
      if (!mounted) return;
      Navigator.pop(context, widget.product); // Return deleted product
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNameField(),
              _buildBrandField(),
              _buildProductTypeField(),
              _buildCategoriesField(),
              _buildIngredientsField(),
              _buildDateField('Date Opened', _dateOpened, (picked) {
                setState(() => _dateOpened = picked);
              }),
              _buildDateField('Expiration Date', _expirationDate, (picked) {
                setState(() => _expirationDate = picked);
              }),
              _buildNotesField(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(isEditing ? 'Update Product' : 'Add Product'),
              ),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ElevatedButton(
                    onPressed: _deleteProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete Product'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() => TextFormField(
    initialValue: _name,
    decoration: const InputDecoration(labelText: 'Product Name'),
    validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
    onSaved: (value) => _name = value ?? '',
  );

  Widget _buildBrandField() => TextFormField(
    initialValue: _brand,
    decoration: const InputDecoration(labelText: 'Brand'),
    onSaved: (value) => _brand = value ?? '',
  );

  Widget _buildProductTypeField() => TextFormField(
    initialValue: _productType,
    decoration: const InputDecoration(labelText: 'Product Type (e.g. Serum, Cleanser)'),
    onSaved: (value) => _productType = value,
  );

  Widget _buildCategoriesField() => TextFormField(
    initialValue: _categories.join(', '),
    decoration: const InputDecoration(labelText: 'Categories (comma-separated)'),
    onSaved: (value) {
      _categories = value!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    },
  );

  Widget _buildIngredientsField() => TextFormField(
    initialValue: _keyIngredients?.join(', '),
    decoration: const InputDecoration(labelText: 'Key Ingredients (comma-separated)'),
    onSaved: (value) {
      final input = value?.trim();
      _keyIngredients = (input?.isEmpty ?? true)
          ? null
          : input!.split(',').map((e) => e.trim()).toList();
    },
  );

  Widget _buildDateField(String label, DateTime? value, void Function(DateTime) onPicked) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(value == null
          ? 'Select $label'
          : '$label: ${DateFormat.yMMMd().format(value)}'),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }

  Widget _buildNotesField() => TextFormField(
    initialValue: _notes,
    decoration: const InputDecoration(labelText: 'Notes'),
    maxLines: 3,
    onSaved: (value) => _notes = value ?? '',
  );
}
