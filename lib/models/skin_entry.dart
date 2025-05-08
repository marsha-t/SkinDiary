class SkinEntry {
  final String id;
  final DateTime date;
  final List<Map<String, String>> photos;
  final int rating;
  final List<String>tags;
  final String notes;
  
  SkinEntry({
    required this.id,
    required this.date,
    required this.photos,
    required this.rating,
    required this.tags,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'photos': photos.map((p)=> {'path': p['path'], 'label': p['label']}).toList(),
      'rating': rating, 
      'tags': tags.join(','),
      'notes': notes,
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
    );
  }
}