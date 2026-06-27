import 'package:skin_diary/models/product.dart';
import 'package:skin_diary/models/entry_photo.dart';

class SkinEntry {
  final String id;
  final DateTime date;
  final List<EntryPhoto> photos;
  final int rating;
  final List<String> tags;
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
      'photos': photos.map((photo) => photo.toMap()).toList(),
      'rating': rating,
      'tags': tags.join(','),
      'notes': notes,
      'productsUsed': productsUsed.map((p) => p.toMap()).toList(),
    };
  }

  factory SkinEntry.fromMap(Map<String, dynamic> map) {
    return SkinEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      photos:
          map['photos'] != null
              ? List<EntryPhoto>.from(
                map['photos'].map(
                  (photo) =>
                      EntryPhoto.fromMap(Map<String, dynamic>.from(photo)),
                ),
              )
              : [],
      rating: map['rating'],
      tags:
          (map['tags'] as String? ?? '')
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList(),
      notes: map['notes'],
      productsUsed:
          map['productsUsed'] != null
              ? List<Product>.from(
                map['productsUsed'].map((p) => Product.fromMap(p)),
              )
              : [],
    );
  }

  SkinEntry copyWith({
    String? id,
    DateTime? date,
    List<EntryPhoto>? photos,
    int? rating,
    List<String>? tags,
    String? notes,
    List<Product>? productsUsed,
  }) {
    return SkinEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      productsUsed: productsUsed ?? this.productsUsed,
    );
  }
}
