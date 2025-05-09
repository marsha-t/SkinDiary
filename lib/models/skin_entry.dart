import 'package:skin_diary/models/product.dart';

class SkinEntry {
  final String id;
  final DateTime date;
  final List<Map<String, String>> photos;
  final int rating;
  final List<String>tags;
  final String notes;
  final List<Product> productsUsed;

  SkinEntry({
    required this.id,
    required this.date,
    required this.photos,
    required this.rating,
    required this.tags,
    required this.notes,
    this.productsUsed = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'photos': photos.map((p)=> {'path': p['path'], 'label': p['label']}).toList(),
      'rating': rating, 
      'tags': tags.join(','),
      'notes': notes,
      'productsUsed': productsUsed.map((p) => p.toMap()).toList(),
    };
  }
  
  factory SkinEntry.fromMap(Map<String, dynamic> map) {
    final rawPhotos = (map['photos'] is List) ? List<dynamic>.from(map['photos']) : [];
    final parsedPhotos = rawPhotos.map((p) => {
      'path': p['path'] as String, 
      'label': p['label'] as String,
    }).toList();
    
    return SkinEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      photos: parsedPhotos,
      rating: map['rating'],
      tags: (map['tags'] as String).split(','),
      notes: map['notes'],
      productsUsed: map['productsUsed'] != null 
        ? List<Product>.from(map['productsUsed'].map((p) => Product.fromMap(p)))
        : [],
    );
  }
}