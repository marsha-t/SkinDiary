enum ProductStatus { active, archived }

class Product {
  final String id;
  final String name;
  final List<String> categories; // e.g., ['Morning', 'SPF']
  final DateTime dateAdded;
  final ProductStatus status;
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
    this.status = ProductStatus.active,
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
      'status': status.name,
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
      status: ProductStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => ProductStatus.active,
      ),
      dateOpened:
          map['dateOpened'] != null ? DateTime.parse(map['dateOpened']) : null,
      expirationDate:
          map['expirationDate'] != null
              ? DateTime.parse(map['expirationDate'])
              : null,
      keyIngredients:
          map['keyIngredients'] != null
              ? List<String>.from(map['keyIngredients'])
              : null,
      brand: map['brand'],
      productType: map['productType'],
      notes: map['notes'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    List<String>? categories,
    DateTime? dateAdded,
    ProductStatus? status,
    DateTime? dateOpened,
    DateTime? expirationDate,
    List<String>? keyIngredients,
    String? brand,
    String? productType,
    String? notes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      dateAdded: dateAdded ?? this.dateAdded,
      status: status ?? this.status,
      dateOpened: dateOpened ?? this.dateOpened,
      expirationDate: expirationDate ?? this.expirationDate,
      keyIngredients: keyIngredients ?? this.keyIngredients,
      brand: brand ?? this.brand,
      productType: productType ?? this.productType,
      notes: notes ?? this.notes,
    );
  }
}
