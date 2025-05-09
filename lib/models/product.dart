class Product {
  final String id;
  final String name;
  final List<String> categories; // e.g., ['Morning', 'SPF']
  final DateTime dateAdded;
  final DateTime? dateOpened;
  final DateTime? expirationDate;
  final List<String>? keyIngredients;
  final String? brand;
  final String? productType;
  final String? notes;

  Product({
    required this.id,
    required this.name,
    required this.categories,
    required this.dateAdded,
    this.dateOpened,
    this.expirationDate,
    this.keyIngredients,
    this.brand,
    this.productType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categories': categories,
      'dateAdded': dateAdded.toIso8601String(),
      'dateOpened': dateOpened?.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'keyIngredients': keyIngredients,
      'brand': brand,
      'productType': productType,
      'notes': notes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      categories: List<String>.from(map['categories']),
      dateAdded: DateTime.parse(map['dateAdded']),
      dateOpened: map['dateOpened'] != null ? DateTime.parse(map['dateAdded']) : null,
      expirationDate: map['dateAdded'] != null ? DateTime.parse(map['dateAdded']) : null,
      keyIngredients: map['keyIngredients'] != null ? List<String>.from(map['keyIngredients']) : null,
      brand: map['brand'],
      productType: map['productType'],
      notes: map['notes'],
    );
  }
}
